# next-investigator — PAYOUT slice-2 Step-2 FALSIFICATION (campaign payb2i)

> **Role / posture:** build-workflow **Step-2 falsification**. I do **not** inherit next-tester's
> 46/46 GREEN. I independently **re-derived** every PAYOUT-004/005 money invariant from the
> **contract** (SPEC v2 + slice-1 money model + the ratified ADR/epic text it cites), drove the
> **real deployed RPCs/EFs** on **my own seal stack (qnccph)** with **my own fixtures + my own
> independently-computed expectations**, and tried to **falsify every PASS**. Every money scenario ran
> inside one `BEGIN … ROLLBACK` (zero-footprint); zero-footprint was independently verified after the run.
>
> **VERDICT: ✅ GREEN — slice-2 falsification PASS.** 65/65 independent re-derivations reconcile with
> qnccph ground truth (+ 1 deliberate teeth-sentinel correctly RED, proving the checks are not vacuous);
> the EF auth gate is live (401, not 404) on both EFs on qnccph. The tester's **46/46 is corroborated by
> independent re-derivation on a different stack (qnccph), not inherited.** All 4 of the tester's
> probe-side fixes (§7) are re-confirmed from **my** ground truth. **No money-spine contradiction found.**

- **Stack (my seal env):** `qnccphgykzdydebmdwdf` (investigator.env slot), driven as `postgres` over the
  IPv4 session pooler. Slice-2 substrate verified live: migrations `…000130` + `…000140` applied; RPC
  signatures present; knob `payout_stuck_review_minutes=5`; cron `sweep-stale-claims` → `sweep_stale_claims(500)`;
  EFs `admin-payout-cancel` + `admin-payout-reconcile` respond (401, not 404).
- **Slice under test:** PAYOUT-004 (D6 sweep → review + admin-reconcile) + PAYOUT-005 (admin-cancel) — PRs #449 (+ tester #451).
- **Inputs READ (never trusted as substitute):** SPEC v2 `origin/build/payout-slice2:docs/spec/payout-review-cancel-slice.md`
  (+ slice-1 `…/payout-core-lifecycle-slice.md` §0/§1 money model); next-tester `wt-c-payb2t/next-tester_payb2t_findings.md`
  + evidence `integration-run-payout-rc-1781276546411-36403014.json` (46/46, `git_sha 3640301…`, stack **yupsev**);
  next-dev `wt-c-payb2/next-dev_payb2_findings.md`; brew-ops `wt-c-payb2ops/brew-ops_payb2ops_findings.md`.
  I read the deployed RPC **bodies** (via `pg_get_functiondef`) to learn RPC **surface** (args, fixture graph,
  lock/CAS shape) — the **verdict** is from observed DB behaviour vs **my** computed expectations, never
  "the code looks right".
- **Note on `git_sha`:** the GOAL cited `afcb9df`; the deployed-source evidence JSON carries `3640301…`
  (the later cosmetic "v1→v2 label" commit on the same `test/payb2-probes` branch). Immaterial — I bind
  to the **contract + ground truth**, not the tester's sha. brew-ops deployed PR #449 @ `3e2b778`.

---

## 1. Substrate facts established first-hand on qnccph (census)

| Fact | Evidence (qnccph, ground truth) |
|---|---|
| AM5 **table-enforced** | `wallet` CHECK `wallet_balance_gte_frozen :: balance >= frozen` + `wallet_frozen_nonneg`. Any settle/release/unfreeze that broke AM5 aborts the RPC. Final cross-wallet sweep: 0 violations. |
| `sweep_stale_claims(int,timestamptz)` | `SECURITY DEFINER`, `service_role` EXECUTE granted; reads `COALESCE(p_now, app_now())` + `_payout_stuck_review_minutes()`; old `(interval)` overload **dropped**. Predicate on `withdrawal_queue.claimed_at`, status ∈ `{claimed,processing}`; per-row `mark_review` in `BEGIN…EXCEPTION WHEN OTHERS CONTINUE`; `routed_to` always `'review'`. |
| `mark_failed_from_review(uuid,text,text)` | review-source guard (`status<>'review' ⇒ RETURN`); release `frozen-=gross`, **balance untouched**; one `payout_unfreeze` wcl; one `payout.failed` callback byte-shape = `mark_failed`'s; `failure_code` whitelist `{bank_timeout,claim_timeout,system_error}`, default `system_error`. `service_role` granted. |
| `admin_reconcile_payout` failed leg | `pg_get_functiondef` contains `mark_failed_from_review`, **not** a bare `PERFORM mark_failed(` — DRIFT-A is closed in the deployed body. Success leg `PERFORM mark_success(...)`; audit AFTER the money move in ONE txn (a money RAISE rolls back the whole request — no audit/no callback). |
| `mark_failed` (slice-1) | asserts `status='processing'` ONLY ⇒ `review` is a **benign no-op** — the SM2-SPLIT lock is intact in the deployed body. |
| `mark_success` (slice-1) | accepts source ∈ `{processing,review}`; settle `balance∧frozen-=gross`; PW2 fan-out `share=round(amount×pct/100,2)`; residual = `payout_fee − Σcredited` → `mdr_owner`; **PV1-R**: `residual<0 ⇒ RAISE mdr_over_allocated` (whole settle rolls back). |
| denorm path | `ts_payouts` has the `last_admin_action_*` columns but **no trigger**; the denorm is driven by `tr_audit_log_denorm` AFTER INSERT on `audit_log` → `_denorm_last_admin_action()` (only when `actor_type='admin'`, resource_type `payout` → updates `ts_payouts`). `audit_log` is append-only (no update/delete triggers). |
| audit_log shape | columns `resource_type / resource_id / action_type / actor_type / actor_id / actor_username / action_at / reason / metadata` — the tester's rebind is correct. |
| super_admin actors | two `app_user` super_admins (`18487feb…c5534` probe-admin, `e6175dca…d5e0`). Used `18487feb…` as `p_actor_id` for the direct-RPC money legs (gotrue-independent, SPEC §5). |
| residual sink | exactly one `mdr_owner` wallet (`33333333…01ff`, balance 0.00). Measured its delta per scenario. |
| RBAC seed | `role_permissions`: `super_admin ⊇ {payout:approve, payout:cancel}`; `client_admin / client_viewer / partner_user` lack both (the 403 perm-less set). |
| isolation | `mark_review` tail calls `reconcile_payout()` (PAYOUT-009); gated by `payout_auto_reconcile_enabled` (default **true** on qnccph). I forced `'false'` in-txn so the sweep cannot auto-resolve `review→success` (SPEC §5). `auth.users=0` (no gotrue identities). |

---

## 2. Money spine — independently re-derived, every PASS attacked (65/65 green)

All expectations computed by my harness from the contract formulae (`gross=amount+fee`,
`fee=round(amount×pct/100,2)`, `share=round(amount×partner_pct/100,2)`, `residual=fee−Σcredited`),
then compared to the rows the **real RPCs** wrote on qnccph. *(Harness `/tmp/falsify_payb2i.sql`,
65 assertions, one `BEGIN…ROLLBACK`.)*

### PAYOUT-004(a) — D6 sweep (`sweep_stale_claims`) — 16 checks
- **AC#1 always-review, never auto-fail:** two fixtures (`btxn=NULL` + `btxn='BTX-HINT-B'`), both
  `processing`, `claimed_at = app_now()−(knob+2)min` → **both land at `review`**; neither flips `failed`,
  neither reverts `pending`; `routed_to='review'` ×2. `btxn` is **hint-only**: the NULL one carries NULL
  into `ts_payouts.bank_transaction_id`, the set one carries `BTX-HINT-B` — the outcome (`review`) is
  identical, the hint never branches it.
- **AC#4 callback-silent + freeze held byte-exact:** the review flip enqueued **0** `callback_queue`
  rows for the swept payouts and **0** `wallets_change_logs` rows; `wallet.frozen` unchanged (`2026.00`).
- **AC#2 threshold relative to the knob:** older-than-knob → `review`, younger-than-knob stays
  `processing` (knob=5).
- **AC#2b knob tracks config:** a row at `claimed_at = anchor−7min` **stays `processing` with knob=10**,
  then **sweeps to `review` with knob=5** — the cutoff tracks the config, not a constant.
- **AC#3 virtual-clock drivable:** fresh-at-anchor not swept; after `clock_advance((knob+1)min)` the
  same row crosses the boundary → `review`. Driven by the §ADR-20 clock, not real time.

### PAYOUT-004(b) — admin reconcile — 21 checks
- **Success from review (full settle + PW2 + audit + denorm):** `amount=1000 @2% → fee=20, gross=1020`.
  client `balance 100000→98980` **and** `frozen 1020→0`; **one** `payout_settle`; **two** `mdr_distribute`
  (P1 `+6.00`, P2 `+4.00`); **one** `mdr_residual` → `mdr_owner` delta `+10.00`; **conservation exact**
  `gross 1020 = payee 1000 + Σcredited 10 + residual 10`, `residual ≥ 0`; **exactly one** `payout.success`
  (status SUCCESS, `bankTransactionId='admin-reconcile'` from the coalesce chain, `clientReferenceId` echoed
  iff `ref_code`); **one** §ADR-13 audit (`resource_type=payout, action_type=reconcile, actor_type=admin`),
  `audit_id` echoed matches the row; denorm `last_admin_action_type=reconcile / _by=actor / _reason`.
- **Failed from review via `mark_failed_from_review` ONLY (delta-A):** `amount=500 @2% → 510`. release
  `frozen 510→0`, **balance untouched** (`100000→100000`); **one** `payout_unfreeze` with
  `balance_before==balance_after`; **no** fan-out/residual; **exactly one** `payout.failed`
  (`failureCode=system_error`, `failureMessage=reason`, `clientReferenceId`); **NOT** a reverse_settle
  (source was `review`, zero prior settle); one audit (reconcile); denorm.
- **Producer-direct `mark_failed_from_review` (service-role):** release + one `payout.failed`, `ts→failed`,
  **no audit** (the §ADR-13 envelope lives in the admin wrapper, not the producer).
- **delta-A NEGATIVE (the SM2-SPLIT lock must survive slice 2):** slice-1 `mark_failed` on a `review`
  payout = **benign no-op** — stays `review`, `frozen` unchanged, **no** callback, **no** wcl. The
  dangerous late-bot `review→failed` path is still structurally locked out. ✓
- **PV1-R inheritance (fail-close):** over-allocated profile (`Σ shares 13 > fee 10`, `residual=−3`) at
  reconcile-success → **RAISE `mdr_over_allocated`**, **whole reconcile rolls back** — stays `review`,
  `balance`/`frozen` unchanged, **zero** settle/distribute/residual wcl, **zero** callback, **zero** audit,
  `mdr_owner` delta `0`.
- **`mark_failed_from_review` from non-review** (`processing/pending/success/cancelled`) = **refused/no-op**
  (no state change, no callback, no wcl).
- **Illegal reconcile sources** (`pending/processing/success/failed/cancelled`) → `outcome='not_review'`,
  zero effect; `invalid_resolution` → `invalid_resolution`; unknown payout → `not_found`.

### PAYOUT-005 — admin cancel — 11 checks
- **Happy (pending→cancelled):** `amount=300 @2% → 306`. `status→cancelled`; **unfreeze** `frozen 306→0`,
  **balance untouched**; **one** `payout_unfreeze` (`amount=306`, `balance_before==after`); queue item
  `→cancelled`; **exactly one** `payout.cancelled` with `failure_code='admin_cancelled'` + `request_id` +
  `amount`; **one** audit (`action_type=cancel`, `metadata.failure_code='admin_cancelled'`); denorm
  `last_admin_action_type=cancel`; outcome `cancelled` + `audit_id`.
- **Pending-only precondition:** `processing/review/success/failed/cancelled` → `not_pending`, **zero**
  money/state/callback/audit effect (5 sources, 0 violations).
- **Re-cancel = benign no-op (SM3):** 2nd cancel → `not_pending`; counts stay `unfreeze=1, callback=1,
  audit=1`, `frozen=0` — zero second effect (idempotency is in the EFFECT, not the 409 status code).
- **Cancel-vs-claim lock-first-wins:** *claim-first* → payout `→processing`, racing cancel returns
  `not_pending` with **no** unfreeze/callback (payout survives). *cancel-first* → payout `→cancelled`,
  a subsequent `claim_withdrawal_items` **does not pick it** (`v_payouts.effective_status='cancelled'`
  excluded; queue stays `cancelled`). Both legs on dedicated banks to isolate the claim's bank-wide scan.
- **AM5:** final cross-wallet sweep `balance<frozen OR frozen<0` = **0** (the table CHECK held the whole run).

### Harness has teeth
A deliberately-wrong expectation (settle balance `=99999`, the truth is `98980`) was injected and went
**RED** as designed — the predicates are not vacuously green (the live analogue of the tester's offline
self-check).

---

## 3. EF auth gate (live over the wire, qnccph) + the 403 substrate

| Probe | admin-payout-cancel | admin-payout-reconcile |
|---|---|---|
| no `Authorization` (apikey only) | **401 `missing_bearer_token`** | **401 `missing_bearer_token`** |
| garbage bearer | **401 `invalid_token`** (real gotrue verify, no stub) | **401 `invalid_token`** |
| GET | **405** (live routing, deployed — not 404) | **405** |

- **403 wrong-perm:** the RBAC decision behind it is **substrate-verified from ground truth** —
  `super_admin ⊇ {payout:approve, payout:cancel}`; `client_admin/client_viewer/partner_user` lack both
  (would 403). A **live** 403 needs an `aal2` gotrue JWT for a perm-less identity, but **`auth.users=0`
  on qnccph** → no token is mintable without committing gotrue rows (would break zero-footprint on the
  seal stack). I therefore **name** it: the EF-layer RBAC 403 is **tester-covered live on yupsev** (the
  tester minted a real aal2 super_admin + a perm-less `partner_user` → 401×4 / 403 `{required_permission}`)
  and the substrate that drives it is confirmed on qnccph. Same disciplined posture as my slice-1 pass.

---

## 4. Re-verification of the tester's 4 probe-side fixes (§7) — from MY ground truth

1. **audit_log column rebind** (`resource_type/action_type/metadata/resource_id`, not `entity/action/detail`)
   — **CONFIRMED** by my census and by every REC/CAN audit assertion reading the deployed columns and matching.
2. **sweep/race staging → claim-path-independent drive** — **CONFIRMED necessary**: `claim_withdrawal_items`
   carries an active-batch guard (`count(*) WHERE status IN ('claimed','processing') > 0 ⇒ RETURN`) **and**
   scans every pending row on the bank — my own harness independently hit this (I had to seed the sweep via
   direct `claimed_at` backdating and give the race tests dedicated banks). The SPEC §5 drive is correct.
3. **cancel-vs-claim race rewrite (winner determination)** — **CONFIRMED**: both deterministic orderings
   yield the safe lock-first-wins outcome; the `race_lost` branch is the genuine-concurrency CAS path
   (`UPDATE … WHERE status='pending' RETURNING …; NOT FOUND ⇒ race_lost`), code-confirmed and mapped to the
   same 409, money-safe in both directions.
4. **readiness `mark_review` arity drop** — **CONFIRMED**: `mark_review(uuid,text,text)` is present and its
   presence is proven transitively by the sweep producing `review`.

---

## 5. KNOWN items — NAMED, not sealed over

1. **EF-layer 403 not live-exercised on qnccph** (auth.users=0 → no mintable aal2 identity without
   committing gotrue rows). Substrate verified; tester-covered live on yupsev. Not a money-spine concern,
   not a slice blocker. (Same boundary call as slice-1.)
2. **Genuine-concurrency `race_lost`** not driven via two committed sessions (would require committed
   fixtures, breaking zero-footprint). The invariant (lock-first-wins, no double effect) is proven by both
   deterministic orderings + the re-cancel no-op; the `race_lost` CAS branch is code-confirmed.
3. **`mark_review` lacks a positive source assert** (dev routed note #3) — confirmed structurally; money-safe
   because the sweep predicate constrains the source to `claimed/processing` and `review` holds the freeze +
   is callback-silent. Architect-routed robustness nit, not a slice blocker.
4. **PAYOUT-009 (`reconcile_payout` tail of `mark_review`)** is out-of-slice; I isolated it via
   `payout_auto_reconcile_enabled='false'` (in-txn). Confirmed `reconcile_payout` returns `'disabled'` when
   off and would otherwise need a matching `direction='out'` `bank_statements` row (none seeded). Not in scope.
5. **IP-allowlist** (named in the §3.1/§4.1 auth chain) — not in the GOAL negative set; no `admin_profiles`
   allowlist rows on qnccph (so `enforceIpAllowlist` passes). Not exercised; consistent with the tester note.

---

## 6. Zero-footprint (verified after the run)

Every money scenario ran in one `BEGIN…ROLLBACK`. Post-run census on qnccph: `ts_payouts`,
`withdrawal_queue`, `callback_queue`, `wallets_change_logs` all back to **0**; `audit_log` = **447**
(baseline, unchanged); **no** leaked `merchant_config`/`client`/`bank_account('TESTBANK')`/`mdr_profile`;
virtual clock back to **real** (drift `0.00`); `payout_auto_reconcile_enabled='true'` and
`payout_stuck_review_minutes=5` restored; `mdr_owner` balance back to **0.00**. The 6 live EF probes were
rejected at auth (no DB write). **Nothing committed to qnccph.**

---

## 7. Bottom line

**GREEN — PAYOUT slice-2 falsification PASS.** Independent re-derivation of the D6 sweep (always-review /
never-auto-fail / btxn-hint-only / threshold-relative-to-knob / knob-tracks-config / virtual-clock-driven /
callback-silent + freeze-held), the admin-reconcile success (settle + PW2 + residual + conservation≥0 +
one callback + §ADR-13 audit + denorm) and failed (`mark_failed_from_review` release frozen-only + one
callback + audit), the PV1-R `mdr_over_allocated` fail-close (full rollback, stays review), the SM2-SPLIT
NEGATIVE (slice-1 `mark_failed` on review still a benign no-op — the lock survives slice 2), the
producer-direct and non-review no-ops, and the PAYOUT-005 admin-cancel (unfreeze-not-debit, one
`admin_cancelled` callback, audit + denorm, re-cancel zero-second-effect, cancel-vs-claim lock-first-wins) —
**all reconcile with qnccph ground truth.** The EF auth gate is live (401, not 404) on both EFs; the RBAC
403 substrate is correctly seeded. All four tester probe-side fixes are re-confirmed from **my** ground
truth. The tester's **46/46 is corroborated, not inherited.** No money-spine contradiction. The named items
(EF-403 live / genuine-concurrency race_lost / `mark_review` positive-assert) are boundary/robustness calls,
not slice blockers. (Slice-level only — the payout **epic-seal** awaits all slices.)

*Harness: `/tmp/falsify_payb2i.sql` (local, not committed) — 65 assertions + 1 teeth-sentinel,
`BEGIN…ROLLBACK`, run against `qnccphgykzdydebmdwdf` 2026-06-12.*
