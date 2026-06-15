# next-investigator — PAYOUT EPIC-SEAL findings (campaign `payoutseal`)

**VERDICT: 🟢 GREEN — PAYOUT EPIC-SEAL ISSUED.**
The whole payout lane (PAYOUT-001/002/003/004/005/007/008/009/010/012/013 + the canonical
SM1/SM2/SM2-SPLIT/SM3 + AM2/AM5/PW2/PV1-R/CB3/CB5/LO1 money invariants) is **independently
behaviorally re-derived GREEN** at `origin/main` HEAD on the investigator seal stack
**qnccph**. This is the §ADR-21 **G1** prereq for the payout LIVE/L5 leg. **No blocking
money or safety contradiction was found.** Named-but-non-blocking items are listed in §7.

- **Date:** 2026-06-13
- **Stack:** qnccph (`mb-next-investigator`, `qnccphgykzdydebmdwdf`) — `stack_role=test`, REAL clock.
- **Commit:** `origin/main` HEAD `1af6c73` (PR #478); branch `campaign/payoutseal` == origin/main (0/0 divergence).
- **Migration head:** `20260613000010_payout012013_correction_reverse_settle` — deployed, present; 158 migrations local == deployed.
- **Result:** **70/71 PASS, 1 deliberate teeth-sentinel RED (expected), 0 UNEXPECTED failures.** Zero footprint (verified post-ROLLBACK).
- **Method artifact:** one `BEGIN … ROLLBACK` — [`/tmp/falsify_payoutseal.sql`](file:///tmp/falsify_payoutseal.sql).

> This is the **EPIC seal** (whole lane), distinct from — and **not inherited from** — the 5
> per-slice falsifications (payb1i 77/77 · payb2i 65/65 · payb3i 27+sentinel · payb4i 68/68 ·
> payb5i 161/161) or the 5 tester VERIFY runs (yupsev). All money invariants were re-derived
> from scratch here against the **deployed** RPCs. The LIVE/L5 run is a **separate later step**
> (deferred behind the composed-run infra, like the bbot LIVE) and is **not** part of this seal.

---

## 1. Substrate ground truth (confirmed, not assumed)

- `supabase_migrations.schema_migrations` head = `20260613000010`; the slice-5 row is present; 158 rows == 158 local migration files; local migration head file == deployed head.
- All payout RPCs are deployed and **`SECURITY DEFINER`** with `proacl = {postgres=X, service_role=X}` only (PUBLIC/anon/authenticated revoked — **SV8 seal intact**): `create_payout`, `claim_withdrawal_items`, `mark_success`, `mark_failed`, `mark_failed_from_review`, `mark_review`, `reconcile_payout`, `match_payout_statement`, `cancel_stale_payout`, `admin_cancel_payout`, `admin_reconcile_payout`, `admin_correct_payout`, `admin_reverse_settle_payout`, `mdr_clawback_fanout`, `classify_success_payout`, `sweep_stale_claims`, `sweep_stale_payouts`, `sweep_payouts_bank_maintenance`, `sweep_payout_reconcile`.
- **Cross-boundary lock HELD** (slice-5 migration redefines ONLY the 3 new fns + grants; touches neither sealed fn):
  - `mark_success` `md5(pg_get_functiondef)` = `55561e5aaccb2aa42582a47a5e65a3ff` — byte-unchanged vs the slice-1/bbot-sealed value.
  - `match_payout_statement` `md5` = `966267eed668e235146ae9ca7def6d32` — byte-unchanged.
  - The correction success-leg `PERFORM mark_success(...)` and the reverse reconstruct-from-change-log both consume those sealed fns **verbatim** — no STOP.
- **`ts_payouts_status_check`** = `status = ANY('{pending,processing,success,failed,review,cancelled}')` — exactly the **6-value canonical SM1 set** (see §6 note on the brief's "7-enum").
- **AM5** `wallet_balance_gte_frozen` = `CHECK (balance >= frozen)` + `wallet_frozen_nonneg` (`frozen >= 0`) + `wallet_owner_type_check` ∈ `{client,partner,merchant,mdr_owner}`. `wallets_change_logs.operation` and `audit_log.action_type` are **free-text** (no enum CHECK) — the RPC op strings are written directly.
- **RLS / tenant-scope** (item 5): `ts_payouts`, `withdrawal_queue`, `wallets_change_logs`, `callback_queue`, `wallet` all have `relrowsecurity=t`. The only policy on the four payout-read tables is `rls_read_a4` — **SELECT-only**, for role `authenticated`: `auth_aal2() ∧ has_read_perm('payout') ∧ (auth_db_is_admin() ∨ client_id = auth_db_effective_client_id())`. There is **no INSERT/UPDATE/DELETE policy** → direct table writes by non-owner roles are denied by RLS; all money moves go through the `SECURITY DEFINER` RPCs (which run as owner `postgres` and bypass RLS by design). Tenant isolation on reads is present and correct.
- Baselines (footprint anchors): `ts_payouts` = 0, `audit_log` = 447, `mdr_owner` wallet (`33333333…01ff`) balance = 0.00, the 3 real system banks `77777777…001/002/003` balance = 1,000,000.00 each.

## 2. Method (standing zero-footprint epic-seal pattern)

One `BEGIN … ROLLBACK`. **Own fixtures**: a fresh client + wallet, a callback endpoint, and **my own MDR profile** inserted with `created_at='2020-01-01'` so it wins `create_payout`'s `ORDER BY created_at,id LIMIT 1` (full control of the partner set: P1 1.0% active, P2 0.5% active, P3 0.3% **inactive wallet** → exercises the `mdr_skip` arm), 3 partner wallets, and **12 of my own `bank_account` fixtures** (one per payout — so the real `claim_withdrawal_items` RPC drives every `pending→processing` with no batch/active-count coupling). Reused **read-only**: `merchant_config 11111111…001`, the singleton `mdr_owner` wallet (snapshotted), an active `pool`, the `bank` registry (`bbl`). The 3 real `77…` banks are only **read** by `claim` (balance) — never written. Every PASS is attacked; the harness carries **one deliberately-wrong assertion (SENTINEL)** that **must** go RED to prove non-vacuity.

## 3. What the epic-seal ADDED (beyond per-slice falsification) — all GREEN

### (1) WHOLE-LANE money conservation — `create → claim → settle → reverse_settle` (Lane 1, L1.0–L1.19)
Drove a full lifecycle end-to-end and confirmed **every wallet returns to its exact pre-create satang**:
- create: client `frozen += 1020.00` (=amount 1000 + fee 20), balance untouched (AM2).
- claim (REAL `claim_withdrawal_items`): `pending → processing`.
- settle (`mark_success`): client `balance −1020 AND frozen −1020`; PW2 fan-out P1 `+10.00`, P2 `+5.00`, inactive P3 → `mdr_skip` (no credit), residual `+5.00` → `mdr_owner`; **Σcredited + residual = payout_fee (20.00) EXACT**; exactly one `payout.success` callback.
- reverse_settle (`admin_reverse_settle_payout`): client `balance += 1020`, no re-freeze; per-partner full clawback; residual unwound.
- **CONSERVATION (L1.13–L1.18): client balance & frozen, P1, P2, mdr_owner all back to start; inactive P3 untouched the whole lane; `Σ mdr_clawback (incl. residual) = payout_fee` read from the raw change-log (not a harness sum); 0 shortfall; one corrective `payout.failed` callback (distinct dedup_key).**

### (2) CROSS-STORY interaction (Lanes 2, 3, 5, 6)
- **Reverse with a partner SHORTFALL** (L2): after settle, simulated P2 having withdrawn its share; reverse **commits anyway** — client re-credited FULL gross (made whole), coverable P1 fully clawed, **shortfall partner UNTOUCHED** (no partial deduct), full unrecovered share = **one** `mdr_unwind_shortfall` audit row (5.00), residual leg self-covers, **CB5 `Σclawback(15) + Σshortfall(5) = payout_fee(20)`**, AM5 never violated.
- **Correction `failed → success`** (L3a): RE-DEBIT from spendable (`balance −= gross`, frozen unchanged at the correction — the freeze was already released at `failed`), PW2 fan-out ran, one `payout.success`.
- **Correction `review → success`** (L3b): review HOLDS the freeze (`frozen += gross` at create, not released — proven), then SETTLE-FROM-FREEZE (`balance −= gross AND frozen −= gross`); `review` is **callback-silent** (0 callbacks before the terminal); one `payout.success`. → The same terminal reached two source-state-dependent ways, both correct.
- **success → reverse_settle → re-correct cycle** (L5, §8-C): success then reverse then a re-correction-to-success — the correction's inherited `mark_success` re-INSERTs the static dedup_key `payout:<id>:payout.success` → **`UNIQUE` (23505)** → the whole correction **rolls back (fail-SAFE)**: payout stays `failed`, **NO money moved**. The success→reverse→correct→success cycle is therefore **UNREACHABLE** via the RPCs (so the §8-B multi-generation netting concern is unreachable; single-generation conservation holds by construction).
- **Sweep producers vs admin-cancel share ONE bundle** (L6): `admin_cancel_payout` (PAYOUT-005), `cancel_stale_payout(_,'bank_maintenance')` (PAYOUT-010 per-row), and `cancel_stale_payout(_,'auto_cancelled')` (PAYOUT-008 per-row) all flip `pending → cancelled` through the same `cancel_stale_payout` body — each releases `frozen` (balance untouched), enqueues exactly one `payout.cancelled` callback with the correct distinct failure code, and a **re-cancel is a benign `not_pending` no-op** (no second callback). No interference.

### (3) STATE-MACHINE completeness (Lane 4 + static producer scan)
- **Every illegal source is a benign no-op, no money, no callback:** `mark_success`/`mark_failed`/`mark_failed_from_review` on a `pending` payout (freeze intact, balance untouched, 0 callbacks); `admin_correct_payout` on pending/processing/success → `not_correctable`; `admin_reverse_settle_payout` on non-`success` → `not_success`; `mark_failed_from_review` on `processing` → no-op.
- **SM2-SPLIT** (the dangerous direction is locked out): a late bot **`failed` from `review` is REJECTED** (stays `review`); a late bot **`success` from `review` is ACCEPTED** (→ success).
- **Positive controls:** `processing → failed` via `mark_failed`; duplicate `mark_success` on an already-`success` payout is a no-op (**no second debit, still exactly one `payout.success` callback**).
- **No orphan producer of any terminal** (static scan of every `prokind='f'` function body + the bodies I read): INSERT `pending`=`create_payout`; SET `processing`=`claim_withdrawal_items`; `review`=`mark_review`/`admin_correct_payout`(transient); `success`=`mark_success`; `failed`=`mark_failed`/`mark_failed_from_review`/`admin_reverse_settle_payout`; `cancelled`=`cancel_stale_payout`. The producer set exactly matches the ratified SM2 table — **no function writes `ts_payouts.status` to an out-of-spec literal**.

### (4) Status CHECK (Lane 4, L4.14)
The deployed CHECK is the **6-value canonical SM1 set**. A direct `UPDATE … SET status='completed'` is **rejected with `check_violation`** — the enum is hard-enforced; no Phase-1 producer emits an out-of-spec status.

### (5) RLS / tenant-scope on `ts_payouts` reads
Present and correct — see §1 (read-only `rls_read_a4`, aal2 + payout-read-perm + own-client-or-admin; no write policy).

### Money-safety boundaries (Lanes 7, 8)
- **AM2 spend-guard** (L7): an over-available `create_payout` is rejected with `insufficient_funds` and leaves **zero state** (no payout row, no freeze). **Global AM5**: no wallet ever had `balance < frozen` across the whole run.
- **§8-A fail-closed** (L8): a `correction` from `failed` when the client has **already spent** the released funds — the re-freeze (`frozen += gross`) hits `wallet_balance_gte_frozen` → **`check_violation` → whole correction rolls back**; payout stays `failed`, no partial wallet move, AM5 never violated. The dangerous "re-settle money the client no longer has" path is fail-SAFE, not a forced-negative.

## 4. Per-story coverage map (whole epic)

| Story | Behaviour sealed here | Lanes |
|---|---|---|
| PAYOUT-001 | create + AM2 freeze + enqueue + fee=round(amt·pct,2) + validations | L1.0–L1.1, L7 |
| PAYOUT-002 | claim + settle (AM2) + PW2 fan-out + residual + PV1-R-inert + one success cb + duplicate no-op | L1.2–L1.10, L4.9–L4.10 |
| PAYOUT-003 | release (`frozen −= gross`, balance untouched) `processing`-only | L3a, L4.8 |
| PAYOUT-004 | sweep→`review` via `mark_review`; admin reconcile success leg (=`mark_success`) / failed leg (`mark_failed_from_review`, review-only) | L3b, L4.6 |
| PAYOUT-005 | admin-cancel `pending`-only + race-guard no-op | L6.1–L6.4 |
| PAYOUT-007 | resend RPC deployed/SV8-granted (callback resend; not money-bearing — structural only) | §1 |
| PAYOUT-008 | per-age auto-cancel via shared bundle (`auto_cancelled`) | L6.7 |
| PAYOUT-009 | review auto-reconcile no-op without a matching statement (callback-silent review) | L3b.1–L3b.3 |
| PAYOUT-010 | per-bank maintenance cancel via shared bundle (`bank_maintenance`) | L6.5–L6.6 |
| PAYOUT-012 | `correction` failed→success (re-debit) + review→success (settle-from-freeze) + fail-closed | L3a, L3b, L8 |
| PAYOUT-013 | `reverse_settle` success→failed + PW1 re-credit + per-partner full-or-audit-only clawback + CB5 | L1.11–L1.19, L2 |
| SM1/SM2/SM2-SPLIT/SM3 | full legal-source matrix; illegal=no-op; CAS lock-first | L4 |
| AM2/AM5/PW2/PV1-R/CB5/LO1 | conservation, freeze/settle/release, residual, clawback, fail-close | L1, L2, L7, L8 |

## 5. Footprint (zero — verified on a fresh connection AFTER ROLLBACK)
`ts_payouts`=0 · `withdrawal_queue`=0 · `wallets_change_logs`=0 · `callback_queue`=0 · `audit_log`=447 (baseline) · 0 `dded%` seal fixtures remain (client/wallet/bank_account/mdr_profile) · `mdr_owner` balance=0.00 · real banks `77…` balance unchanged (1,000,000.00 each). The callback dispatch trigger's `net.http_post` is transactional → rolled back (net queue untouched).

## 6. The "7-enum status CHECK" note (brief vs. reality — NAMED, not a blocker)
The dispatch brief says "7-enum status CHECK". The **deployed** `ts_payouts_status_check` is a **6-value** set: `{pending, processing, success, failed, review, cancelled}` — exactly the ratified canonical SM1 state set. The "7" appears to be a miscount (most likely counting the **dropped** `claimed` state, or conflating with the 9-value `ts_payouts_failure_code_check`). **Reality matches the spec**, the enum is hard-enforced (L4.14), and no producer emits an out-of-spec status — so this is a documentation count correction, **not** a seal blocker.

## 7. NAMED items (deferred + non-blocking — none is a money/safety contradiction)

**Genuinely deferred (correctly NOT sealed over):**
- **PAYOUT-006** — cut 2026-05-17 (no scope distinct from PAYOUT-004); deliberate numbering gap.
- **PAYOUT-011** — deferred Phase-2 *automatic* `review → failed` statement-driven auto-reconcile. Not built; correctly absent (the only `review → failed` producer present is the sanctioned `mark_failed_from_review`, admin/statement-reconcile-only). The "absence never auto-fails" hard invariant (RR4) holds.
- **Step-up second-factor** — explicitly NOT gated on any payout admin action (S2 carve-out, §ADR-2 2026-06-04; current-parity — `VerifyTOTPStepUp` covered only `deposit_refund`/`deposit_refund_resolve`). The admin RPCs (`admin_correct_payout`/`admin_reverse_settle_payout`/`admin_cancel_payout`/`admin_reconcile_payout`) carry no step-up by design; gated by the §ADR-13 three-layer write invariant + canonical audit + canonical lock order. Correct, not a gap.

**Carried non-blocking notes (re-confirmed REAL + non-blocking; route to architect, not seal-blocking):**
- **NEW this seal — cancel-bundle callback payload shape divergence (L6.8).** `cancel_stale_payout` emits the `payout.cancelled` callback payload as **snake_case** `{request_id, amount, failure_code}` with **no camelCase WC envelope**, whereas `mark_success`/`mark_failed`/`admin_reverse_settle_payout` emit the §ADR-9 camelCase shape (`event`/`txnId`/`amount`/`fee`/`status`/`failureCode`/…). The failure-code **value** is present and correctly distinguishes all three paths (admin_cancelled/auto_cancelled/bank_maintenance), money is released correctly, and exactly one callback is enqueued — so the AC ("a client can tell which path cancelled") is behaviourally met. The divergence is a **wire-contract fidelity gap** (the dispatcher/serialization layer or `cancel_stale_payout` should normalize to the WC shape), **not** a money/safety contradiction. → route to next-architect / callback-delivery owner. (This is the as-built shape, GREEN in slice-3 payb3i; surfaced explicitly here as the cross-callback comparison.)
- **§8-B 3-term netting** — `mdr_clawback_fanout`'s netting subtracts `mdr_unwind_shortfall` as well as `mdr_clawback` (SPEC §4.4 says only `−Σclawback`). Single-generation-identical; a divergence would only appear across multiple distribute→claw generations on one payout — which §8-C (L5) proves is **UNREACHABLE** via the RPCs. Latent only; architect to ratify the 3-term form.
- **§8-D / failure_code CHECK** — `ts_payouts_failure_code_check` has **no** reverse code (and no `bank_maintenance`): `reverse_settle` sets the **column** `failure_code = NULL` (CHECK allows NULL) and the cancel bundle writes the code only to the callback **payload** — so no CHECK violation ever occurs. Latent taxonomy-add for the column enum; architect-routed, non-blocking.
- **DRIFT-V** — view-layer effective-status virtual-clock concern (slice-3); out of the payout-RPC money scope, architect-routed.
- **`claimed_at` / T1 wall-clock residue** — `cancel_stale_payout`/`claim` use `now()`/`completed_at` wall-clock stamps; the money branches are virtual-clock-drivable where it matters (sweeps take `p_now`); residue is timestamp-cosmetic, not money-load-bearing.

## 8. Verdict

The payout epic's whole-lifecycle money conservation, cross-story interactions, state-machine
completeness, status enum, and RLS tenant-scope are **independently behaviorally re-derived
GREEN** on qnccph at `origin/main` HEAD, zero-footprint, with the cross-boundary seal and SV8
grants intact. The named items in §7 are real and routed but contain **no money or safety
contradiction**. → **PAYOUT EPIC-SEAL ISSUED (G1 satisfied).** The §ADR-21 G2 epic-DONE still
additionally requires the **LIVE signoff** (`live_signoff` ACCEPT) — a separate later step,
behind the composed-run infra; this seal does not run or grant it.

— next-investigator (`payoutseal`), 2026-06-13. Artifact: `/tmp/falsify_payoutseal.sql` (71 assertions; 70 GREEN + 1 sentinel RED; 0 unexpected).
