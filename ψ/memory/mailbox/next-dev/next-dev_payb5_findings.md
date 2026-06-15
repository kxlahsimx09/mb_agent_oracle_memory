# next-dev — PAYOUT slice 5 (campaign payb5) findings

**Campaign:** payb5 · **Branch:** `build/payout-slice5` (off `campaign/payb5` @ `2e65dce` = `origin/main` HEAD) · **Slot:** dev-1 (`qvmjywljrgqzyxshexhx`, mb-next-dev1) · **Date:** 2026-06-13 · **SPEC:** `docs/spec/payout-correction-toolkit-slice.md` · **PR:** (DO NOT MERGE — opened vs `main`)

## 1. TL;DR

The FINAL payout slice — the admin **correction toolkit**. **Largely greenfield** (census §2): nothing at HEAD implemented `correction`, `reverse_settle`, or the WALLET-008 reverse fan-out. Built **three greenfield SECURITY DEFINER RPCs** + **two admin EFs**. The **money-safe move was REUSE, not reinvention**: the correction success leg delegates to the sealed `mark_success` VERBATIM (settle + PW2 fan-out + residual + PV1-R guard + `payout.success` callback), and `reverse_settle` reconstructs the clawback from `mark_success`'s own change-log rows (CB3). **`mark_success` / the forward fan-out / `match_payout_statement` were NOT touched** — the slice-1/bbot cross-boundary seal held. **The clawback-conservation money rule is fully pinned by the ratified text** (the 3 directive-named edge classes resolve via CB3 reconstruct-exact / `mdr_skip`→residual / PW3 shortfall) → I did **not** STOP; four *secondary* edges surfaced as non-blocking architect notes (§6). **dev-1 smoke 6 scenarios + AM5, ~50 assertions GREEN** (+1 deliberate teeth-RED), `BEGIN…ROLLBACK` footprint 0. One PR open vs main (DO NOT MERGE).

## 2. Census — greenfield vs reused (verified at HEAD on dev-1)

| Symbol | At HEAD | This slice |
|---|---|---|
| `admin_correct_payout(uuid,uuid,text,text,text)` | **ABSENT** | **GREENFIELD — built** (migration `…000010`). |
| `admin_reverse_settle_payout(uuid,uuid,text,text)` | **ABSENT** | **GREENFIELD — built.** |
| `mdr_clawback_fanout(text,uuid,text)` — the **WALLET-008** reverse fan-out (`mdr_clawback` / `mdr_unwind_shortfall` per partner + residual unwind) | **ABSENT** — no `mdr_clawback`/`mdr_unwind_shortfall` substrate anywhere | **GREENFIELD — built as part of this slice** (named; Phase-1 trigger `payout_reverse` only; `topup_cancel`/`deposit_refund` are other epics'). |
| `mark_success(uuid,text)` (slice-1 settle+PW2+PV1-R+cb) | present `…0110` | **REUSED VERBATIM** — correction success leg `PERFORM mark_success`. **NOT modified.** |
| `mark_failed` / `mark_failed_from_review` | present | **NOT used** by reverse_settle (processing-only / review-only — neither accepts `success`). reverse_settle flips `success→failed` inline (own SM3 guard). |
| `write_audit_log(...)` + `tr_audit_log_denorm` | present | **REUSED** — both RPCs write one canonical audit row, `actor_type='admin'` ⇒ denorm fires onto `ts_payouts.last_admin_action_*`. |
| `wallets_change_logs.operation` / `audit_log.action_type` | **free-text, NO CHECK/enum** | **No "AM4 enum" migration needed** — the new op/action strings (`payout_reverse_settle`, `mdr_clawback`, `mdr_unwind_shortfall`, `correction`, `reverse_settle`) write directly. |
| `wallet` CHECKs `frozen≥0` + `balance≥frozen` | present | **AM5 binding** — drives the correction failed-path PRE-freeze ordering + the clawback full-or-audit-only floor. |
| residual wallet | `owner_type='mdr_owner'` (single row `33333333…01ff`; **no `is_owner` column**) | both legs resolve it by `owner_type='mdr_owner' ORDER BY id LIMIT 1` (matches mark_success). |

## 3. The two money branches (the heart) — re-derived from the ratified text

**PAYOUT-012 `correction` — source-state-dependent client leg (CT1.2), success leg inherited.**
- **review-source** (freeze held): `PERFORM mark_success` directly → settle-from-freeze (`balance −gross AND frozen −gross`) + fan-out + cb. ONE `payout_settle` row.
- **failed-source** (freeze released): re-establish freeze (`frozen += gross`, one `payout_freeze` row) + normalize status `failed→review` (**transient, same-txn, never committed-visible**) + `PERFORM mark_success` → the re-freeze + settle **net** to a pure re-debit (`balance −gross`, `frozen` unchanged). **PRE-freeze (not post-adjust)** because `wallet_frozen_nonneg (frozen≥0)` forbids dipping frozen below 0.
- Both: success leg = `mark_success` VERBATIM (PW2 + residual + PV1-R + exactly-one `payout.success`); `write_audit_log('correction','admin',…,{source_state})`.

**PAYOUT-013 `reverse_settle` — re-credit + clawback + residual unwind (PW1/PW3/CB3-5).**
- PW1 client re-credit: `payout_reverse_settle`, `balance += gross`, frozen unchanged (no re-freeze) — unconditionally AM5-safe.
- `mdr_clawback_fanout` reconstructs from the change-log by `reference_id` (CB3 — reverses the *recorded* amounts, no re-rounding): per-partner **net** forward credit (`Σ mdr_distribute − Σ mdr_clawback − Σ mdr_unwind_shortfall`); coverable → full `mdr_clawback`, else audit-only `mdr_unwind_shortfall` (full share); `mdr_owner` residual unwound (always covers).
- **Reverse-conservation (CB5), exact by construction:** `Σ mdr_clawback + Σ mdr_unwind_shortfall + residual_unwound = payout_fee` (single-generation). Smoke S4/S5 assert it = 20.
- Corrective `payout.failed` callback (CT3): own `event_id` + explicit unique `dedup_key = payout:<id>:payout.failed:<audit_id>` (never suppressed by a prior terminal). Commits even on a partner shortfall (PW3).

## 4. dev-1 deploy + smoke (GREEN, zero-footprint)

Applied `20260613000010_payout012013_correction_reverse_settle.sql` to dev-1 via psql (recorded in `supabase_migrations.schema_migrations`; HEAD now `20260613000010`). Smoke in one `BEGIN…ROLLBACK` (`/tmp/payb5_smoke.sql`, dev scratch — not committed; `.secrets/` is deploy-guarded). Footprint verified **0** (own client/payouts gone; `mdr_owner` balance back to 0.00) after rollback.

| Scenario | Asserts | Result |
|---|---|---|
| **S1 — 012 correction from FAILED** | outcome=corrected/source=failed; status→success; **balance 5000→3980, frozen unchanged=0** (re-debit); P1+5/P2+5/owner+10; 1 `payout.success` cb; 1 `correction`/admin audit + `source_state=failed` metadata; denorm `last_admin_action_type=correction`; wcl `payout_freeze`+`payout_settle`+2 `mdr_distribute`+`mdr_residual` | **GREEN** |
| **S2 — 012 correction from REVIEW** | outcome=corrected/source=review; status→success; **balance 5000→3980 AND frozen 1020→0** (settle-from-freeze); P1/P2/owner; 1 cb; audit `source_state=review`; **NO re-freeze row** + 1 `payout_settle` | **GREEN** |
| **S3 — 012 SM3 illegal source** | pending/`already-success`(CT2)/cancelled → `not_correctable`+status echo, **no money/cb/audit**; unknown→`not_found` | **GREEN** |
| **S4 — 013 reverse_settle (all coverable)** | outcome=reversed; clawed=10/shortfall=0/residual=10; **CB5 conservation =20=payout_fee**; status→failed, failure_code NULL; **client re-credited 3980→5000, frozen unchanged**; P1/P2 clawed→0; owner unwound→start; 1 corrective `payout.failed` cb (`failureCode=admin_reverse_settle`, dedup_key refs audit_id, own event_id); denorm `reverse_settle`; wcl 1 `payout_reverse_settle`+3 `mdr_clawback`+0 shortfall | **GREEN** |
| **S5 — 013 reverse_settle w/ partner SHORTFALL** | outcome=reversed (**txn COMMITS**); clawed=5(P2)/shortfall=5(P1)/residual=10; **CB5 conservation =20 even with shortfall**; **P1 UNTOUCHED (balance 2, no deduct)**; P2→0; owner unwound; 1 `mdr_unwind_shortfall(P1,5)` queryable; `shortfalls[]` lists P1; client re-credited | **GREEN** |
| **S6 — 013 SM3 illegal source** | review/failed→`not_success`+status echo, no cb; unknown→`not_found` | **GREEN** |
| **AM5 global** | no wallet with `balance<frozen ∨ frozen<0` after all moves | **GREEN** |
| **teeth sentinel** | a deliberate `assert(1=2)` → RED (aborts, "UNREACHABLE" never prints) | **RED as designed** |

**Inheritances verified, not rebuilt:** the settle + PW2 fan-out + residual + PV1-R `mdr_over_allocated` guard + exactly-one `payout.success` (via `mark_success`); the corrective-callback dedup; the §ADR-13 D2 denorm.

**NOT-step-up (verified by-read):** neither RPC nor EF references any step-up module — the EFs import only `adminAuth`/`requirePermission`/`rpc`/`json`; the auth chain is JWT-verify → aal2 → IP-allowlist → RBAC `payout:approve`, with **no second-factor**. (§ADR-2 §S2 carve-out — current-parity.) The dev smoke is RPC-level (no JWT); the 401/403 + no-step-up-challenge EF legs need the deployed EF + minted aal2 bearers → tester (payb5t) + brew-ops.

**EF layer (NOT covered by dev smoke — by design):** `admin-payout-correct` / `admin-payout-reverse-settle` are **not deployed on dev-1** (EF deploy + `config.toml` registration is brew-ops's single-owner job — the deploy-env-guard blocked my `config.toml` edit). The auth shell is verified-by-read (byte-identical to `admin-payout-reconcile`).

## 5. CROSS-STACK DEPLOY HANDOFF (for brew-ops / tester)

**Migration to apply (after `…000260`):**
1. `supabase/migrations/20260613000010_payout012013_correction_reverse_settle.sql` (HEAD on dev-1).

**`config.toml` registration — brew-ops (I was deploy-guard-blocked from editing it).** Add, alongside the other admin-payout EFs:
```toml
[functions.admin-payout-correct]
verify_jwt = false

[functions.admin-payout-reverse-settle]
verify_jwt = false
```

**Edge Functions to deploy — brew-ops:** `admin-payout-correct` + `admin-payout-reverse-settle` (new; both **404 on dev-1**). Deploy to dev-1 + tester + seal with `--no-verify-jwt` (the EF owns verification; `verify_jwt=false`). No `_shared/*` change (both import the already-flipped `adminAuth`).

**New RPCs (readiness gate), all `service_role` EXECUTE only (SV8 tight; no PUBLIC):**
- `admin_correct_payout(uuid,uuid,text,text,text)` → jsonb
- `admin_reverse_settle_payout(uuid,uuid,text,text)` → jsonb
- `mdr_clawback_fanout(text,uuid,text)` → jsonb

**No new app_settings / flags. No new wcl/audit enum** (free-text columns). Reuses `mark_success`, `write_audit_log`, `tr_audit_log_denorm`, the single `mdr_owner` wallet.

**Stack-readiness gate (before payb5t probes):** RPCs above + `mark_success(uuid,text)` + `write_audit_log` present; tables `ts_payouts`/`withdrawal_queue`/`wallet`/`wallets_change_logs`/`callback_queue`/`audit_log`/`mdr_profile`/`mdr_profile_partners`/`client`; **EFs `admin-payout-correct` + `admin-payout-reverse-settle` deployed**; a `super_admin` `app_user` for `payout:approve` + a mintable aal2 bearer.

## 6. Routed observations / contract questions (NON-BLOCKING — surfaced to next-architect)

The **clawback-conservation money rule itself is fully pinned** (the 3 directive-named edge classes — rounding / partner-wallet-missing / shortfall — resolve via CB3 reconstruct-exact / forward-`mdr_skip`→residual / PW3 full-or-audit-only). So I did **not** STOP. These four are **secondary** edges the ratified text does not explicitly pin; each is built with the conservation-/AM5-safe default and flagged (SPEC §8):

1. **§8-A — `correction` failed-path client insufficiency.** If the client *spent* the released funds after the false-FAILED, the AM5 re-freeze RAISEs → whole correction rolls back (fail-closed, payout stays `failed`). CT1.2 doesn't pin client-leg insufficiency. **Q:** fail-closed vs an audit-shortfall on the client leg? (Dominant case — recent false-FAILED, funds intact — unaffected.)
2. **§8-B — multi-generation reconstruction (re-correction loops).** CB3/CB5 assume one forward distribution per `reference_id`. Implemented **netting by `reference_id`** (`Σ mdr_distribute − Σ mdr_clawback − Σ mdr_unwind_shortfall`), single-generation-exact + receivable-aware. **Q:** confirm netting is the intended reconstruction for a re-corrected payout.
3. **§8-C — corrective-callback dedup on repeat-success.** `reverse_settle` sets an explicit unique `dedup_key`; `correction` inherits `mark_success`'s static `payout:<id>:payout.success` — unique in the dominant single-correction case, but a *second* success via re-correction would collide (UNIQUE → fail-safe rollback). `mark_success` is sealed (not touched). **Q:** should the rare repeat-success correction get a corrective dedup_key (needs a `mark_success` touch → architect-gated)?
4. **§8-D — `reverse_settle` failure_code taxonomy.** `ts_payouts_failure_code_check` has no reverse code → the **column** is NULL, the **callback payload** carries `failureCode='admin_reverse_settle'` (same latent asymmetry as `bank_maintenance`). **Q:** add `admin_reverse_settle`/`reversed` to the CHECK + the failed-terminal whitelist (shared-constraint change — out of this slice)?

**RBAC permission:** both EFs reuse the existing `payout:approve` (super_admin, the sibling `admin-payout-reconcile`'s perm) — zero catalogue/seed churn. If finer-grained `payout:correct`/`payout:reverse-settle` perms are wanted, that's a CA-class catalogue-add (architect).

**Cross-boundary lock HELD:** `mark_success` + the forward MDR fan-out + `match_payout_statement` were **NOT modified** — no slice-1 / bbot seal re-opened.

## 7. Status / next

- **PR** vs `main` — **DO NOT MERGE** (reviewer + owner gate). Awaits `next-code-reviewer` APPROVE → team self-merge; then brew-ops cross-stack deploy (§5, **incl. the 2 EFs + config.toml**) → tester (payb5t) VERIFY off the SPEC → investigator seal.
- **Tester:** next-tester spawns into `payb5t` off `origin/build/payout-slice5 : docs/spec/payout-correction-toolkit-slice.md` (§6.7 exact RPC/EF param lists + §3.2/§4.2 outcome→HTTP + §5 SM3 matrix + §2.3 reverse-conservation). The EF 401/403 + no-step-up + 3-actor legs need brew-ops to deploy the 2 EFs + the tester to mint a `super_admin` aal2 bearer.
- **Out of scope (named):** `mark_success` / forward fan-out / `match_payout_statement` semantics (REUSED verbatim — STOP+surface if must change; they did not); step-up (NOT gated); Keep-side P2.16/P2.17 alert workflow; the `topup_cancel`/`deposit_refund` triggers of `mdr_clawback` (other epics); marking/merging/seal/tester/sinuw.
