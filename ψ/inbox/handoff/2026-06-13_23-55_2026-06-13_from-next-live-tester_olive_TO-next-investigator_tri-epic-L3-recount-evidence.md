## next-live-tester (olive) → next-investigator: TRI-EPIC LIVE evidence ready for the L3 §9 recount

**The harness RUNS + frames; it does NOT grade. You own PASS/FAIL via the raw-table recount (§ADR-21).** Owner-GO was granted for all three epics (Mode SIM). Run completed 2026-06-13 on LIVE-mode staging **sinuw** (`sinuwgsqqyqzlpaavimf`, main HEAD).

### The three evidence sets (L3 join keys = the per-act X-Request-Id)
Under `poc/integration/evidence/live/<epic>/<requestId>/` (manifest.json + legs.json + per-beat NNN_*.{json,png} + video/ + trace.zip):
- **AUTH**  REQ-AUTH = `4ee11470-0dc1-4d04-afe6-3e459f33ee05`  (15 frames)
- **DEPOSIT** REQ-DEP = `3a1d4b8c-105b-4c25-8b15-877c57010756`  (16 frames) — golden deposit `afa2ee01-d6f3-4391-bcd1-db13fcbda18c`
- **PAYOUT** REQ-PAY = `d57ef134-8335-48e6-908a-4ece617b5b32`  (15 frames)
Cast namespace `0117e000-…` (C1=…0c11…0001). Payouts: request_id like `OLIVE-%-d57ef1`.

### Harness self-report (NOT the verdict — your recount is)
- AUTH 6 GREEN / 2 AMBER / 0 RED · DEPOSIT 8G / 4A / 1R · PAYOUT 8G / 6A / 0R.

### §9 invariants to recompute (the point of your pass)
1. **Conservation** — for the II.2 match deposits (PROFILE-A=40000+, PROFILE-B=30000+ per-run-unique) and the III.2/III.9 payouts: `NET + Σpartner_MDR + residual = GROSS/fee` from raw `wallets_change_logs`. NOTE: payout **settle** rows key on `reference_type='withdrawal_queue', reference_id=queue_id` (mark_success body); **freeze/distribute/clawback** key on `reference_type='ts_payouts', reference_id=payout_id` — read BOTH. III.9 self-reported Σclawback=30 + residual=10 = fee 30.
2. **Exactly-one callback** per terminal event, byte-matching the move.
3. **balance ≥ frozen** always.
4. **Money in/out once** — no double-credit/debit (F-DEP-i dup-credit=0 GREEN; F-PAY-i double-reverse-blocked GREEN).

### Non-GREEN legs — my characterization (verify independently; none are confirmed deployed money-safety bugs, 0 RED in the money lanes)
- **DEPOSIT F-DEP-ii AMBER / F-DEP-iii RED (callback retry/dead-letter):** ENVIRONMENTAL — the deployed `mock-merchant` EF receiver always-200s (/flaky,/fail don't fail); the local failing receiver needs a cloudflared tunnel that won't establish on this fleet host. Gateway at-least-once + dead-letter is seal/probe-covered. NOT a gateway bug.
- **DEPOSIT II.4 force-approve AMBER:** deployed returns **400 V2_FRAUD** (not the design's 409 AU1_REFUSED) without the marker — it DID refuse; code-shape nuance.
- **DEPOSIT II.1 idempotency AMBER:** same-key replay didn't echo the same deposit id (diff-body=409 correct) — recheck the idempotency-key semantics.
- **DEPOSIT II.7 cancel AMBER:** deposits-cancel 401 (X-Client-Id clientAuth model — harness auth-contract nuance).
- **PAYOUT III.3 fail / III.8 correction AMBER:** the 'failed' bot-verdict didn't land (payout stuck `pending`) due to **batch-claim FIFO contention** (`claim_withdrawal_items` grabs older sibling pendings when many payouts share the primary bank); III.8 correct then 409'd (source not failed). HARNESS claim-targeting limit; deployed mark_failed works (III.4 review→failed GREEN).
- **PAYOUT III.11 conservation AMBER (C1 drift):** likely the stuck-pending fail-path payouts holding frozen during the snapshot — recompute to the satang.
- **PAYOUT III.5 auto-reconcile AMBER:** review→review (sweep_payout_reconcile didn't flip) — check the outbound-statement amount/tolerance + sweep lookback.
- **PAYOUT F-PAY-ii shortfall AMBER:** no shortfall row — the deployed MDR profile selection is **global-oldest** (`create_deposit`/payout ORDER BY created_at LIMIT 1), so the run's partners ≠ my PT2; draining PT2 didn't create a clawback. Same reason II.2 shows mdr_skip=0 (PT3-inactive→residual NOT exercised). Deployed profile-selection note for the architect.
- **AUTH I.8 step-up / I.1 enrolment AMBER:** AUTH-007 has ZERO deployed call sites (S2 Phase-2-deferred — honest, not false-green); I.1 factor-verify inconclusive.

Findings detail: `next-live-tester_olive_findings.md` (worktree root). Out-of-scope respected: no supabase/ or src/ edits, no deploy, nothing marked done. Over to you for the authoritative L3 recount → then owner reads the L4 card → writes the three live_signoff rows.