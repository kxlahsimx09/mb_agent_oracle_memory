---
title: poc-ready: §ADR-4a Withdrawal Dispatch & Claim — Pass-1 PoC at `poc/4a/` (Postgr
tags: [implementation-architect, repo:mb-next-payment-gateway, next, 4a, poc, spec-test, pgtap, supabase-local, withdrawal-lane, claim-rpc, dispatcher, sweep-triage, lifecycle-rpcs, decision, poc-ready, fixture-source:vault-learning, fixture-source:repo-flow-doc]
created: 2026-05-06
source: poc/4a/{README.md, src/*.sql, tests/*.spec.sql, mutation-tests.ts} + evidence/production-shape-summary.md
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# poc-ready: §ADR-4a Withdrawal Dispatch & Claim — Pass-1 PoC at `poc/4a/` (Postgr

poc-ready: §ADR-4a Withdrawal Dispatch & Claim — Pass-1 PoC at `poc/4a/` (Postgres-only-floor; reuses local Supabase from §ADR-4b PoC).

10 spec tests across 3 groups: A claim_withdrawal_items RPC atomicity (5: bank-isolation, strict-budget, skip-locked, fifo-priority, batch-id-mirror); B one-batch-per-bank + sweep triage (3: invariant, with-tx-id→waiting_to_review, no-tx-id→failed); C sweep-never-reverts + 4-step lifecycle atomic (2). 39 assertions all green; 7 mutations all flip ≥1 expected red, 0 escapees. ADR claims hold; no drift filed.

Scope decision: Mode 2 (direct-address, `required_bank_account_id NOT NULL`) only. Mode 1 (pool-broadcast) routing delegated to fair-router EF (§ADR-8 Tier-2, deferred). Pass-7 amendment justifies — fair-router singularizes Mode 1 to direct-address before claim RPC sees the row, so Mode 2 testing covers the load-bearing claim atomicity.

Production data shape (mined 2026-05-06 via mcp__dpay__*):
- 121,386 withdrawal_queue records; 92.6% success, 5.1% failed, 1.3% waiting_to_review
- source_type split: payout 78%, pullout 21%, settlement 0.9%, direct_transfer 0.3%
- typical batch size 5-6 items
- real waiting_to_review pattern matches D6 triage exactly: bot clicked OTP-approve, browser session died mid-flight, bank may have processed → bank_transaction_id SET → admin verifies bank statement
- found typo state `cancle` in 59 rows — next-system CHECK constraint rejects (filed as drift candidate for pg-tester lane, not impl-architect)
- `wallets_change_logs` for `reference_type='withdrawal_queue'` not previously sampled — Pass 2 should verify production audit pattern

Schema: pool, pool_members, bank_account, bank_account_method (live junction per D2), withdrawal_queue (two-mode CHECK constraint per D1), ts_payouts, wallet, wallets_change_logs, callback_queue. RPCs: claim_withdrawal_items (sole pending→claimed path), sweep_stale_claims (D6 triage, never reverts), mark_failed/mark_success/mark_waiting_to_review (D7 4-step lifecycle).

Mutation iteration: M-G (drop step ii wallet refund) reds test 10 happy path AND test 08 sweep-no-tx-id — cross-test redundancy is good signal that sweep + lifecycle share the same atomic boundary. M-B (relax strict budget) reds test 02 AND test 04 (overcommit picks both rows instead of priority-bound 1) — same redundancy.

Substrate convergence: claim_withdrawal_items joins finalize_deposit + link_statement_to_deposit + match_deposits_cascade as the 4th thin RPC for state-transition writes. Pattern durable across deposit-lane + withdrawal-lane.

Known gap: `[POC_GAP:ADR-4a:concurrent-claim-test]` — true 2-connection SKIP LOCKED race not tested in single-conn pgTAP. Pass 2 candidate via Bun + postgres lib.

Next implement-architect lane candidates: §ADR-4c (deposit auto-expire — cheapest, ~3-4 tests, no MDR fan-out); §ADR-3 (full withdrawal lane with EF dispatcher + bot simulator — first to need EF runtime).

---
*Added via Oracle Learn*
