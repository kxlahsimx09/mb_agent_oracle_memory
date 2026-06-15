# next-dev — PAYOUT slice 4 (campaign payb4) findings

**Campaign:** payb4 · **Branch:** `build/payout-slice4` (off `campaign/payb4` @ `4e6ce6b` = `origin/main` HEAD) · **Slot:** dev-1 (`qvmjywljrgqzyxshexhx`, mb-next-dev1) · **Date:** 2026-06-13 · **PR:** #472 (DO NOT MERGE) · **SPEC:** `docs/spec/payout-resend-reconcile-slice.md`

## 1. TL;DR

The callback/reconcile pair. **The two surfaces were largely already built** — the census found the resend RPC+EF and the reconcile/audit substrate all standing at HEAD. The slice's real work was **closing two §ADR-20 clock drifts** (the predating reconcile/audit was built 05-16..18, before the 06-03 clock baseline) and **one stale EF comment**, then **verifying the inheritances** the SPEC promises (the resend race-guard, the reconcile success leg's settle+PW2+PV1-R, the audit detection-only invariant). Nothing was forked; the shared `match_payout_statement` matcher and `mark_success` settle path are **untouched** (the bbot epic-seal cross-boundary lock held). **dev-1 smoke 37/37 GREEN** (zero-footprint `BEGIN…ROLLBACK`). One PR open vs main (DO NOT MERGE).

## 2. Census — vs the CURRENT ratified text (verified at HEAD on dev-1)

| # | Area | State at HEAD | This slice |
|---|---|---|---|
| **C-A** | `resend_callback(text,uuid,uuid,text,text)` — source-type-generic resend RPC. HEAD def `…0607` (`20260607000002_deposit012_resend_race_guard_dispatching`). | **STANDS — payout already carries the mirrored race-guard.** `…0607` is NOT a deposit-only fork: it `CREATE OR REPLACE`s the **shared** generic RPC, widening the in-flight guard `status='pending'` → `status IN ('pending','dispatching')`. Payout dispatches through the same body → inherits it. Payout terminal set `{success,failed,cancelled}`; `review` callback-silent → `not_terminal`. | **No change.** Census starting-point (a) resolved: **NOT a drift.** |
| **C-B** | EF `payout-resend-callback/index.ts` header | stale `§ADR-2 JWT (stub)`. `admin-auth.ts` is real-gotrue-JWT-flipped at HEAD (`verifyGotrueJwt`, aal2, NO stub fallback; owner GO 2026-06-08). | **Comment-only fix.** Census (b) resolved: comment-only, as predicted. |
| **C-C** | `sweep_payout_reconcile(interval)` — pg_cron 1-min safety-net. HEAD def `…0004`. | wall-clock `now()` on the look-back predicate (§ADR-20 T1 violation), no `p_now` arg, default PUBLIC EXECUTE. | **Rewritten:** `sweep_payout_reconcile(interval, timestamptz DEFAULT NULL)` → `COALESCE(p_now, app_now())`; old 1-arg overload **DROPPED**; SV8 tight grant (no PUBLIC/anon/authenticated; service_role). Cron unchanged (zero-arg call re-resolves). |
| **C-D** | `v_success_payout_audit` VIEW — HEAD def `…0006`. | grace predicate `now() - completed_at > grace_window` (wall-clock → `pending→unconfirmed` not virtual-clock drivable). | **`CREATE OR REPLACE VIEW`** with the single predicate → `app_now() - completed_at > grace_window`. Columns unchanged; in-place. |
| — | `match_payout_statement(uuid)` — shared MATCH-003 matcher. HEAD def `…0007` (FC3 fee-skip). | review→completed branch calls `mark_success(queue_id,bank_ref)`; only `now()` use = cosmetic `updated_at`. Drove bbot epic-seal GREEN. | **NOT MODIFIED** (cross-boundary lock). The clock fixes are in the *caller* sweep + the *read-side* view. |
| — | `mark_success(uuid,text)` — settle RPC. HEAD def `…0110`. | SM2-SPLIT (review accepted) + AM2 settle + PW2 fan-out + PV1-R residual<0 fail-close + exactly-one `payout.success`. | **No change** — the reconcile success leg **inherits** it (verified, smoke B1/B3). |
| — | flag `payout_auto_reconcile_enabled='true'` (ships ON) / `_payout_auto_reconcile_enabled()` (fail-closed); `payout_audit_grace_window='6 hours'` / `_payout_audit_grace_window()`; `bank_capabilities` (KTB-only memo seed) / `_payout_memo_carries_request_id()` (fail-safe false). | **STAND.** Flag-default asymmetry vs slice-3 (`payout_auto_cancel_enabled='false'`) is principled (RR6 zero-safety-regression → opt-out). | **No change** — reused. |

## 3. The two §ADR-20 clock fixes (the slice's actual delta)

The reconcile/audit pieces predate the §ADR-20 clock baseline. Same drift class as slice-2/3's sweeps:
- **C-C** — the safety-net `sweep_payout_reconcile` look-back is now `app_now()`-relative; a probe drives the virtual clock (`clock_set`/`clock_advance`) or passes `p_now`. (The *primary* reconcile path is `reconcile_payout` ← `mark_review`, which has no time predicate; the sweep is the backstop.)
- **C-D** — the audit's grace boundary is now `app_now()`-driven → `pending → unconfirmed` is virtual-clock drivable (smoke C4 proves the flip after `clock_advance(grace+1min)` with no real-time wait).

`mark_success`'s `completed_at = now()` (a recorded state-write timestamp, not a gating predicate) was **left as-is** — it is the slice-2/3 reused pattern and not virtual-clock-relevant; changing it = touching the shared settle path for no test benefit.

## 4. Grace knob — naming reconciliation

The ratified **requirements** name `payout_confirm_grace_minutes` (minutes). The **deployed substrate** uses **`payout_audit_grace_window`** = `'6 hours'` (`interval`, fail-safe 6h, "errs long"). The SPEC + the tester bind the **substrate** name (it is what ships + what bbot ran against). The spec-layer rename is routed (§7.1) — *not* renamed in code (churn/risk on a sealed-adjacent fn). The `payout_confirm_grace_minutes` key does **not** exist in the DB.

## 5. dev-1 deploy + smoke (37/37 GREEN, zero-footprint)

Applied `20260612000260_payout009_reconcile_clock_grace.sql` to dev-1 via psql (recorded in `supabase_migrations.schema_migrations`; renumbered 000250→000260 — 000250 was taken on main by `…_adr10_rm_residual_backfill`). RPC/view smoke in one `BEGIN…ROLLBACK` (`.secrets/payb4_smoke.sql`, dev-artifact, not committed — `.secrets/` is a symlink outside git). Footprint verified **0/0/0** (ts_payouts/callback_queue/bank_statements) after rollback.

| Leg | Scenarios | Result |
|---|---|---|
| **PAYOUT-007 resend (RPC)** | admin/client/sub-client accepted + actor-triple (`triggered_by='manual_resend'`); all 3 terminals {success,failed,cancelled}; review→`not_terminal`; in-flight→`already_in_flight`; empty-url→`no_callback_url`; append (new cb row, same `event_id`, new `dedup_key`, pending) | **12/12 PASS** |
| **PAYOUT-009 reconcile** | flag-ON `reconciled` (review→success; balance 5000→3980 & frozen 1020→0; one `payout_settle`; PW2 `mdr_distribute`(10)+`mdr_residual`(10); exactly one `payout.success`; stmt `matched`+linked); flag-OFF `disabled` no-op; **PV1-R** `mdr_over_allocated` whole-rollback (wallet 5000/1005 intact); never-auto-fail `anomaly_terminal_mismatch`; `amount_mismatch` | **13/13 PASS** |
| **PAYOUT-009 audit** | `confirmed`; `exempt(intrabank)`; `exempt(non_memo)`; `pending`→`unconfirmed(no_confirming_debit)` via `clock_advance`; `unconfirmed(amount_mismatch)`; SC8 flag-off `audit_disabled` (no `unconfirmed` rows); **SC6 detection-only** (status/callback/wallet byte-identical across reads) | **12/12 PASS** |

**Inheritances verified, not rebuilt:** the resend race-guard (C-A), the reconcile success leg's settle+PW2+PV1-R+exactly-once-callback via `mark_success` (B1/B3), the audit detection-only invariant (C7).

**EF layer (NOT covered by dev smoke — by design):** `payout-resend-callback` is **404 on dev-1** (not deployed). EF deploy is **brew-ops's single-owner job** (deploy-env-guard blocked my `supabase functions deploy`; the dev tests RPC/gate logic via SQL per the dev-slot model). The EF auth shell + tenant-scope (`tenantScopeVerdict`) is verified-by-read (identical shape to the deposit-012 EF, the first live `tenantScopeVerdict` exerciser). The **3-actor + tenant-scope-403** legs need the deployed EF + minted aal2 bearers → **tester (payb4t) + brew-ops**.

## 6. CROSS-STACK DEPLOY HANDOFF (for brew-ops / tester)

**Migration to apply (after `…000170`/`…000230`/`…000240`):**
1. `supabase/migrations/20260612000260_payout009_reconcile_clock_grace.sql` (renumbered from 000250 — collision with the merged `…000250_adr10_rm_residual_backfill`; 000260 is what brew-ops deployed to the stacks)

**Edge Functions to (re)deploy — brew-ops:** **`payout-resend-callback`** (carries the C-B comment fix; **404 on dev-1 — deploy it**). Deploy to dev-1 + tester + seal with `--no-verify-jwt` (the EF owns verification; `verify_jwt=false`). No `_shared/*` change beyond the one comment. (DEPOSIT-012 sibling `deposit-resend-callback` unchanged.)

**Changed RPC / signatures (readiness gate):**
- `sweep_payout_reconcile(interval, timestamptz)` — **replaces** `sweep_payout_reconcile(interval)` (1-arg overload DROPPED). `service_role` EXECUTE only.
- VIEW `v_success_payout_audit` — `CREATE OR REPLACE` (now `app_now()`-driven grace). Columns unchanged.

**Cron:** `sweep-payout-reconcile` (`* * * * *`) — **unchanged**; the zero-arg call re-resolves to the new 2-arg signature.

**No new app_settings keys / flags** — reuses `payout_auto_reconcile_enabled` (default `'true'`, ships ON) + `payout_audit_grace_window` (default `'6 hours'`); `bank_capabilities` ktb-only memo seed.

**Cross-lane #463 (SV8 revoke, OPEN, branch `arch/sv8-revoke-payout-fns`, migration `…000240`):** **non-colliding.** #463 REVOKEs EXECUTE on 6 *other* payout fns (create_payout, _payout_stuck_review_minutes, mark_failed_from_review, sweep_payouts_bank_maintenance, sweep_stale_claims, sweep_stale_payouts). My new `sweep_payout_reconcile` ships the same tight grant from the start. **If #463 merges mid-slice:** re-verify `service_role` EXECUTE survives on my fn (it will — identical pattern) and that the migration order stays clean (my `…260` is after #463's `…240`). No overlap in the function sets.

**Stack-readiness gate (must hold before payb4t probes):** RPCs `resend_callback(text,uuid,uuid,text,text)`, `match_payout_statement(uuid)`, `reconcile_payout(uuid)`, `sweep_payout_reconcile(interval,timestamptz)`, `mark_success(uuid,text)`, `mark_review(uuid,text,text)`, `classify_success_payout(uuid)`, `_payout_auto_reconcile_enabled()`, `_payout_audit_grace_window()`, `_payout_memo_carries_request_id(text)`, `app_now`/`clock_set`/`clock_advance`/`clock_reset`/`reset_for_test` present; VIEW `v_success_payout_audit`; pg_cron `sweep-payout-reconcile`; `app_settings.payout_auto_reconcile_enabled`+`payout_audit_grace_window` seeded; `bank_capabilities` has the `ktb` memo row; **EF `payout-resend-callback` deployed**.

## 7. Routed observations (NON-BLOCKING — not fixed here)

1. **Grace-knob name divergence (→ next-writer/architect).** `epic-payout.md` `payout_confirm_grace_minutes` vs deployed `payout_audit_grace_window`. Reconcile the spec layer to the substrate (the deployed reality). §4 above.
2. **SV8 latent exposure on the pre-SV8 reconcile/audit fns (→ next-architect / next `execute_or_no_grants` sweep).** `_payout_auto_reconcile_enabled`, `_extract_payout_request_ids`, `reconcile_payout`, `_payout_memo_carries_request_id`, `_payout_audit_grace_window`, `classify_success_payout`, `match_payout_statement` were born (05-16..20) with default PUBLIC EXECUTE — the **same class PR #463 caught**. This slice ships its new fn (`sweep_payout_reconcile`) with the tight grant but does **not** retro-revoke the untouched ones (#463's lane; and `match_payout_statement`'s grants are deliberately untouched per the cross-boundary lock). Recommend folding into the next SV8 revoke batch.
3. **Deposit sibling stale comment (→ DEPOSIT-012 owner).** `deposit-resend-callback/index.ts` carries the same `§ADR-2 JWT (stub)` comment — out of this payout slice; fix symmetrically.
4. **DRIFT-V — the `v_payouts`/`v_payouts_read`/`v_deposits` `effective_status` 0-lag view-clock `now()` residue** — carried from slice 3 (read-side view family; one architect-owned §ADR-20 view-clock hardening). Untouched.

## 8. Status / next

- **PR #472** vs `main` — **DO NOT MERGE** (reviewer + owner gate). Awaits `next-code-reviewer` APPROVE → team self-merge; then brew-ops cross-stack deploy (§6, **incl. the EF**) → tester (payb4t) VERIFY off the SPEC → investigator seal.
- **Tester:** next-tester spawns into `payb4t` (separate worktree) off `origin/build/payout-slice4 : docs/spec/payout-resend-reconcile-slice.md` (§5.7 exact RPC/EF param lists + outcome→HTTP maps; §5 canonical reconcile + virtual-clock audit-grace drives). The 3-actor + tenant-scope-403 EF legs need brew-ops to deploy `payout-resend-callback` + the tester to mint aal2 bearers.
- **Out of scope (named overlaps only):** PAYOUT-012/013; `match_payout_statement` semantics (REUSED verbatim — STOP+surface if it must change; not needed); review→failed auto-direction (RR4 never-auto-fail); Keep-side P2.16 workflow; deposit-resend-callback sibling; the read-view family (§7.4); marking/merging/seal.
