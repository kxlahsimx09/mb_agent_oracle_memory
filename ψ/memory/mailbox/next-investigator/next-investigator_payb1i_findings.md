# next-investigator — PAYOUT slice-1 Step-2 FALSIFICATION (campaign payb1i)

> **Role / posture:** build-workflow **Step-2 falsification**. I do **not** inherit next-tester's
> 71/71 GREEN. I independently **re-derived** every payout money invariant from the **contract**
> (SPEC v2 + ratified ADR/epic text), drove the **real deployed RPCs** on **my own seal stack
> (qnccph)** with **my own fixtures + my own independently-computed expectations**, and tried to
> **falsify every PASS**. Everything ran inside `BEGIN … ROLLBACK` (zero-footprint); zero-footprint
> independently verified after the run.
>
> **VERDICT: ✅ GREEN — slice-falsification PASS. 77/77 independent re-derivations reconcile with
> qnccph ground truth. No money-spine contradiction found.** The tester's 71/71 is **corroborated by
> independent re-derivation on a different stack** (not inherited). Both of the tester's probe-side
> RED reclassifications were re-confirmed from **my** ground truth.

- **Stack (my seal env):** `qnccphgykzdydebmdwdf` (investigator.env slot). Driven as `postgres` over the
  IPv4 session pooler. Substrate carries the 3 slice migrations `20260612000100 / …000110 / …000120`
  and the slice RPC signatures (verified live, see §1). EFs `payouts-create` + `bot-queue-mark` deployed
  + auth-gating (401, not 404) on qnccph.
- **Slice under test:** PAYOUT-001/002/003 + SM1–SM3 — PR #437 @ `build/payout-slice1`.
- **Inputs READ (never trusted as substitute):** SPEC v2 (`origin/build/payout-slice1:docs/spec/payout-core-lifecycle-slice.md`);
  next-architect rulings (`wt-c-payb1/next-architect_payb1_findings.md` Q1–Q4/C1); next-tester
  evidence (`wt-c-payb1t/.../integration-run-payout-1781266973439-91e2497a.json`, 71/71 GREEN on `yupsev`)
  + `next-tester_payb1t_findings.md §6`. I read the migration bodies to learn RPC **surface** (names,
  args, fixture graph) — the **verdict** is from observed DB behaviour vs **my** computed expectations,
  never "the code looks right".
- **Method note (independence):** I drove the **RPC money substrate** (`create_payout`,
  `claim_withdrawal_items`, `mark_success`, `mark_failed`) directly — the same transport the tester's
  RPC legs used (PostgREST service-role → here `psql`/postgres), but on a **different stack**, with
  **different fixtures**, and with **expected values I recomputed from the contract**, not lifted from
  the evidence JSON. The only shared input is the **contract** (by design — it is the source of truth).

---

## 1. Substrate facts I established first-hand on qnccph (census)

| Fact | Evidence (qnccph) |
|---|---|
| AM5 is **table-enforced** | `wallet` CHECK `wallet_balance_gte_frozen :: (balance >= frozen)` + `wallet_frozen_nonneg`. A settle/release that broke AM5 would abort the RPC. |
| `create_payout` selection is **global-singleton** | `… FROM mdr_profile ORDER BY created_at, id LIMIT 1` (no WHERE) — the architect Q1 model. My fixtures backdate each scenario's profile to be unambiguously global-oldest (see §4 harness-bug note). |
| Deployed RPC sigs | `create_payout(13 args incl. callback_endpoint_key/client_reference_id/metadata)`, `mark_success(p_queue_id,p_bank_transaction_id)`, `mark_failed(p_queue_id,p_error_message,p_failure_code)`, `claim_withdrawal_items(p_bank_account_id)`; `mark_rejected` **dropped**. |
| `ts_payouts` slice cols present | `callback_endpoint_key, callback_endpoint_version, mdr_profile_id, ref_code, metadata`. |
| `mdr_profile_partners` shape | `(mdr_profile_id, partner_id, percentage)` — **no `is_active`**; partner active-ness = the partner **wallet's** `is_active` (matches deployed `mark_success` LEFT JOIN). |
| residual sink | `wallet` has **no `is_owner`**; residual wallet = `owner_type='mdr_owner'` (qnccph has exactly 1; I used it as the live residual sink and measured its before/after delta). |
| callback insert path | `callback_queue` autofill trigger derives `dedup_key` + resolves `merchant_id` via `client.merchant_id` (NN); a dispatch trigger `net.http_post`s only if `app_settings` has a URL — it does, but the enqueue **rolls back** with my txn (zero delivery). |
| fair-router | `trigger_fair_router` on `withdrawal_queue` INSERT **no-ops for Mode-2** (required_bank_account_id set) — create-time observable `status='pending'`, no bank assigned, holds. |

---

## 2. Money spine — independently re-derived, every PASS attacked (77/77 green)

All expectations below were **computed by my harness from the contract formulae**, then compared to the
rows the **real RPCs** wrote. (`gross = amount + fee`, `fee = round(amount × pct/100, 2)`.)

### PAYOUT-001 create (freeze + fee + snapshot)  — task #2
- `fee = round(amount×pct/100,2)`: `100@1.5% → 1.50` ✓. **Rounding falsified vs trunc:** `33.33@1.5% =
  0.49995 → 0.50` (trunc would give 0.49) ✓; `10@1.25% = 0.125 → 0.13` half-up (trunc 0.12) ✓.
- `final_amount = amount − fee = 98.50` (stored display col, **not** the freeze base) ✓.
- **Freeze = gross:** `frozen += 101.50`, **balance unchanged** ✓. `payout_freeze` wcl: 1 row, `amount=gross`,
  all four `balance/frozen_before/after`, `reference_type='ts_payouts'`, `reference_id=payout_id` ✓.
- Snapshots: `callback_url = the RESOLVED endpoint` (I passed a raw `https://EVIL-…` in the ignored
  `p_callback_url` slot → stored URL is the preconfigured endpoint, **raw URL ignored**, §ADR-9 CU1) ✓;
  `callback_endpoint_key/version`, `mdr_profile_id`, `ref_code`, `metadata` all snapshotted ✓; `system_bank_id`
  **NULL at create** ✓; `withdrawal_queue` row `source=payout/pending`, no bank assigned ✓. AM5 ✓.
- **Q1 deterministic tiebreaker:** 3 profiles tied on `created_at`, distinct ids → `create_payout` picked
  the **min-id** profile (independently computed by me) and its fee (2.00%, not the 7.00% losers) ✓.

### PAYOUT-002 claim (C1)  — task #3
- `claim_withdrawal_items` → `withdrawal_queue.status pending→claimed` + `batch_id` stamped + `claimed_at`;
  linked `ts_payouts.status pending→processing`; `system_bank_id` stamped to the claiming bank; `batch_id`
  mirrors across both rows. **C1 hard-assert** (`wq='claimed'` AND `ts='processing'`) ✓; **no `claimed`
  value ever appears on `ts_payouts.status`** ✓.

### PAYOUT-002 success — settle + PW2 fan-out + callback  — task #4
- **Settle = atomic:** client `balance −= 101.50` **and** `frozen −= 101.50` (→ 0) in one txn ✓.
- **`payout_settle` wcl [tester RED1, re-confirmed from MY ground truth]:** exactly 1 row, all four
  before/after populated, `reference_type='withdrawal_queue'`, `reference_id = queue_id` ✓.
- **PW2 fan-out:** exactly **one** audit row per partner (no silent drop). Active partners credited
  `share = round(amount×pct/100,2)` (`0.60`, `0.40`) with `mdr_distribute` (`ref=ts_payouts/payout_id`);
  **residual = fee − Σcredited = 0.50** routed to `mdr_owner` (measured owner-wallet delta = 0.50) with
  `mdr_residual` ✓.
- **PW2 conservation, residual ≥ 0:** `payout_fee (1.50) = Σcredited (1.00) + residual (0.50)`; gross form
  `101.50 = payee 100 + Σcredited 1.00 + residual 0.50` ✓.
- **mdr_skip:** inactive-partner-wallet → `mdr_skip` note `partner_inactive`; missing-wallet partner →
  `mdr_skip` note `wallet_missing`; **skipped shares stay in residual** (only the 1 active credited 0.60 →
  residual 0.90 → owner) ✓. One row per partner (3 partners → 1 distribute + 2 skip) ✓.
- **Over-allocated profile (Q2 fail-close):** seeded `Σ partner-pct 1.3 > fee 1.0` **at create time** (no
  post-create bump needed → cleaner than the probe's bump path). `mark_success` **RAISEd
  `mdr_over_allocated` (residual = −0.30)** and **fully rolled back**: payout stays `processing`, freeze
  intact (101.00), balance unchanged, **zero** settle/fan-out rows, **zero** callback ✓.
- **Missing residual wallet (extra leg, beyond the GOAL minimum):** hid the `mdr_owner` wallet inside a
  subtxn → `mark_success` **RAISEd `mdr_owner_residual_wallet_missing`** + full rollback (stays processing);
  owner wallet restored on rollback ✓.
- **Callback exactly-once:** one `payout.success`, payload `status:SUCCESS`, `txnId=request_id`, `fee`,
  `bankTransactionId`, `completedAt`, `clientReferenceId` present **iff** `ref_code` set ✓. `wq→success` ✓.
- **Duplicate `mark_success` = benign no-op:** 2nd call → no 2nd settle/callback/debit/fan-out;
  `bank_transaction_id` not overwritten ✓.

### PAYOUT-003 failed — release + SM guard  — task #5
- **Release = frozen-only, BALANCE UNTOUCHED:** `frozen −= 101.50` (→0), **balance identical**;
  `payout_unfreeze` wcl with `balance_before == balance_after`, `frozen−=gross`, `ref=withdrawal_queue` ✓.
  **No** settle/distribute/residual/skip rows on the failed path ✓.
- Callback exactly-once `payout.failed`, **mandatory `failureCode`**, `fee`, `txnId`, optional
  `failureMessage`, `clientReferenceId` iff `ref_code` ✓. `wq→failed` ✓. AM5 ✓.
- **Non-whitelist code [tester RED2, re-confirmed from MY ground truth]:** `mark_failed('bank_rejected')`
  at the **RPC seam** RAISEs `invalid_failure_code_for_failed_terminal` + full rollback (stays processing,
  freeze intact, no unfreeze, no callback) — the RPC is **defensive**, money-safe. (The spec's
  collapse→`system_error` lives at the **EF** seam — see §3 named gap.) ✓.
- Duplicate `mark_failed` → benign no-op (no 2nd release/callback; first failure_code preserved) ✓.
- **Pre-claim `mark_failed` = no-op (processing-only):** on a `pending` (unclaimed) payout → no-op, stays
  `pending`, freeze intact, no callback — **`failed` is strictly post-claim** ✓.

### SM2-SPLIT / SM3 / AM5  — task #6
- **SM2-SPLIT both arms:** late **success** from `review` **ACCEPTED** → settles **once**, `review→success`,
  one callback ✓. Late **failed** from `review` **REFUSED** → benign no-op, stays `review`, freeze intact,
  no callback (asymmetry: trust a late success, never a late failure) ✓.
- **SM3 illegal-source matrix (14):** `mark_success` from `{pending,success,failed,cancelled}`,
  `mark_failed` from `{pending,review,success,failed,cancelled}`, `claim` from
  `{processing,success,failed,review,cancelled}` → **all benign no-ops**: no status change, no money move,
  no callback, no batch stamp ✓.
- **AM5 walk:** `balance ≥ frozen` at create → claim → settle (and on the release path) — table CHECK
  active the whole way ✓.

### Create-time negatives (RPC-level "no state written")
- `insufficient_funds` (402-mapped RAISE; **money-safety**), `payout_disabled`, `unsupported_dest_bank`,
  `amount_out_of_range`, `callback_endpoint_not_configured`, `invalid_callback_endpoint_key`, route XOR
  neither/both — **each RAISEs and writes no `ts_payouts` row, frozen unchanged** ✓.

---

## 3. KNOWN items — NAMED, not sealed over

1. **EF-layer `failure_code` collapse (coverage gap, NOT an RPC-substrate defect).** SPEC §4.1 says a
   non-whitelist `failure_code` (e.g. legacy `bank_rejected`) **collapses to `system_error`**. From my
   ground truth that collapse is **not** in the RPC — the RPC `mark_failed` is **defensive** (RAISEs
   `invalid_failure_code_for_failed_terminal`, money-safe). The collapse must therefore live in the
   `bot-queue-mark` EF normalization (bot-tier auth, `BOT_CRED_ENC_KEY`). I did **not** drive that EF
   seam (it would commit real state and needs bot-tier auth) → **named, unverified, same gap the tester
   flagged.** Recommend the orchestrator either (a) confirm the EF collapse via the bbot seam, or
   (b) pin in the SPEC exactly which seam owns the collapse. **Not a slice-falsification blocker** (the
   money substrate is correct; this is a normalization-location question).
2. **`ts_payouts` actor-triple = `client_id`-suffices Phase-1 (architect Q3).** `ts_payouts` has no
   `created_by_{type,id,username}`; create-time actor degrades to `client_id` (+ the asserted `sub`).
   Ruled acceptable (parity with the sealed deposit lane). Not re-litigated here — confirmed structurally
   absent on qnccph; not a blocker.
3. **`admin_approve_paid` residual<0 guard = cross-campaign coordination (PR #438).** The over-allocation
   fail-close I re-confirmed in `mark_success` (PR #437) and the parity mirror (`finalize_deposit`,
   PR #441) is the **third** call site `admin_approve_paid`, owned by another campaign's PR #438
   (`orchestrator-dev28` coordination envelope 2026-06-12 18:05). **Out of this slice** — named, not sealed.

---

## 4. Falsification hygiene — the harness can (and did) go RED

The predicates are **not vacuously green.** My **first** live run produced **21 REDs** — and on
inspection **all 21 traced to two bugs in MY harness, not the substrate**, which is exactly the signal a
real falsifier should surface:
- **(A) fixture-isolation bug:** I had backdated *every* scenario's `mdr_profile` to the same
  `1990-01-01`. Because `create_payout` is **global-singleton** (`ORDER BY created_at, id`), later
  scenarios snapshotted an *earlier* scenario's profile (the `1.25%`-no-partner one) → my fee/fan-out
  predicates correctly went RED (fee 1.25≠1.50, 0 fan-out rows, residual=whole-fee). The substrate was
  behaving **exactly** per the architect Q1 ruling; my fixtures violated "seed one applicable profile".
  Fixed with a monotonically-decreasing profile timestamp so each scenario's profile is unambiguously
  global-oldest.
- **(B) S9 positional bug:** I passed the invalid endpoint key into the *ignored* `p_callback_url` slot →
  it defaulted to `default` and resolved → my "should RAISE" predicate correctly went RED.

After fixing **the harness** (never the substrate), all 77 reconcile. That a wrong fixture and a wrong
arg both drove visible REDs is the live analogue of the tester's offline 25/25 self-check: the checks
have teeth.

---

## 5. Scope boundary (named, not hidden) + zero-footprint

- **What I re-derived:** the **RPC money substrate** — the entire money spine in the GOAL. EF-boundary-only
  behaviours (Idempotency-Key 400/409 + replay, metadata cap, raw-`callback_url` 400, GW4 auth precedence /
  `wrong_scope` 401, the HTTP-200 response envelope) live at the `payouts-create` EF, are **not** money-spine,
  and are **tester-covered**; I independently confirmed only that both EFs are **deployed + auth-gating**
  (401, not 404) on qnccph. The RPC-level callback-endpoint gates (`not_configured` / `invalid_key`) **are**
  in the RPC and I re-derived them (§2 negatives).
- **Virtual clock:** slice-1 has **no time-gated transition** (auto-cancel/timeout = PAYOUT-008, out of
  slice); the lifecycle RPCs use `now()` only to stamp `completed_at`/`failed_at`/callback `completedAt`.
  A virtual clock is therefore **not money-load-bearing** here; `BEGIN…ROLLBACK` already pins a single
  transaction timestamp. Named as an *absence of dependency*, not an omission.
- **Zero-footprint (verified after the run):** every scenario ran in one `BEGIN…ROLLBACK`. Post-run census:
  0 leaked `merchant_config`/`client`/`ts_payouts`/`bank('TESTBANK')`/backdated-`mdr_profile`; the `_seed`
  helper is gone; the single `mdr_owner` wallet is untouched (count still 1, my S4b owner re-point rolled
  back). The two EF probes were rejected at auth (no write). **Nothing committed to qnccph.**

---

## 6. Bottom line

**GREEN — PAYOUT slice-1 falsification PASS.** Independent re-derivation of the create-freeze/fee money,
the claim C1 transition, the success settle + PW2 fan-out/residual/over-config fail-close, the failed
release, the SM2-SPLIT asymmetry, the SM3 benign-no-op matrix, and AM5 — all reconcile with qnccph ground
truth. The two probe-side RED reclassifications (settle wcl 4-field+linkage; non-whitelist defensive RAISE)
are re-confirmed from **my** ground truth. The tester's 71/71 is **corroborated, not inherited.** The one
EF-layer `failure_code` collapse is the single **named** coverage gap; the actor-triple and the
`admin_approve_paid` guard are named, ruled/coordinated elsewhere, and out of this slice. No money-spine
contradiction. (Slice-level only — the payout **epic-seal** awaits all slices.)

*Harness: `/tmp/falsify_payout.sql` (local, not committed) — 77 assertions, `BEGIN…ROLLBACK`, run against
`qnccphgykzdydebmdwdf` 2026-06-12.*
