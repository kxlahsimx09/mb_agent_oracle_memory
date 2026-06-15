# next-investigator — PAYOUT slice-4 Step-2 FALSIFICATION (campaign payb4i)

> **Role / method (build-workflow Step-2):** I do **not** trust the SPEC, the tester (51/51 yupsev), or the
> dev (37/37 dev-1). I re-derive every PAYOUT-007 / PAYOUT-009 behaviour + money invariant from the **deployed
> substrate ground truth on the SEAL STACK qnccph** (real `pg_get_functiondef` bodies + table constraints +
> the deployed EF source on `origin/build/payout-slice4`), drive the **real deployed RPCs / view / EF** with
> **my own fixtures** + my own recomputed expectations, and **attack every PASS**. Zero-footprint:
> one `BEGIN…ROLLBACK` (`/tmp/falsify_payb4i.sql`), own clients/wallets/profiles/payouts (the 3 real banks
> `77…` read-only; shared `mdr_owner` wallet asserted by delta), virtual clock driven BOTH ways
> (`clock_set`/`clock_advance` + explicit `p_now`), flag/clock restored, footprint verified 0.
>
> **Verdict: ✅ GREEN — slice-4 falsification PASS.** 68/68 independent re-derivations reconcile with qnccph
> ground truth **+ 1 deliberate teeth-sentinel correctly RED** (harness is non-vacuous), **0 unexpected
> failures**. The substrate is correct; the SPEC's C-A..C-D claims and the tester's 51/51 are corroborated by
> independent re-derivation on a *different stack* (qnccph) — **not inherited**.
>
> **Under test:** dev PR **#472** (`origin/build/payout-slice4`) + the payb4t probe PR. **Seal stack:** qnccph
> (`qnccphgykzdydebmdwdf`, `stack_role=test`). next-code-reviewer reviews #472 + the probe PR in parallel (payb4r).

---

## 0. Substrate ground truth re-confirmed (the C-A..C-D deltas, from qnccph not the findings)

| Claim | Ground-truth check on qnccph | Verdict |
|---|---|---|
| Migration HEAD | `20260612000260_payout009_reconcile_clock_grace` is the latest `schema_migrations` row (after `…000240 sv8_revoke_payout_fns` + `…000250 adr10_rm_residual_backfill`). | ✓ |
| Flag ships ON | `app_settings.payout_auto_reconcile_enabled = 'true'`; `_payout_auto_reconcile_enabled()` fail-closed (`lower(value)='true'`). | ✓ |
| Grace | `payout_audit_grace_window = '6 hours'`; `_payout_audit_grace_window()` → `06:00:00`, fail-safe 6h. `payout_confirm_grace_minutes` **does not exist** in `app_settings` (requirements-name divergence confirmed — probe the substrate name only). | ✓ |
| ktb memo seed | `_payout_memo_carries_request_id('ktb')=t`, `('scb')=f`; `bank_capabilities` holds only the `ktb` row. | ✓ |
| **C-A** resend race-guard | `resend_callback` body: payout terminal set `v_status IN ('success','failed','cancelled')`; in-flight guard `status IN ('pending','dispatching')`; terminals `{delivered,dead_letter}` do **not** guard. The shared generic RPC carries the mirrored guard — **not a payout-side drift.** | ✓ |
| **C-B** EF comment | EF `payout-resend-callback` deployed + real-gotrue gated (live: forged bearer → `401 invalid_token`, no stub fallback). Behaviour == source; the C-B change was comment-only. | ✓ |
| **C-C** sweep clock + grant | `sweep_payout_reconcile` has **only** the 2-arg overload `(interval, timestamptz)` (1-arg DROPPED); body `v_now := COALESCE(p_now, app_now())`, predicate `created_at > v_now - p_lookback`; flag-gate first; per-row `EXCEPTION…CONTINUE`. **SV8 grant:** `proacl = postgres,service_role` only (no PUBLIC/anon/authenticated). | ✓ |
| **C-D** view grace | `v_success_payout_audit.audit_due = p.completed_at IS NOT NULL AND (app_now() - p.completed_at) > cfg.grace_window`. Column list/order **exactly** matches §5.7 (18 cols). | ✓ |
| §4.2 lock — matcher | `match_payout_statement` last defined in `20260520000007_adr4b_fee_row_intake` (FC3); **no slice-4 migration redefines it.** Migration `…0260` does only: `DROP sweep(interval)` · `CREATE sweep(interval,timestamptz)` · `REVOKE/GRANT` · `CREATE OR REPLACE VIEW`. | ✓ unmodified |
| §4.1 — settle | `mark_success` last defined in `20260612000110_payout002_mark_success_pw2_fanout` (slice-1 PW2); not touched by `…0260`. | ✓ inherited |

**No cross-boundary STOP needed:** nothing in my re-derivation required changing `match_payout_statement` or
`mark_success` semantics. The bbot epic-seal + slice-1 seal are untouched.

---

## 1. PAYOUT-007 — manual terminal-callback resend (RPC + EF)

### RPC `resend_callback` (the terminal/race/append engine) — 22 checks GREEN

| AC / invariant | Re-derivation on qnccph (own fixtures) | Result |
|---|---|---|
| §1.5#1 AM3/AM4 admin happy | admin resends a `success` payout → `accepted`; **exactly one** new `callback_queue` row (SAME `event_id`, fresh dedup `<orig>:resend:<unix_ms>`, `status='pending'`, event+payload preserved); **one** `callback_attempts` (`triggered_by='manual_resend'`, actor triple = admin); the **original row byte-identical** (status/dedup/event_id/event). | ✓ |
| §1.5#4 / §1.3#1 AM5 terminal-only | `{success,failed,cancelled}` all → `accepted`; `review`/`pending`/`processing` → `not_terminal` (carries `status`) **and no row written** (count unchanged). | ✓ |
| §1.5#5 / §1.3#4 AM5 race-guard | in-flight original `pending` → `already_in_flight`, **no 2nd row**; `dispatching` → `already_in_flight`, no 2nd row; `dead_letter` → `accepted` (+1, recovers); `delivered` → `accepted` (+1). | ✓ |
| §1.3#2/#3 | empty `callback_url` → `no_callback_url`; no original row → `no_callback_queued`; unknown id → `not_found`; bad type → `invalid_source_type`. | ✓ |
| §1.5#6 AM4 append | 3 resends (dispatcher delivering each between) → **N+1 = 4** rows, **ONE** `event_id`, **4 distinct** dedup_keys, original (`dk:AP`) byte-identical. | ✓ |

> **Subtle, surfaced (NOT a defect):** the AM4 "N resends → N+1 rows" AC is only reachable when the dispatcher
> moves each intermediate `pending` row to a terminal state before the next resend — because the in-flight
> guard (AM5, "one in-flight per `event_id`") refuses a resend while the prior resend's row is still
> `pending`/`dispatching`. This is the **correct** consequence of the guard, not a bug; the AC is idealised
> (assumes the dispatcher runs between resends). Worth a doc note so the AC isn't read as "spam N instantly".

### EF `payout-resend-callback` — auth shell + AM6 tenant scope

**The RPC has NO tenant gate** (confirmed from its body — it only records the actor triple). Therefore the EF
**is** the sole tenant gate, and AM6 is an app-layer property. Verified three ways from ground truth:

1. **Live gate (deployed EF on qnccph):** `GET → 405 method_not_allowed`; POST no bearer → `401
   missing_bearer_token`; forged bearer → `401 invalid_token`; anon-key bearer → `401 invalid_token`
   (real-gotrue active, aal2 strictly required, **no stub fallback**).
2. **EF source (deployed, `origin/build/payout-slice4`):** for `actor.user_type !== 'admin'` it reads
   `ts_payouts.client_id`, computes `tenantScopeVerdict(actor, resourceClientId)`, and on `deny` returns
   `403 {error:'forbidden', detail:'cross_tenant_access_denied'}` **before calling `resend_callback`** — so a
   cross-tenant denial **writes no `callback_queue`/`callback_attempts` row** (the RPC is the only writer).
   admin **bypasses** the block entirely.
3. **`rbac.ts` (deployed):** `tenantScopeVerdict` → admin `allow`; else `allow` iff
   `resourceClientId === effective_client_id`, else `deny`. `effectiveClientId` → client uses `client_id`,
   **sub-client uses `parent_client_id`** (matches §1.2). RBAC: `payout:resend-callback` is granted to
   `client_admin` / `client_viewer` / `super_admin` on qnccph (the own-tenant happy legs are NOT RBAC-seed-blocked here).

The full **3-actor + cross-tenant-403** legs require minted aal2 bearers (`auth.users=2` on qnccph but a true
app-layer 403 needs a fully-provisioned 2nd-client identity + the gotrue mint — the tester's yupsev lane). I
did **not** mint (it commits non-transactional gotrue rows = footprint) — the AM6 check is verified
conclusively by (RPC-has-no-gate) ∧ (EF denies-before-RPC) ∧ (verdict semantics) ∧ (live auth gate). The
tester's minted-bearer 403 is **corroborated, not inherited.**

---

## 2. PAYOUT-009 — statement-driven `review → success` reconcile (15 checks GREEN)

| AC | Re-derivation (own fixtures, real RPCs) | Result |
|---|---|---|
| §2.4#1 clean match → success | `reconcile_payout` → `reconciled`; `ts_payouts.status='success'`; **AM2 settle** balance & frozen each −1020 (5000/1020 → 3980/0), **exactly one** `payout_settle`; **PW2** one `mdr_distribute(+10)` to partner + one `mdr_residual(+10)` to `mdr_owner` — **conservation EXACT** 1000(payee)+10+10=1020; **exactly one** `payout.success` callback; statement `matched` + `matched_payout_id` + `matched_link_step='payout_reconcile'`. | ✓ |
| §2.4#2 PV1-R inheritance | over-allocated profile (partner 5% ⇒ Σ share 50 > fee 20 ⇒ residual −30) → `mark_success` **RAISES `mdr_over_allocated` (P0001)**, whole settle rolls back: payout STAYS `review`, wallet unchanged (5000/1020), **no callback, no settle**. | ✓ |
| §2.4#3 RR9 flag | flag OFF → `disabled`, stays `review`, no wallet move, no callback; flip ON + re-run → `reconciled`/`success` (**flag is the only difference**). | ✓ |
| §2.4#4 RR4 never-auto-fail **(both legs)** | (a) OUT debit vs a **`failed`** payout → `anomaly_terminal_mismatch`; statement→`review`; payout STAYS `failed` (no revert), queue stays `failed`, **no move, no callback**. (b) `review` payout, **no** debit → `no_statement_yet`; STAYS `review`, **never `failed`**. | ✓ |
| §2.4#5 RR5 tolerance | diff 100 (>50) → `amount_mismatch`, statement→`review`, payout stays `review`, no settle. **Boundary attack:** diff **exactly 50.00** → within tol → `reconciled`/`success`; diff **50.01** → `amount_mismatch`. | ✓ |
| §2.4#6 RR6 idempotent/lock-first | reconcile once (1 callback, 1 settle), then a 2nd matching statement on the now-`success` payout → `already_success`; callback stays 1, settle stays 1, payout stays `success`, 2nd statement `matched`. | ✓ |
| §2.4#7 C-C safety-net clock | `sweep_payout_reconcile(p_now)` window is **p_now-relative**: a debit 2h before `p_now` is **excluded at `p_lookback='1 hour'`** (statement stays `pending`, payout stays `review`) and **included at `'3 hours'`** (→ `reconciled`, `success`, `matched`). Virtual-clock drivable; no real wait. | ✓ |

The success leg lands on the **inherited `mark_success`** verbatim (SM2-SPLIT accepts `review`, AM2, PW2,
PV1-R fail-close, exactly-one callback) — proven identical to the bot/admin path.

---

## 3. PAYOUT-009 — success-confirmation audit (DETECTION-ONLY) (16 checks GREEN)

| AC | Re-derivation via `classify_success_payout` + `v_success_payout_audit` | Result |
|---|---|---|
| §3.5#1 SC2 confirmed | interbank (ktb→scb) + memo-bearing + linked OUT debit within tol → `confirmed`. | ✓ |
| §3.5#2 SC3 intrabank exempt | source code = dest code (ktb/ktb) → `exempt` (`exempt_reason='intrabank'`) **even with no debit** — and **STILL `exempt` after the grace elapses** (intrabank predicate consulted before `audit_due`). | ✓ |
| §3.5#3 SC4 non-memo exempt | non-ktb source (scb, fail-safe non-memo) → `exempt` (`exempt_reason='non_memo_bearing_source_bank'`). | ✓ |
| §3.5#4 SC5/C-D grace flip | interbank (ktb→kbank) + memo + no debit → `pending` inside grace; after `clock_advance(_payout_audit_grace_window()+1 min)` → `unconfirmed` (`unconfirmed_reason='no_confirming_debit'`) — **virtual-clock, no real wait** (proves C-D). | ✓ |
| §3.5#5 amount-mismatch | interbank + memo + linked debit over 50 tol → `unconfirmed` (`unconfirmed_reason='amount_mismatch'`), **regardless of grace**. | ✓ |
| §3.5#6 SC8 self-suppress | flag OFF → A4 classifies `audit_disabled`; **GLOBAL** `WHERE classification='unconfirmed'` candidate set = **0** (storm structurally impossible). Restored ON. | ✓ |
| §3.5#7 **SC6 detection-only ATTACK** | after classifying all 5 + `clock_advance` to flip A4 `unconfirmed`: **success-population count, `callback_queue` count, `wallets_change_logs` count, the audit payouts' statuses, and wallet balances are ALL byte-identical** before/after. Built to FAIL on any status-revert / wallet-move / wcl-row / callback — **it passed.** | ✓ |

**SC6 is the load-bearing invariant** (a falsely-`success` payout is surfaced for a human, never auto-reverted
— absence of a debit cannot positively prove the transfer didn't happen). The audit is a pure read-side SQL
view + a `STABLE` wrapper; my falsifier confirms it mutates **nothing**.

---

## 4. Teeth + zero-footprint

- **68/68 PASS + 1 deliberate teeth-sentinel RED** (asserted `classify=unconfirmed` against a payout that is
  truly `exempt`; the harness flagged it FAIL → checks are non-vacuous), **0 unexpected REDs**. One
  `BEGIN…ROLLBACK`. Result matrix + tally in `/tmp/falsify_payb4i.out`.
- Virtual clock driven **both** ways: explicit `p_now` to `sweep_payout_reconcile` (RC7) and
  `clock_set`/`clock_advance` for the audit grace flip (A4).
- **Footprint = 0 post-rollback:** `ts_payouts`/`callback_queue`/`bank_statements`/`wallets_change_logs` all
  back to `0`, `mdr_profile` back to `3`; flag restored `true`; `sys_clock` back to `real` mode
  (`app_now()≈now()`). The `tr_dispatch_callback_on_insert` / `tr_fair_router_on_insert` net.http_post
  triggers are transactional → rolled back. Nothing committed to qnccph.

## 5. Tester's 3 first-run REDs re-confirmed PROBE-SIDE (substrate correct throughout)

The tester's first run was 41/51; all three REDs were probe-side (zero substrate fixes). Re-confirmed from MY ground truth:

1. **`bank_statements` seed missing 4 NOT-NULL cols.** I independently confirm `system_bank_id`,
   `account_number`, `bank_code`, `transaction_date_bkk` are `NOT NULL` (information_schema) — a seed omitting
   them `23502`-fails → no statement → matcher returns no-linkage. **Probe bug; my fixtures fill all four and
   the matcher reconciles.**
2. **`resendEf` 405 leg sent a body on `GET`** (fetch cannot carry a GET body). Transport bug; my live `GET`
   (no body) returns a clean `405 method_not_allowed`.
3. **Cross-tenant synthetic client died at auth (`401`) before the tenant check.** Confirmed by the EF's
   `adminAuth` doing a **C4 DB-fresh `app_user` lookup** — a non-provisioned `client_id` fails auth before
   `tenantScopeVerdict` is ever reached; a real, provisioned 2nd client is required to exercise the clean
   `403 cross_tenant_access_denied`. **Probe-fixture concern; substrate correct.**

## 6. Named, NOT sealed over (boundary / routed — NOT blockers)

1. **SV8 §7.2 routed note is ALREADY-RESOLVED on the seal stack (correction).** The SPEC/dev §7.2 route a
   "latent default PUBLIC EXECUTE" on the pre-SV8 reconcile/audit fns (`reconcile_payout`,
   `classify_success_payout`, `match_payout_statement`, `_payout_*` helpers). On qnccph their **`proacl` is
   `postgres,service_role` only** — PUBLIC/anon/authenticated already revoked by the **blanket sweep
   `20260612000020_sv8_function_execute_revoke`** (it loops over every app-owned `pg_proc` and REVOKEs from
   PUBLIC/anon/authenticated). So the routed exposure is **closed** on the deployed substrate; the note reads
   stale. **NB:** this also locks `match_payout_statement`'s grants (despite §4.2 "deliberately untouched") —
   but a GRANT revoke is **not** a body/behaviour change, the EF/cron reach it via `service_role`, so the bbot
   seal is **not** re-opened. → next-architect: verify + close the §7.2 routed item.
2. **Grace-knob name divergence** — `payout_confirm_grace_minutes` (requirements) is absent from the DB;
   deployed key is `payout_audit_grace_window='6 hours'`. Reconcile the spec layer to the substrate name.
   → next-writer/architect (already routed; confirmed).
3. **DRIFT-V** (`v_payouts`/`v_payouts_read`/`v_deposits` `effective_status` 0-lag view-clock residue) — out
   of slice, architect-routed; not probed.
4. **Genuine-concurrency** races (resend in-flight, RR6 lock-first) verified via deterministic ordering + CAS
   code-confirm — a true 2-session commit would break zero-footprint (same posture as slices 1–3).

## 7. Scope

**OUT OF SCOPE (untouched):** fixing · merging · marking · epic-seal (slice-level only — the payout epic-seal
awaits all slices) · sinuw / dev-1 / tester-stack / livegate / authfull. The `match_payout_statement` +
`mark_success` cross-boundary lock held (no STOP triggered). next-code-reviewer reviews #472 + the probe PR in
parallel (campaign payb4r).

---
*Falsification artifact: `/tmp/falsify_payb4i.sql` (+ `/tmp/falsify_payb4i.out`). Seal stack qnccph via
investigator.env DB pw, IPv4 session pooler `postgres.qnccphgykzdydebmdwdf@aws-1-ap-southeast-1.pooler.supabase.com:5432`.*
