# next-tester — PAYOUT core-lifecycle slice-1 probe build (campaign payb1t)

> **Role / de-bias:** Step-1 PARALLEL probe build (build-workflow.md). Probes bind **EXCLUSIVELY**
> to the broadcast SPEC contract `origin/build/payout-slice1 : docs/spec/payout-core-lifecycle-slice.md`
> (**v2, 2026-06-12** — re-broadcast after the next-architect payb1 rulings), read via `git show` —
> **the contract, never next-dev's `supabase/` code** (layer-1 de-bias, never violated). Expected
> behaviour is derived from the SPEC + the ratified epic/ADR text it cites, cross-checked below.
>
> **Both v1 contract questions are now RULED (SPEC v2) and bound — see §3.** C1 → SM1 binds
> `ts_payouts.status` ONLY, queue keeps `claimed` (claim probe now HARD-asserts both). Q2 → SHARE_BASE
> stays `amount`, conservation + `residual ≥ 0`, and a NEW over-allocated-profile fail-close probe.
>
> **Status: ✅ VERIFIED GREEN on the tester stack (yupsev, 2026-06-12).** The slice-1 substrate
> deployed (brew-ops, dev PR #437); the suite ran **push-button → 71/71 PASS, all 8 lanes GREEN**
> (git_sha `91e2497`). See §6 for the run, the readiness rebindings, and the 2 probe-side fixes the
> live run surfaced. (Offline harness self-check 25/25 still gates every run.)
>
> **Branch / PR:** `test/payb1-probes` off `origin/main` (f30daac). Test-only — **DO NOT MERGE** (PR #439).

---

## 0. What was built

```
tests/integration/probes/payout/
  _spec-payout.ts      SPEC binding block (ef/rpc/tbl/col/hdr/status/err/op/quote/legalSource)
  _assert-payout.ts    PURE predicates (fee, gross, share[Q2-swappable], pw2-conserve, am5,
                       settle/release/freeze mutations, SM2 legal-source, SM3 benign-no-op)
  _flow-payout.ts      TRANSPORT + fixtures (scope=payout assertion signer, create EF, claim/
                       mark_success/mark_failed RPCs, ground-truth reads, fixture resolve/seed)
  _stage-payout.ts     staging (create→claim→force-state) for the lifecycle probes
  readiness.ts         Lane-0 stack-readiness gate (tables/EFs/RPCs/clock+reset/fixtures)
  p001-create.ts       PAYOUT-001 create (16 assertions)
  p002-claim.ts        PAYOUT-002 claim (3; C1 ruled → hard-asserts wq='claimed' AND ts='processing')
  p002-success.ts      PAYOUT-002 success settle + PW2 fan-out + over-config fail-close (6)
  p003-failed.ts       PAYOUT-003 failed release (6)
  sm2-split.ts         SM2-SPLIT late-report asymmetry (2)
  sm3-cas.ts           SM3 illegal-source benign-no-op matrix (14)
  am5-invariant.ts     AM5 balance≥frozen walk (2)
tests/integration/run-payout-core.ts   runner (reset+clock → readiness gate → money lanes; evidence JSON)
tests/integration/payout-selfcheck.ts  OFFLINE harness validation (mutate expectation → red)
```

**Harness validation (offline, stack-bare):** `bun tests/integration/payout-selfcheck.ts` → **25/25
meta-assertions pass**. Every money/SM predicate is proven **GREEN on a valid input AND RED on a
deliberately-violated one** — including the load-bearing safety cases:
- a `settle` that moved `frozen` but **not** `balance` → RED (the "forgot the balance leg" bug);
- a `failed` release that **debited** `balance` → RED (a failed payout can never debit);
- `mark_failed` from `review` ruled a **legal** source → RED (SM2-SPLIT: never auto-fail a late report);
- a PW2 ledger that does not conserve, or a negative residual (Σpartner-pct > fee-pct) → RED;
- the over-config detector flags Σ active-pct > fee_pct (the Q2 fail-close trigger) and passes a valid profile.

This satisfies "prove each probe FAILS on a violated expectation before trusting any green" without
touching a deployed stack. The first live run additionally validates end-to-end against ground truth.

---

## 1. Probe → AC bijection

Each `ok(...)` row carries the verbatim SPEC/AC clause it binds (the `:: …` quote tail). HTTP **200**
on create (payout), **not** deposit's 201.

| Probe assertion | SPEC / epic AC | Binds |
|---|---|---|
| `p001.a_happy_create_freeze_fee_actor` | §2.1/§2.3 · epic L108 | 200 + pending; **fee=round(amount×pct/100,2)**; final=amount−fee; **frozen += gross(amount+fee), balance unchanged**; payout_freeze wcl (4 before/after); wq source_type=payout/pending; actor triple type=client |
| `p001.b_missing_idem_key_400` | §2.2 · epic L111 | missing key → 400 `IDEMPOTENCY_KEY_REQUIRED`, no state |
| `p001.c_idem_replay_echo_no_second_freeze` | §2.2 · epic L112 | same key+same body → replay echo, no 2nd payout/freeze |
| `p001.d_idem_diff_body_409` | §2.2 · epic L113 | same key+diff body → 409 `IDEMPOTENCY_KEY_REUSED_WITH_DIFFERENT_BODY`, no new row |
| `p001.e_callback_url_not_allowed_400` | §2.2 · epic L109 | raw `callback_url` → 400 `CALLBACK_URL_NOT_ALLOWED`, no state |
| `p001.f_callback_not_configured_409` | §2.2 · epic L110 | no payout endpoint → 409 `CALLBACK_ENDPOINT_NOT_CONFIGURED`, no state |
| `p001.g_invalid_callback_key_400` | §2.2 · epic L110 | unknown key → 400 `INVALID_CALLBACK_ENDPOINT_KEY`, no state |
| `p001.h_no_assertion_401_auth_precedes_body` | §2.1 | omitted assertion → 401; **auth precedes body** (no row) |
| `p001.i_wrong_scope_401` | §2.1 | non-`payout` scope → 401 `wrong_scope` |
| `p001.j_amount_out_of_range_400` | §2.2 | amount<min → 400 `AMOUNT_OUT_OF_RANGE`, no state |
| `p001.k_unsupported_dest_bank_400` | §2.2 | dest bank not in registry → 400 `UNSUPPORTED_DEST_BANK`, no state |
| `p001.l_insufficient_funds_402` | §2.2 | spendable<gross → **402** `INSUFFICIENT_FUNDS`, no state |
| `p001.m_metadata_too_large_400` | §2.2 | metadata > cap (30 keys / 8192 B) → 400 `METADATA_TOO_LARGE`, no state |
| `p001.n_neither_route_400_missing_route` / `..._both_route_400_ambiguous_route` | §2.2 | route XOR: neither→`missing_route`, both→`ambiguous_route` |
| `p001.o_concurrency_first_wins_second_insufficient_am5` | §2.4 · epic L117 | two creates summing>spendable → one 200, one 402; **AM5 (balance≥frozen) never violated** |
| `p002.claim_a_pending_to_processing_bank_batch_stamped` | §3.1 · epic L192 · SM1 | claim → ts_payouts `pending→processing`, system_bank_id stamped, batch_id stamped |
| `p002.claim_b_no_claimed_state_on_ts_payouts` | §1 SM1 v2 | ts_payouts.status is exactly `processing` — **no `claimed` ts_payouts.status** (claimed lives only on the queue) |
| `p002.claim_c_wq_claimed_ts_processing` | **C1 RULED v2 — §3.1** | **HARD-asserts** `withdrawal_queue.status='claimed'` AND `ts_payouts.status='processing'` |
| `p002.success_a_settle_balance_and_frozen_audit_terminal_am5` | §3.2 · epic L195 · AM2/AM3/AM4 | **balance AND frozen each −= gross atomically**; one payout_settle wcl (4 before/after, ref=withdrawal_queue); status→success, bank_transaction_id+completed_at; AM5 |
| `p002.success_b_pw2_fanout_one_per_partner_conserved` | §3.2 · epic L196 · PW2 | **exactly one audit row per partner** (distribute/skip, no silent drop); residual→is_owner mdr_owner; **conservation fee=Σshares+residual, residual ≥ 0** (Q2 v2); per-share value `base=amount` (SHARE_BASE re-affirmed) |
| `p002.success_c_callback_payout_success_once` | §3.2 · epic L198 | one `payout.success` callback; payload status:SUCCESS, completedAt, fee, txnId(=request_id), bankTransactionId, clientReferenceId iff ref_code |
| `p002.success_d_inactive_partner_mdr_skip_with_note_conserved` | §3.2 | inactive partner → one `mdr_skip` w/ structured note; share rolls to residual; ledger balances |
| `p002.success_e_duplicate_benign_no_op` | §3.2 · epic L200 | 2nd success → benign no-op (no 2nd settle/callback/debit/fan-out) |
| `p002.success_f_over_allocated_fail_close_rollback` | **§3.2 Q2 v2** | over-allocated profile (Σ active-pct > fee_pct) → mark_success **RAISEs `mdr_over_allocated`** + full rollback; payout stays `processing`, freeze intact, no settle/fan-out rows, no callback |
| `p003.failed_a_release_frozen_only_balance_untouched_am5` | §4.1 · epic L261 | **frozen −= gross, balance UNTOUCHED**; payout_unfreeze wcl (balance_before==balance_after); status→failed+failure_code; AM5 |
| `p003.failed_b_no_debit_no_fanout_no_residual` | §4.1 · epic L262 | failed path never touches balance; no settle/mdr rows |
| `p003.failed_c_callback_payout_failed_once_failureCode` | §4.1 · epic L264 | one `payout.failed`; status:FAILED, **mandatory failureCode**, fee |
| `p003.failed_d_nonwhitelist_code_rpc_defensive_guard` | §4.1 | non-whitelist code at the RPC seam → `400 invalid_failure_code`, stays `processing` (the collapse→`system_error` is EF-layer — §6/RED2, flagged) |
| `p003.failed_e_duplicate_benign_no_op` | §4.1 · epic L266 | 2nd failed → benign no-op (no 2nd release/callback) |
| `p003.failed_f_pre_claim_mark_failed_is_no_op_processing_only` | §4.1 · epic L265 · SM2-SPLIT | mark_failed on **pending** → benign no-op, stays pending (failed is strictly post-claim) |
| `sm2split.a_late_success_from_review_accepted_settles_once` | §1 SM2-SPLIT | late bot success from `review` **ACCEPTED** → settle once, review→success, one callback |
| `sm2split.b_late_failed_from_review_rejected_no_op` | §1 SM2-SPLIT | late bot failed from `review` **NOT accepted** → benign no-op, stays review, freeze intact |
| `sm3.mark_success.from_{pending,success,failed,cancelled}_benign_no_op` (4) | §1 SM3 | illegal source → benign no-op (no status/money/callback change) |
| `sm3.mark_failed.from_{pending,review,success,failed,cancelled}_benign_no_op` (5) | §1 SM3 | illegal source → benign no-op |
| `sm3.claim_withdrawal_items.from_{processing,success,failed,review,cancelled}_benign_no_op` (5) | §1 SM3 | claim never moves a non-pending item |
| `am5.freeze_settle_invariant_each_step` / `am5.freeze_release_invariant_each_step` | §0 AM5 | balance≥frozen at create→claim→settle and create→claim→release |

**Coverage of the GOAL's named AC surface:** create (auth precedence ✓, Idempotency 400/409 ✓,
callback 409/400 ✓, fee formula ✓, gross freeze ✓, actor triple ✓, pending ✓); claim→processing
single work-state / no claimed-on-payout ✓ (+ C1 wq='claimed' hard-asserted); success settle
balance&frozen atomic ✓, PW2 residual conservation (residual ≥ 0) ✓, over-config fail-close ✓,
callback once ✓; failed release frozen-only / balance-untouched ✓, callback ✓; SM2-SPLIT both arms ✓;
SM3 CAS illegal-source matrix ✓; AM5 invariant ✓.

---

## 2. PENDING-DEPLOY — what the tester stack must carry before a push-button run

The runner (`run-payout-core.ts`) gates ALL money lanes on the Lane-0 readiness gate **and** the
signing key; absent either, lanes report `BLOCKED-ON-DEPLOY` and never run. Required before green:

**Tables (not 404):** `ts_payouts`, `withdrawal_queue`, `wallet`, `wallets_change_logs`,
`client_callback_endpoints`, `mdr_profile`, `mdr_profile_partners` (+ `client`, `bank_account` for reads).

**Edge Functions (respond, not 404):** `payouts-create` (GW4 scope=payout gate live), `bot-queue-mark`.

**RPCs (PostgREST-resolvable):** `claim_withdrawal_items(p_bank_account_id)`,
`mark_success(p_queue_id,p_bank_transaction_id)`, `mark_failed(p_queue_id,p_error_message,p_failure_code)`,
`upsert_client_callback_endpoint(...)` (callback config seam), `reset_for_test`, **§ADR-20 clock**
(`app_now`, `clock_set`, `clock_advance`, `clock_reset`).

**Fixtures (seeded):** an `enable_payout=true` client + wallet (balance ≥ test gross) + min/max band;
an `mdr_profile` with `payout_fee_percent` + ≥1 `mdr_profile_partners` row with a partner wallet; an
`is_owner` `mdr_owner` **residual wallet** (settle fail-closes without it); an active **payout**
`client_callback_endpoints` row (`flow='payout'`, `endpoint_key='default'`); ≥1 `bank_account` in the
supported-bank registry. *(The routed `withdrawal_queue` item is produced by the probe via a Mode-2
create bound to the seeded bank — routing itself is out of slice, per SPEC §3.1.)*

**Tester-slot env (brew-ops provisioning):** `GATEWAY_ASSERTION_SIGNING_KEY` (base64 PKCS8 Ed25519)
+ `GATEWAY_ASSERTION_KID` — a **scope=payout** GW4 keypair whose `kid` is in the stack's
`GW4_VERIFY_KEYS`. Absent → create assertions fail closed (401) and money lanes report BLOCKED.

**Deploy ownership:** next-dev hands off the migration set + EF list (PR #437) → **brew-ops/owner**
applies the cross-stack deploy to the tester (+ seal) stack. Currently **held pending the Q2 ruling**.

### `[SPEC-PENDING]` / `[SEED-PENDING]` census (verify at first deploy; never silently assumed)
- `wallets_change_logs` four before/after **column spelling** (`balance_before/after`,`frozen_before/after`) — SPEC §2.3 names them generically; probes read defensively, surface an absent column.
- `callback_queue` **payout linkage** column (`source_type`/`source_id`; assumed `source_id=payout_id`) — probes filter by event + best-effort linkage and record which matched.
- `upsert_client_callback_endpoint` **reuse for `flow='payout'`** — confirmed-empirical for deposit, assumed-portable here.
- `client` table name + `enable_payout`/`min_payout`/`max_payout` **column spelling**.
- **mdr_skip trigger key**: probe deactivates the partner **wallet** (deposit-slice analogue); if the gateway keys on `mdr_profile_partners.is_active` instead, the skip leg surfaces (skip row absent) rather than silently passing.
- **over-config staging** (`p002.success_f`) assumes `mark_success` re-reads `mdr_profile_partners.percentage` at settle time (the bump-after-create then triggers). If `create_payout` *snapshots* the partner percentages too, the post-create bump won't trip the guard → the leg surfaces (no `mdr_over_allocated`) rather than silently passing; reconcile at deploy.
- **actor-triple columns** presence (SPEC §2.3 census note) — degrades to `client_id` + asserted `sub`.
- a real `pool_id` for any Mode-1 happy-path leg (the both-route negative uses a placeholder UUID; the missing/ambiguous legs need no real pool).

### Known AC gaps NOT built this slice (flagged, not silently dropped)
- **`IDEMPOTENCY_KEY_CONCURRENT_INFLIGHT` (409)** — not deterministically forceable black-box (a true in-flight collision is a timing race). Deferred; flagged for a stress-leg if the stack exposes a hold seam.
- **Whitelist collapse → `system_error` (SPEC §4.1) — EF-SEAM, not verified.** Live run (§6/RED2) showed the deployed `mark_failed` RPC *defensively rejects* a non-whitelist code (`400 invalid_failure_code_for_failed_terminal`, no transition); the SPEC's collapse-to-`system_error` is an **EF-layer normalization** in `bot-queue-mark`, which needs **bot-tier auth** (`BOT_CRED_ENC_KEY`, absent in the tester slot). `p003.failed_d` now asserts the RPC's defensive guard; the EF-layer collapse needs a `bot-queue-mark` EF leg (bbot substrate). **Routed for the orchestrator to (a) confirm the EF collapse via the bbot seam, or (b) clarify in the SPEC where the collapse lives (EF vs RPC).**
- **Settle fail-closed on a MISSING residual wallet (SPEC §3.2)** — distinct from the now-covered *over-config* fail-close (`p002.success_f`). Not built as a live leg: the readiness gate *requires* the residual wallet present, and deleting it mid-suite is unsafe on a shared stack. Covered structurally by the conservation/atomicity conjunction; flag for a targeted isolated leg.

> Note: the **over-config fail-close** (Σ active-pct > fee_pct → `RAISE mdr_over_allocated`) **IS** built this slice (`p002.success_f`) per the Q2 v2 ruling.

---

## 3. CONTRACT QUESTIONS — both RULED (SPEC v2 re-broadcast, 2026-06-12) and bound

### C1 — `claimed` vs `processing` at claim → **RESOLVED** *(I found this in my v1 cross-check)*
- **v1 tension:** SPEC §1 SM1 pinned the canonical set on **BOTH** `ts_payouts.status` AND
  `withdrawal_queue.status` with "no `claimed` row-state", and §ADR-4a SM1 (`adr.md` L600-601) says
  *"Drop `claimed` — use `processing` … no distinct `claimed` row-state"* — yet SPEC §3.1 set
  `withdrawal_queue.status='claimed'`. I surfaced it and built the v1 probe **non-binding** (recorded
  the observed value, asserted only the agreed fact).
- **v2 RULING (next-architect):** SM1's canonical set binds **`ts_payouts.status` ONLY**; the §ADR-8
  `withdrawal_queue.status` is a **separate work-lane vocabulary** that legitimately keeps a `claimed`
  state. At claim: `withdrawal_queue.status` `pending→claimed` (+`batch_id`) while `ts_payouts.status`
  `pending→processing`. SM2/SM3 lock-and-assert on `ts_payouts.status`.
- **Probe now (v2):** `p002.claim_c_wq_claimed_ts_processing` **HARD-asserts** `wq='claimed'` AND
  `ts='processing'` — the record-only hedge is dropped. **Closed.**

### Q2 — PW2 partner share-base → **RESOLVED** *(relayed by orchestrator; routed next-dev ↔ architect)*
- **v2 RULING:** conservation equation **UNCHANGED** (`payout_fee = Σ credited + residual`) with an
  explicit **`residual ≥ 0` invariant**; **`SHARE_BASE` stays `amount`** (gross-pct reading re-affirmed,
  NOT re-based to fee). **NEW:** an over-allocated profile (`Σ active-partner.pct > payout_fee_percent`
  ⇒ residual<0) is **INVALID config** — the settle **FAIL-CLOSES** (`RAISE mdr_over_allocated` + full
  rollback, payout stays `processing`), never over-credits.
- **Probes now (v2):** `SHARE_BASE` stays `"amount"` (the swappable switch I pre-built — no flip
  needed); `p002.success_b` keeps conservation + the `residual ≥ 0` assertion on the valid seed
  (Σ partner-pct ≤ fee_pct); **new `p002.success_f_over_allocated_fail_close_rollback`** stages an
  over-allocated profile (bumps a partner's pct on the payout's *actual snapshotted* profile, restores
  in `finally`) and asserts `mdr_over_allocated` raised + full rollback (stays processing, freeze intact,
  no settle/fan-out rows, no callback). Self-check adds the `over_alloc_detector` discrimination. **Closed.**
- **Substrate (FYI from re-broadcast, non-contract):** #437 gained the `residual<0` guard, a
  deterministic `create_payout` MDR-profile tiebreaker (`ORDER BY created_at, id`), and payout-valid
  seed `payout_fee_percent` (seed partners Σ 1.00% now valid); dev re-smoked green on dev-1.

---

## 4. Process notes
- De-bias held: read **only** `origin/build/payout-slice1:docs/spec/payout-core-lifecycle-slice.md`
  from the build branch; ratified epic/ADR read from this worktree (origin/main). **No `supabase/`
  source read, ever.**
- No money probes were run against staging/sinuw/any dev-N/seal slot — the suite was validated
  **purely offline** (predicate self-check + transpile/typecheck). The first live run waits on the deploy.
- Out of scope (untouched): dev implementation code; PAYOUT-004..013; merging; marking done; livegate /
  PR #433 / tunnels.

---

## 6. LIVE VERIFY RUN — tester stack `yupsev` (2026-06-12)

**Result: ✅ GREEN — 71/71 PASS, all 8 lanes GREEN. Runner exit 0.**
Stack `yupsevcrubgprsbujbpu` (substrate `20260612000120`); git_sha **`91e2497`** (= committed HEAD);
evidence `evidence/integration-run-payout-1781266973439-91e2497a.json`.

| Lane | Result | Notes |
|---|---|---|
| lane0-readiness | GREEN | 22/22 — all tables/EFs/RPCs/clock+reset/fixtures present (after the 2 rebindings below) |
| lane1-create | GREEN | 16/16 — fee=round (1.5 on 100@1.5%), freeze=gross, 200, full error catalogue, §2.4 concurrency+AM5 |
| lane2-claim | GREEN | 3/3 — **C1 v2 confirmed live**: `wq='claimed'` AND `ts='processing'`, system_bank_id + batch_id stamped |
| lane3-success | GREEN | 6/6 — settle (bal&froz each −=507.5) + PW2 (2 distribute + residual 2.5→mdr_owner, conserved, residual≥0) + callback-once + duplicate no-op + mdr_skip + **over-config fail-close (`mdr_over_allocated` + rollback, stays processing)** |
| lane4-failed | GREEN | 6/6 — release frozen-only/balance-untouched, callback, duplicate + pre-claim no-op, **non-whitelist RPC defensive guard** |
| lane5-sm2split | GREEN | 2/2 — late success from review ACCEPTED (settle once); late failed from review NO-OP (stays review, freeze intact) |
| lane6-sm3 | GREEN | 14/14 — full illegal-source matrix, benign no-op everywhere |
| lane7-am5 | GREEN | 2/2 — balance≥frozen at every step of both lifecycles |

### Readiness rebindings applied before the run (column-drift; substrate correct — brew-ops §5)
1. `mdr_profile_partners` has **`partner_id`** (not `wallet_id`) and **no `is_active`** → the partner
   wallet resolves via `wallet(owner_type='partner', owner_id=partner_id)`, and partner active-ness =
   that wallet's `is_active`. Rebound in `_spec-payout.ts` / `_flow-payout.ts` / `readiness.ts`.
2. `wallet` has **no `is_owner`** → residual wallet = `owner_type='mdr_owner'` ALONE. Rebound.
*(Also confirmed live: `ts_payouts` has no actor-triple columns — the probe degrades to `client_id`,
PASS; `wallets_change_logs` has all four before/after columns, populated.)*

### 2 probe-side fixes the live run surfaced (ground-truth-classified — substrate was correct)
- **RED1 `p002.success_a`** — the `payout_settle` row is correct on the stack (`reference_type=
  withdrawal_queue`, `reference_id=queue_id`, all four before/after populated, amount=gross). My
  `wclRows()` SELECT had **omitted `reference_type`/`reference_id`**, so the linkage re-check saw
  `undefined`. Added the columns → GREEN. *(Probe bug, not substrate.)*
- **RED2 `p003.failed_d`** — ground truth: the deployed `mark_failed` RPC **defensively rejects** a
  non-whitelist code (`400 invalid_failure_code_for_failed_terminal`, payout stays `processing`, no
  `failure_code`). The SPEC §4.1 collapse→`system_error` is an **EF-layer normalization** I drove at
  the wrong seam (RPC-direct). Re-scoped the leg to assert the RPC's money-safe guard → GREEN; the
  EF-layer collapse is **flagged as an EF-seam coverage gap** (§2 known gaps — routed). *(Probe seam, not substrate.)*

> Discipline: a RED is reported, never fixed in substrate by me. Both REDs were classified from
> ground-truth reads (a throwaway diagnostic, since deleted) as **probe-side**, and fixed probe-side;
> the one residual EF-layer claim I could not verify at the RPC seam is surfaced, not buried.
