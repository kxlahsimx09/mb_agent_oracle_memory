# next-tester — PAYOUT resend + statement-reconcile slice-4 probe build (campaign payb4t)

> **Role / de-bias:** Step-1 PARALLEL probe build (build-workflow.md). Probes bind **EXCLUSIVELY** to
> the broadcast SPEC contract `origin/build/payout-slice4 : docs/spec/payout-resend-reconcile-slice.md`
> (**v1, 2026-06-13**), read via `git show` — **the contract, never next-dev's `supabase/` code**
> (layer-1 de-bias, never violated; the sibling dev-1 `payb4` build worktree was NOT read). It
> **EXTENDS** slice-1 (`payout-core-lifecycle-slice.md`, money model §0 + state machine §1 +
> `mark_success` SM2-SPLIT/AM2/PW2/PV1-R — read first), slice-2 (`payout-review-cancel-slice.md`, the
> admin/audit shapes) and slice-3 (`payout-cancel-sweeps-slice.md`, the §ADR-20 clock discipline) — not
> restated. Expected behaviour is derived from the SPEC + the ratified epic/ADR text it cites
> (epic-payout PAYOUT-007/009; §ADR-9 §Amendment 2026-05-12 AM1–AM7 + §Amendment 2026-05-13 WC1–WC11;
> §ADR-13 F1–F4; §ADR-4a §Amendment 2026-05-16 RR1–RR11 + §Amendment 2026-05-18 SC1–SC8; §ADR-15 P2.16 +
> FF3; §ADR-10 AM2/PW2 + PV1-R; §ADR-20 T1/T2/T4; §ADR-11).
>
> **Status: ✅ VERIFIED GREEN on the tester stack (yupsev, 2026-06-13).** Orchestrator signalled
> stack-ready (brew-ops GREEN both stacks: migration deployed as `20260612000260` — a PR-file renumber
> 250→260 that does NOT affect the deployed substrate; `sweep_payout_reconcile` 2-arg + SV8 grant;
> `v_success_payout_audit` grace uses `app_now()`; EF `payout-resend-callback` real-gotrue gated; flag
> `payout_auto_reconcile_enabled=true`; grace=`6 hours`; ktb memo seed live). Suite ran push-button →
> **GREEN 51/51, all 5 lanes** (git_sha `93c6b8d4`, evidence
> `evidence/integration-run-payout-rr-1781331132671-93c6b8d4.json`). **The substrate was correct
> throughout** — the first run surfaced THREE probe-side fixture/transport bugs (the slice-3 pattern,
> §8), all fixed + re-run GREEN; **zero substrate fixes**. Identities/flag/clock restored in `finally`:
> flag ends `true` (ships ON), grace `6 hours`, clock reset (app_now≈real now), zero leftover probe rows.
> Offline self-check `payout-selfcheck.ts` **120/120** (78 carried + **42 new `rr_`**) gates every run;
> `bun build` graph clean (17 modules); `tsc --noEmit --strict` 0 errors across the slice-4 graph + selfcheck.
>
> **Branch / PR:** `test/payb4-probes` off `origin/main` — **PR (test-only, DO NOT MERGE)**. No
> `supabase/` code touched; harness + docs + the GREEN evidence JSON only.

---

## 0. What was built

```
tests/integration/probes/payout/         (NEW _rr modules sit alongside the merged slice-1/2/3 suites)
  _spec-rr.ts        slice-4 SPEC binding — resend EF + resend_callback RPC; match_payout_statement
                     (REUSED VERBATIM §4.2), reconcile_payout, sweep_payout_reconcile (2-arg, C-C),
                     mark_success (inherited), classify_success_payout + v_success_payout_audit (C-D),
                     flag/grace/memo readers; terminal set, in-flight statuses, resend/match/reconcile
                     outcome vocabularies, classification + reasons, RR5 50.00 tolerance, resend
                     outcome→HTTP map, AC quotes — all from §5.7 (param lists + outcome strings PINNED)
  _assert-rr.ts      NEW pure predicates (the decision core; selfcheck-validated):
                     isResendTerminal, resendInFlightGuards, resendOutcome, resendTenantAllowed [AM6],
                     singleAppend / appendNotMutate [AM4], amountWithinTolerance [RR5], reconcileOutcome,
                     neverAutoFails [RR4], flagIsOnlyDifference [RR9], graceElapsed [SC5],
                     classifyExpected [SC2/SC3 ordering], exemptReasonExpected, unconfirmedReasonExpected,
                     auditDetectionOnly [SC6], candidateSuppressedWhenFlagOff [SC8], isResendLegalSource
                     — reuses moneyEq; the probes also reuse settle/pw2/am5/expectedShare + exactlyN/
                     expectedHttpForOutcome from the slice-1/2 assert modules
  _flow-rr.ts        TRANSPORT — resend EF + resend_callback RPC; reconcile_payout / match_payout_statement
                     / sweep_payout_reconcile; classify_success_payout + v_success_payout_audit reads;
                     flag/grace/memo readers + app_settings get/set; bank_statements OUT-debit seeder;
                     bank resolve/seed-by-code; callback_queue original-row seeder + by-event_id reads +
                     callback_attempts trail; the §ADR-13 F1 3-actor bearer mint (admin/client/sub-client/
                     other-tenant/wrong-perm + forged/stub/aal1) scoped to the fixture client
  _stage-rr.ts       stageResend (terminal payout + callback_url + pre-seeded original cb row),
                     stageReconcile (review payout, freeze HELD, PAY… request_id + optional OUT debit),
                     stageAudit (success payout + source/dest bank + completed_at + optional linked debit);
                     payToken() (RR2 PAY[A-Za-z0-9_-] token)
  p007-resend.ts     PAYOUT-007 — runResendEfGate (405/401/403/400/404 + idem-exempt; NO fixture/signing
                     key) + runP007Resend (admin/client/sub happy, cross-tenant 403, terminal-only,
                     race-guard, append) — 6 + 4 assertions
  p009-reconcile.ts  PAYOUT-009 reconcile — clean-match settle+PW2+callback+statement-linked, PV1-R
                     rollback, flag-off no-op + flip-on, RR4 never-auto-fail (terminal-mismatch + no-debit),
                     amount-mismatch, idempotent/lock-first, C-C safety-net sweep window — 7 assertions
  p009-audit.ts      PAYOUT-009 audit (DETECTION-ONLY) — confirmed, exempt(intrabank SC3 / non-memo),
                     pending→unconfirmed via virtual clock (C-D), unconfirmed(amount), SC8 self-suppress,
                     SC6 zero-mutation ATTACK — 7 assertions
  readiness-rr.ts    Lane-0 slice-4 stack-readiness gate — RPCs / view / tables / EF / flag+grace+memo
                     seed / clock RPCs / pg_cron (soft) — ~25 gates (efDeployed split out for the EF gate)
tests/integration/run-payout-rr.ts        NEW runner (reset+clock → readiness → EF gate → fixture lanes;
                     5 lanes; evidence JSON; BLOCKED-ON-DEPLOY discipline)
tests/integration/payout-selfcheck.ts     EXTENDED (+42 rr_ meta-assertions; reuses slice-1/2/3 plumbing)
```

**Reuse (house style, GOAL-directed):** the merged slice-1/2/3 helpers (`_spec/_assert/_flow/_stage`
payout + rc + cs modules + `auth/_authctx` real-gotrue mint) are imported as **prior tester artifacts on
`main`** — unmodified. The `_rr` siblings **ADD** the slice-4 surface without mutating the slice-1/2/3
files (their bijections + green runs stay intact). The only edit to a prior file is the **additive**
`payout-selfcheck.ts` extension. The 3-actor bearer mint reuses the slice-2 `mintGotrueBearer`
(disk-backed bearer cache, rate-limit-robust) verbatim.

**Harness validation (offline, stack-bare):** `bun tests/integration/payout-selfcheck.ts` → **120/120**.
Every NEW predicate is proven **GREEN on a valid input AND RED on a deliberately-violated one** — the
five load-bearing safety cases the GOAL named are each an explicit `discriminates(...)` (RED-on-violation):

| GOAL safety case | predicate | RED-on-violation meta-assertion |
|---|---|---|
| **audit-mutates-state → RED** | `auditDetectionOnly` | `rr_audit_sc6_detection_only_zero_mutation` (+ rejects status-revert / wallet-move / wcl-row) |
| **review-auto-failed → RED** | `neverAutoFails` | `rr_reconcile_review_never_auto_failed` (`neverAutoFails("failed")===false`) |
| **flag-off-still-reconciles → RED** | `reconcileOutcome` / `flagIsOnlyDifference` | `rr_reconcile_flag_off_disabled_not_reconciled` |
| **cross-tenant-resend-allowed → RED** | `resendTenantAllowed` | `rr_resend_tenant_own_allowed_cross_denied` |
| **duplicate-callback-on-race → RED** | `resendOutcome` / `resendInFlightGuards` | `rr_resend_in_flight_refuses_not_duplicate` (in-flight ⇒ `already_in_flight`, never `accepted`) |

`bun build tests/integration/run-payout-rr.ts` → 17 modules, clean. `tsc --noEmit --strict
--allowImportingTsExtensions` (ambient platform shim) → **0 errors** across the slice-4 graph + selfcheck.

---

## 1. Probe → AC bijection (every SPEC AC clause has exactly one probe leg; every leg quotes its clause)

### PAYOUT-007 — manual terminal-callback resend (SPEC §1.5 + §5.7 EF gate)

| SPEC clause | probe leg | asserts |
|---|---|---|
| §5.7 EF map (405/401/403/400/404), §ADR-11 idem-exempt | `p007ef.method_405_non_post` · `p007ef.auth_401_no_forged_stub_and_stepup_aal1` · `p007ef.rbac_403_lacks_resend_perm` · `p007ef.validation_400_missing_payout_id_and_idem_exempt` · `p007ef.not_found_404` | the EF shell legs (no mint / no fixture); a no-key call reaches `missing_payout_id`, never `IDEMPOTENCY_KEY_REQUIRED` |
| §1.5 AC#1 (AM3/AM4, 202) | `p007.resend_admin_202_single_append_attempt_original_unchanged` | 202 {accepted, callback_queue_id, attempt_id, event_id}; ONE new cb row (same event_id, fresh dedup, pending) + ONE manual_resend attempt (actor=admin); original byte-unchanged; WC payload preserved |
| §1.5 AC#2 (AM6 own-tenant) | `p007.resend_client_own_tenant_202_or_rbac_seed_pending` · `p007.resend_sub_client_parent_tenant_202_or_rbac_seed_pending` | client (direct client_id) + sub-client (parent client_id) → 202, `triggered_by_type` = client/sub-client (a non-cross-tenant 403 = RBAC-grant SEED-PENDING, surfaced — see §4) |
| §1.5 AC#3 (AM6 cross-tenant) | `p007.resend_cross_tenant_403_no_row_written` | other-tenant actor → **403**, NO callback_queue / callback_attempts row written; a 202 here (cross-tenant resend succeeding) is the load-bearing security FAILURE → RED |
| §1.5 AC#4 / §1.3 #1 (AM5 terminal-only) | `p007.resend_terminal_only_three_accepted_nonterminal_409` | all three {success,failed,cancelled} → 202; review/pending/processing → 409 `payout_not_terminal` (carries status), no row |
| §1.5 AC#5 / §1.3 #4 (AM5 race-guard) | `p007.resend_race_guard_in_flight_409_dead_letter_recovers` | in-flight {pending,dispatching} original → 409 `CALLBACK_ALREADY_IN_FLIGHT`, no 2nd row; dead_letter original → 202 (recovers) |
| §1.5 AC#6 (AM4 append) | `p007.resend_append_n_plus_one_rows_one_event_id_distinct_dedup` | N resends → N+1 rows, ONE event_id, N+1 distinct dedup_keys, original unchanged |

### PAYOUT-009 — statement-driven reconcile (SPEC §2.4)

| SPEC clause | probe leg | asserts |
|---|---|---|
| §2.4 AC#1 (RR1/RR3 clean match) | `p009r.reconcile_clean_match_success_settle_pw2_callback_statement_linked` | `reconciled`; status→success; settle (balance ∧ frozen −= gross, one payout_settle); PW2 (one row/partner + residual→mdr_owner, conservation); EXACTLY ONE payout.success; statement matched + matched_payout_id + matched_link_step=payout_reconcile; AM5 |
| §2.4 AC#2 (PV1-R) | `p009r.reconcile_pv1r_over_allocated_rolls_back_stays_review_no_callback` | over-allocated profile ⇒ whole settle rolls back; stays review; freeze intact; no settle/callback (inherited fail-close) |
| §2.4 AC#3 (RR9 flag) | `p009r.reconcile_flag_off_disabled_noop_flag_on_reconciles` | flag OFF ⇒ `disabled`, stays review, no move/callback; flip ON + re-run ⇒ `reconciled` (flag is the only difference) |
| §2.4 AC#4 (RR4 never-auto-fail) | `p009r.reconcile_rr4_never_auto_fail_terminal_mismatch_and_no_debit` | debit vs failed/cancelled payout ⇒ `anomaly_terminal_mismatch`, no revert/move/callback; a review payout with NO debit stays review, NEVER failed |
| §2.4 AC#5 (RR5 amount) | `p009r.reconcile_amount_mismatch_over_tolerance_stays_review` | amount over 50.00 ⇒ `amount_mismatch`; statement → review; payout stays review; no settle |
| §2.4 AC#6 (RR6 idempotent) | `p009r.reconcile_idempotent_already_success_no_second_settle_or_callback` | re-run on an already-success payout ⇒ `already_success`; settle count stays 1, callback count stays 1 |
| §2.4 AC#7 (C-C clock) | `p009r.reconcile_safety_net_sweep_window_virtual_clock_drivable` | `sweep_payout_reconcile(p_now)` look-back window is p_now-driven (in-window reconciles; out-of-window skipped at 1h, evaluated at 3h) |

### PAYOUT-009 — success-confirmation audit (SPEC §3.5, DETECTION-ONLY)

| SPEC clause | probe leg | asserts |
|---|---|---|
| §3.5 AC#1 (SC2) | `p009a.audit_confirmed_interbank_memo_linked_debit` | interbank + memo (ktb) + linked debit within tol → `confirmed`; never alerted |
| §3.5 AC#2 (SC3 ordering) | `p009a.audit_exempt_intrabank_wins_before_no_debit_test` | source code = dest code → `exempt` (intrabank) EVEN with no debit (intra-bank predicate consulted first) |
| §3.5 AC#3 (SC4) | `p009a.audit_exempt_non_memo_bearing_source` | non-ktb (fail-safe non-memo) source → `exempt` (non_memo_bearing_source_bank) |
| §3.5 AC#4 (SC5 / C-D) | `p009a.audit_pending_to_unconfirmed_via_virtual_clock_C_D` | interbank+memo, no debit → `pending` inside grace, flips `unconfirmed` (no_confirming_debit) after clock_advance past `payout_audit_grace_window` — no real wait |
| §3.5 AC#5 | `p009a.audit_unconfirmed_amount_mismatch_regardless_of_grace` | linked debit over 50.00 → `unconfirmed` (amount_mismatch), regardless of grace |
| §3.5 AC#6 (SC8) | `p009a.audit_sc8_flag_off_audit_disabled_candidate_set_empty` | flag OFF ⇒ every success `audit_disabled` → candidate set EMPTY (storm impossible) |
| §3.5 AC#7 (SC6 attack) | `p009a.audit_sc6_detection_only_zero_mutation_attack` | classifying + clock_advancing to flip `unconfirmed` mutates ZERO status / wallet / wcl / callback; success-population count + balances + callback count byte-identical |

---

## 2. §stack-needs — readiness-rr delta (✅ SATISFIED on yupsev 2026-06-13; all 25 Lane-0 gates GREEN)

The runner's **Lane-0 readiness-rr gate** is the contract for "DEPLOYED, not merely provisioned". A RED
here is a **DEPLOY blocker**, not evidence against the build. On yupsev **every gate is GREEN** (the list
below is the deploy contract, now all met); kept here as the readiness manifest for the second stack /
re-deploys:

1. **Tables** (R1): `bank_statements`, `bank_capabilities`, `callback_attempts`, `app_settings`,
   `callback_queue`, `bank_account` present (+ the slice-1 base tables via the shared readiness).
2. **PAYOUT-007 resend** (R2): RPC `resend_callback(text,uuid,uuid,text,text)` present; **EF
   `payout-resend-callback` deployed** (a non-404 response — the C-B comment-only fix rides this EF).
3. **PAYOUT-009 reconcile** (R3): `match_payout_statement(uuid)` (**REUSED VERBATIM §4.2**),
   `reconcile_payout(uuid)`, **`sweep_payout_reconcile(interval,timestamptz)` — the 2-arg form; the
   1-arg overload DROPPED** (C-C), `mark_success(uuid,text)` (inherited).
4. **PAYOUT-009 audit** (R4): `classify_success_payout(uuid)` + **VIEW `v_success_payout_audit`**
   (the §5.7 column list; C-D grace predicate `app_now()−completed_at>grace`).
5. **Flag/grace/capability readers** (R5): `_payout_auto_reconcile_enabled()`,
   `_payout_audit_grace_window()`, `_payout_memo_carries_request_id(text)`.
6. **§ADR-20 clock RPCs** (R6): `app_now`/`clock_set`/`clock_advance`/`clock_reset`/`reset_for_test`.
7. **Config seed** (R7, soft): `app_settings.payout_auto_reconcile_enabled` ships `'true'` (ON) +
   `payout_audit_grace_window` ships `'6 hours'` (**NOT** `payout_confirm_grace_minutes` — §0/§7);
   `bank_capabilities` has the **ktb** memo-bearing row (verified via
   `_payout_memo_carries_request_id('ktb')===true`, `'scb'===false`).
8. **pg_cron** (R8, soft): `sweep-payout-reconcile` (the zero-arg cron re-resolves to the new 2-arg fn).
9. **Harness env**: the tester slot must carry `GATEWAY_ASSERTION_SIGNING_KEY` + `GATEWAY_ASSERTION_KID`
   (scope=payout GW4 keypair) for the **create staging** the fixture lanes need (a slice-1 dependency).
   **Without it the fixture lanes are BLOCKED-ON-DEPLOY** — but the EF gate (405/401/403/400/404) still
   runs, since it needs only the EF + minted bearers, no signing key.
10. **Fixture seed** (shared, slice-1 readiness): an `enable_payout` client with a real `merchant_id`
    (the `_callback_queue_autofill` BEFORE-INSERT trigger resolves merchant_id from the client and fills
    dedup_key — a fixture client lacking it fails the callback seed; surfaced, not a silent pass), a
    client wallet, an MDR profile (+ partners) for PW2, an `mdr_owner` residual wallet, and ≥1
    `bank_account` (a **ktb**-coded bank for the memo-bearing/interbank audit cases — readiness-rr best-
    effort seeds it but a NOT-NULL FK the seed can't fill surfaces as a BLOCKED leg).
11. **RBAC grant** (SEED, see §4): the role→perm map must grant `payout:resend-callback` to the client /
    sub-client tiers (and super_admin) — else the own-tenant happy legs surface a non-cross-tenant 403
    (recorded SEED-PENDING, not a contract fail).

---

## 3. Defensive (not-§5.7-pinned) bindings — read defensively, surfaced, never silently invented

§5.7 PINS the EF/RPC param lists + outcome strings + the v_success_payout_audit column list, so there are
**no [SPEC-PENDING] outcome/param guesses** this slice. The defensive bindings are carried-substrate
column spellings (`SPEC_RR_PENDING_BINDINGS` in `_spec-rr.ts`):

1. **bank_statements columns** (direction / description / amount / match_status / transaction_code /
   matched_payout_id / matched_link_step / created_at) — carried substrate, **matcher-owned (§4.2
   DO-NOT-MODIFY)**; named in the SPEC narrative but not the §5.7 param block. Read defensively;
   readiness-rr gates the table.
2. **callback_queue.event_id + .dedup_key** spelling (§1.4) — the append asserts SAME event_id + a fresh
   DISTINCT dedup_key; bound conventionally, read defensively (select=* fallback).
3. **callback_attempts** table + actor-triple column spelling (triggered_by / _id / _username / _type,
   §1.4 / §ADR-13 F2) — bound conventionally; the attempt assertion reads select=* and matches by name.
4. **bank_capabilities** shape — the memo capability is read through
   `_payout_memo_carries_request_id(bank_code)` (fail-safe false; KTB-only seed), NOT the table's columns
   directly (spelling unpinned), so `source_memo_bearing` binds to the function's verdict.
5. **`_callback_queue_autofill` BEFORE-INSERT trigger** — seeding a resend ORIGINAL callback row fires it
   (fills dedup_key + resolves merchant_id); the seed reads back the row to confirm what took.

---

## 4. RBAC-grant SEED-PENDING (PAYOUT-007 own-tenant client/sub-client legs)

SPEC §1.2: all three tiers carry **the same** flat perm `payout:resend-callback` (no actor-tier prefix —
§ADR-13 F3); tier separation is route + `user_type` + tenant scope. The EF checks RBAC **before** tenant
scope. So:
- The own-tenant **client/sub-client happy legs** require the role→perm grant (client tier ⊇
  `payout:resend-callback`) to reach a 202. If that grant is missing on the stack, the leg returns a
  **403 that is NOT `cross_tenant_access_denied`** — recorded as **SEED-PENDING** (the probe passes on
  `clean 202 append` OR `403-non-cross-tenant`, and the detail says which). This is a **stack seed**
  concern (parallel to slice-2's `payout:approve`/`payout:cancel` grant seed), not a contract fail.
- The **cross-tenant leg** is robust regardless of the grant: it asserts **403 + NO row written**; a
  cross-tenant resend that **succeeds (202)** is the load-bearing security failure → RED. (Whether the
  403 is the clean `cross_tenant_access_denied` or the RBAC-seed variant is recorded in the detail.)

The actor-role names used by the mint (`client`→role `client_admin`, `sub-client`→`client_admin`,
wrong-perm→`partner`/`partner_user`) are a binding I cannot read from the de-biased SPEC; if the deployed
grant map keys on different role names, the own-tenant legs surface SEED-PENDING and the exact roles are a
coordination item via the orchestrator.

---

## 5. §contract-cross-check — `match_payout_statement` REUSED VERBATIM (§4.2), NOT changed

Per the GOAL + SPEC §4.2 (the cross-boundary lock that drove the bank-bot epic-seal GREEN): the reconcile
probes **CALL** `match_payout_statement` / `reconcile_payout` / `sweep_payout_reconcile` and assert the
SPEC's **STATED** outcomes (`reconciled` / `amount_mismatch` / `anomaly_terminal_mismatch` /
`already_success` / `disabled` / …). **No probe requires any change to the matcher's semantics.** The
clock fixes this slice (C-C in the *caller* sweep, C-D in the *read-side* audit view) do not touch the
matcher. **No contract question arose** — every reconcile AC is expressible against the matcher as-is. If
a future probe is ever found to pass only by changing the matcher, that will be surfaced here and to the
orchestrator (NOT bound to a changed matcher). Nothing to escalate at this time.

---

## 6. Carried / non-blocking observations (NOT in-scope to fix; routed where the SPEC routes them)

- **Grace-knob name divergence (SPEC §0/§7 → next-writer/architect):** the requirements doc names the
  knob `payout_confirm_grace_minutes` (minutes); the deployed substrate is **`payout_audit_grace_window`**
  (interval, 6h). Probes bind ONLY the substrate name; `payout_confirm_grace_minutes` is **never probed**
  (it does not exist in the DB). Already routed by the SPEC — no action.
- **SV8 latent exposure (SPEC §7 → next-architect / next SV8 sweep):** the pre-SV8 reconcile/audit fns
  (`_payout_auto_reconcile_enabled`, `reconcile_payout`, `classify_success_payout`, etc.) carry the
  default PUBLIC EXECUTE; this slice ships ONLY the new `sweep_payout_reconcile` with the SV8 tight grant.
  Out of this probe slice; not asserted.
- **DRIFT-V (SPEC §7):** the `v_payouts`/`v_payouts_read`/`v_deposits` `effective_status` 0-lag
  view-clock residue — carried, architect-owned. Out of slice.
- **P2.16 Keep-side delivery (SPEC §3.4):** out of scope — the probes assert ONLY the candidate-row/flag
  the gateway emits (the VIEW `WHERE classification='unconfirmed'`, deterministic + idempotent, stable
  `payout_id` dedup discriminator), NOT the Keep `firingCounter==1` router / bucketed dedup.

---

## 7. How to run (push-button once stack-ready)

```bash
set -a; source .secrets/slots/tester.env; set +a
bun tests/integration/payout-selfcheck.ts        # offline harness validation (120/120) — gates every run
bun tests/integration/run-payout-rr.ts           # emits evidence/integration-run-payout-rr-<RUN_ID>.json
```

Lanes: `lane0-readiness` · `lane1-resend-efgate` (EF deployed + bearers; no signing key) ·
`lane2-resend` · `lane3-reconcile` · `lane4-audit` (the last three need the signing key for create
staging). A bare/undeployed stack → **BLOCKED-ON-DEPLOY**, non-zero exit, **never green**.

---

## 8. Probe-side fixes the VERIFY run surfaced (substrate was correct throughout — zero substrate fixes)

The first live run was RED 41/51; the substrate behaved correctly on every leg — the REDs were THREE
probe-side fixture/transport bugs (exactly the slice-3 "first run surfaced one staging RED" pattern).
All fixed in the harness only, re-run → **GREEN 51/51**. Reported, never substrate-fixed:

1. **`bank_statements` seed was missing four NOT-NULL columns** (`system_bank_id`, `account_number`,
   `bank_code`, `transaction_date_bkk` — verified over the wire via the `23502` insert errors, a
   ground-truth schema read, NOT dev source). The incomplete INSERT silently 400'd → no statement seeded
   → the matcher returned `no_statement_yet`/no-linkage on every reconcile + the two debit-bearing audit
   legs. Fix: `seedOutDebit` now fills all four (the stage helpers pass the fixture/source bank's id +
   code). *(These spellings are added to `SPEC_RR_PENDING_BINDINGS` as discovered-defensive.)*
2. **`resendEf` 405 leg sent a body on a `GET`** → `fetch` throws (GET/HEAD cannot carry a body) →
   `http=0` instead of 405. Fix: attach the body only for body-bearing methods.
3. **Cross-tenant actor needed a REAL second client + a fresh cache key.** A synthetic `client_id` dies
   at auth with `401 unknown_user` *before* the tenant-scope check, so the leg never reached the clean
   `403 cross_tenant_access_denied`. Fix: resolve a real second `enable_payout` client (≠ the fixture
   owner) for the otherClient actor. The disk-backed bearer cache (keyed on `user_type:sub`, not tenant)
   also returned the first run's stale synthetic-tenant bearer → the otherClient identity was given a
   fresh `sub` so its cache key never collides. *(Carried gotcha: re-running after CHANGING an actor's
   tenant needs a fresh sub or a bearer-cache clear — benign for a stable suite.)*

A fourth assertion was a **predicate-misuse RED, not a substrate or fixture issue**: the RR4
terminal-mismatch sub-leg wrongly applied `neverAutoFails` to a *legitimately* `failed` payout (which
correctly returns false). The "never-auto-fail" invariant governs a *review* payout never being driven TO
failed (the absence-of-debit sub-leg, which uses it correctly); the terminal-mismatch leg's invariant is
NO REVERT (stays failed), already checked by `status === failed`. Removed the misapplied call.

**De-bias note:** the only "code reads" performed to fix these were **ground-truth schema/row reads over
PostgREST** (the deployed `bank_statements` column shape, the `client` table) — never `supabase/` source
and never the dev build branch. Expected behaviour stayed bound to the SPEC.
