# next-dev — PAYOUT slice 2 (review/cancel safety rails) — findings + handoff

**Campaign:** payb2 · **Branch:** `build/payout-slice2` (off `origin/main`) · **Slot:** dev-1 (`qvmjywljrgqzyxshexhx`) · **Date:** 2026-06-12
**SPEC (broadcast):** `origin/build/payout-slice2` : `docs/spec/payout-review-cancel-slice.md`
**Stories:** PAYOUT-004 (stuck-claim sweep → `review` + admin reconcile) · PAYOUT-005 (admin cancel a `pending` payout)

---

## 1. TL;DR

The substrate predated the ratified text (same as slice 1). Censused against the **current** ratified PAYOUT-004/005 + the canonical state machine. **PAYOUT-005 stands entirely** (one cosmetic comment). **PAYOUT-004 carried one real money drift** (the reconcile **failed** leg was silently broken by slice-1's SM2-SPLIT) plus a clock/knob drift on the sweep. Three drifts closed; everything else stands. **dev-1 smoke green across all 8 money scenarios** incl. the drift-A fix and the PV1-R guard inheritance. **No authfull collision** — `_shared/admin-auth.ts` is already JWT-flipped at HEAD; I did **not** edit it.

---

## 2. Census — PAYOUT-004 + PAYOUT-005 vs the CURRENT ratified text

| Surface | Verdict | Detail |
|---|---|---|
| `mark_review` (HEAD = `20260516000004`) | **STANDS** | callback-SILENT (the `waiting_to_review` callback was removed in the 2026-05-16 redefinition; the `20260516000001` version that still had it is **superseded**). processing/claimed→review; carries `bank_transaction_id` as a reviewer hint; holds the §ADR-10 freeze. |
| D6 sweep never-auto-fail | **STANDS** | every stale claim → `review`, never `failed`, never revert to `pending` ("triage, never revert", thread #128). |
| reconcile **success** leg | **STANDS** | `admin_reconcile_payout`→`mark_success`; slice-1 `mark_success` accepts `review` (SM2-SPLIT) **and** carries the PV1-R `mdr_over_allocated` residual<0 guard → the reconcile success path **inherits** the fail-close. Verified by smoke S4. |
| reconcile **failed** leg | **DRIFT-A (money)** | `admin_reconcile_payout` delegated to slice-1 `mark_failed`, now **`processing`-ONLY** (SM2-SPLIT) → a `review` payout was a **benign no-op**: freeze NOT released, NO `payout.failed` callback, payout stuck at `review`. PAYOUT-004 AC#4 broken. |
| D6 sweep clock + knob | **DRIFT-B (clock)** | `sweep_stale_claims` read wall-clock `now()` (§ADR-20 T1 violation), no `payout_stuck_review_minutes` knob, not `SECURITY DEFINER`, no service-role grant → not probe-drivable under the injected clock. |
| admin EF headers ("JWT (stub)") | **DRIFT-C (cosmetic)** | the doc-headers said "JWT (stub)"; the imported `adminAuth` was **already** the real gotrue+aal2+RBAC+IP-allowlist gate (JWT-FLIP, owner GO 2026-06-08). Functionally correct, comment stale. |
| `_payout_stuck_review_minutes()` + `payout_stuck_review_minutes` config | **MISSING** | built this slice. |
| `mark_failed_from_review` (sanctioned review→failed producer) | **MISSING** | built this slice. |
| PAYOUT-005 `cancel_stale_payout` + `admin_cancel_payout` | **STANDS** | LO1 lock order, CAS `pending→cancelled` (race-guard → `race_lost`), AM2/AM4 unfreeze + `payout_unfreeze` log, queue cancel, `payout.cancelled` + `admin_cancelled`, §ADR-13 D1/D2. Re-cancel = SM3 benign no-op (409 `not_pending`, zero second effect). No code change. |

---

## 3. The delta (what shipped)

**Migrations (2, forward-only, stack on `20260612000120`):**
- `20260612000130_payout004_reconcile_failed_from_review.sql` — **new `mark_failed_from_review(uuid,text,text)`** (the sanctioned `review → failed` producer: own `review`-source guard, AM2 release, `payout.failed` callback **byte-identical** to `mark_failed`'s; failure_code defaults `system_error`). Re-points `admin_reconcile_payout`'s failed leg to it. Success leg + §ADR-13 envelope unchanged. *Closes DRIFT-A.* It is **distinct** from `mark_failed` (processing-only — the dangerous late-bot path stays locked out) and from PAYOUT-013 `reverse_settle` (`success→failed`).
- `20260612000140_payout004_sweep_appnow_config.sql` — `payout_stuck_review_minutes` app_settings seed (default **5**) + `_payout_stuck_review_minutes()` reader; **rewrites `sweep_stale_claims`** to `(int batch, timestamptz p_now)` reading `app_now()` + the knob, `SECURITY DEFINER` + `service_role` grant; drops the old `(interval)` overload and **re-points the `sweep-stale-claims` cron** to the new signature (cadence unchanged, ≈1 min). *Closes DRIFT-B.*

**Edge Functions (2, comment-only):**
- `admin-payout-cancel/index.ts`, `admin-payout-reconcile/index.ts` — header comments corrected "JWT (stub)" → the real gotrue+aal2+RBAC gate; the reconcile header's lifecycle-RPC note updated to name `mark_failed_from_review`. **No edit to `_shared/admin-auth.ts`.** *Closes DRIFT-C.*

---

## 4. Collision watch (authfull #443–446) — RESOLVED, no overlap

The task flagged a possible collision on `_shared/admin-auth.ts` (authfull **#445** `dev2/auth008-012` touches `_shared/admin-auth.ts` + `_shared/auth.ts`). **Resolution: no overlap.** DRIFT-C turned out to be **comment-only** — `_shared/admin-auth.ts` is **already** JWT-flipped at HEAD, so the payout admin EFs already ride the real gate; the fix is correcting stale comments **in the two payout EF files** (which authfull does **not** touch). **I did not CREATE-OR-REPLACE or edit any `_shared/*` file.** No unilateral resolution of a shared-file conflict; nothing to surface for arbitration.

---

## 5. dev-1 deploy + smoke (green)

Applied `…000130` + `…000140` to dev-1 via psql (recorded in `schema_migrations`); deployed both EFs. RPC-level money smoke — **ALL 8 scenarios PASS**:

| # | Scenario | Result |
|---|---|---|
| S1 | sweep `processing→review`, btxn=NULL **and** btxn=set | both → `review`; **callback-silent**; freeze held; btxn hint carried |
| S1c | threshold boundary relative to the knob | younger-than-knob stays `processing` |
| S2 | reconcile→success (valid profile) | settle 1015; fan-out 6.00+4.00; residual 5.00→`mdr_owner`; one `payout.success`; `clientReferenceId` echoed; D2 denorm set |
| S3 | reconcile→failed **(DRIFT-A fix)** | `review→failed` **RELEASES** (frozen −2030, balance untouched); one `payout.failed` (failureCode `system_error`); one `payout_unfreeze` log |
| S4 | PV1-R over-allocation on reconcile→success | **RAISE `mdr_over_allocated`** (residual −40); stays `review`; full rollback; no callback/audit — guard **inherited** by the reconcile success path |
| S5 | admin cancel `pending` | `cancelled`; unfreeze 507.5 (balance untouched); queue cancelled; one `payout.cancelled` `admin_cancelled`; D2 denorm |
| S6 | re-cancel | `not_pending` (409); **zero second effect** (no 2nd unfreeze/callback/audit) |
| S7 | cancel rejected on `review` + lock-first-wins | `review` cancel → `not_pending` (no effect); a just-claimed (`processing`) payout survives a racing cancel |

**EF gate (live):** no bearer → `401 missing_bearer_token`; garbage bearer → `401 invalid_token` (real `verifyGotrueJwt`). Confirms the EFs ride the real `adminAuth` (DRIFT-C verified). Smoke fixtures cleaned; client wallet restored to `balance=50000, frozen=0` (append-only `wallets_change_logs` rows remain by design).

---

## 6. CROSS-STACK DEPLOY HANDOFF (for brew-ops / owner — tester + seal stacks)

Deploy the slice-2 delta to the **tester** (`payb2t`) and **investigator/seal** stacks (brew-ops/owner hold those slots; I cannot reach them).

**Migrations to apply (in order, after `20260612000120`):**
1. `supabase/migrations/20260612000130_payout004_reconcile_failed_from_review.sql`
2. `supabase/migrations/20260612000140_payout004_sweep_appnow_config.sql`

**Edge Functions to (re)deploy:**
- `admin-payout-cancel`
- `admin-payout-reconcile`

(Both EFs are comment-only this slice — behaviorally unchanged — but redeploy keeps deployed == source. `_shared/admin-auth.ts` / `auth.ts` unchanged.)

**Apply note (out-of-order migration `20260612000070`):** on a stack that is already at `…000120` but **skipped `…000070`** (`adr10_parity_residual_guard_tiebreaker`, a DEPOSIT-lane file, PR #441), `supabase db push` will refuse without `--include-all`. dev-1 was in exactly this state; **`…000070` is DEPOSIT-only (zero payout overlap)** so I applied 130/140 directly via psql and dev-1's payout smoke is unaffected. For tester/seal, either (a) bring the stack to full main parity first (`--include-all`, applies 070 then 130/140 — 070 is non-regressive per its own header), or (b) apply 130/140 directly (they depend only on objects present at 120). Pick (a) for a clean full-parity stack.

**Stack-readiness gate (must hold before the tester runs probes):** `mark_failed_from_review(uuid,text,text)`, `sweep_stale_claims(int,timestamptz)`, `_payout_stuck_review_minutes()`, `admin_reconcile_payout` (calling `mark_failed_from_review`), `admin_cancel_payout` present; `app_settings.payout_stuck_review_minutes` seeded; `app_now`/`clock_set`/`clock_advance`/`clock_reset`/`reset_for_test` present; `admin-payout-cancel` + `admin-payout-reconcile` EFs respond (not 404). Tester fixtures need a `super_admin` `app_user` with a **real gotrue aal2 JWT** for the EF-gate probes (or call the RPCs directly via service-role for the money assertions).

---

## 7. Routed observations (NON-BLOCKING — for next-architect / slice owner; not fixed here)

1. **Claim-path `claimed_at = now()` (§ADR-20 T1 residue).** `claim_withdrawal_items` (`20260520000002`) stamps `claimed_at = now()` (wall clock), not `app_now()` — a bot-lane T1 residue, OUT of this slice (bot-dispatch/PAYOUT-002). The sweep is fully drivable without it (the SPEC §5 drive sets `claimed_at` relative to `app_now()`), but a clean frozen-step anchor would stamp it via `app_now()`. → next-architect/PAYOUT-002 owner.
2. **Deposit admin EFs carry the same stale "JWT (stub)" comment** (`admin-deposit`, `admin-deposit-resolve`, `admin-deposit-verify-now`) — same cosmetic JWT-FLIP residue, DEPOSIT lane, out of scope. → deposit-lane owner.
3. **`mark_review` lacks a positive source-state assert** — it only early-returns on `status='review'` (idempotency), not a `processing`-source assertion. The D6 sweep predicate already constrains the source to `claimed`/`processing`, so it is money-safe in practice (review holds the freeze, no callback, no wallet move). Noted as a robustness nit, not a fix. → next-architect if a positive assert is wanted.

---

## 8. Status / next

- **PR:** ONE PR vs `main` — **DO NOT MERGE** (reviewer + owner gate per build-workflow Step-3). Awaits `next-code-reviewer` APPROVE (body header) → team self-merge; then brew-ops cross-stack deploy (§6) → tester (`payb2t`) VERIFY off the SPEC → investigator seal.
- **Tester:** next-tester spawns into campaign `payb2t` (separate worktree) off `origin/build/payout-slice2 : docs/spec/payout-review-cancel-slice.md`.
- **Out of scope (named overlaps only):** PAYOUT-007..013, fair-router internals, PAYOUT-012/013 correction toolkit (boundary named in SPEC §3.4).
