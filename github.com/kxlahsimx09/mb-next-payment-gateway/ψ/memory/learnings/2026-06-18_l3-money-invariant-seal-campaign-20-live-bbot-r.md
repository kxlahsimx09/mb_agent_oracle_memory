---
title: L3 MONEY-INVARIANT SEAL — campaign 20-live-bbot, run requestId `live-bbot-rerun-
tags: [next-investigator, repo:mb-next-payment-gateway, next, verify, epic-seal, l3, seal, live-test, money-invariant, 20-live-bbot, conservation, idempotency, fifo, cross-client-park, frozen-ledger, harness-patch-trap]
created: 2026-06-18
source: RAW Postgres recompute (sinuwgsqqyqzlpaavimf service-role PostgREST) — run live-bbot-rerun-1781764891, code git-sha 81872fd (merged main #585-#588)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# L3 MONEY-INVARIANT SEAL — campaign 20-live-bbot, run requestId `live-bbot-rerun-

L3 MONEY-INVARIANT SEAL — campaign 20-live-bbot, run requestId `live-bbot-rerun-1781764891` (suffix 81764891), full bbot LIVE journey off MERGED main #585–#588, deployed stack `sinuwgsqqyqzlpaavimf`. Independent recompute from RAW gateway Postgres via service-role PostgREST (NOT harness booleans, NOT dpay/Mongo). Harness self-reported 20 GREEN / 2 SKIP — I did not trust it; this is the verdict.

VERDICT: MONEY-SAFE-GREEN — merged-main regression gate PASSED. Zero money violations.

Raw dataset (whole-stack reset pre-run): 10 deposits, 5 payouts, 42 wallets_change_logs, 10 mdr_shared, 15 callback_queue, 25 callback_attempts, 15 idempotency_keys, 11 bank_statements. Per-leg request_ids are self-describing (R3 Task A portal-readable refs).

FOUR INVARIANTS (all HOLD to the satang, 0 violations):
1. CONSERVATION (NET+ΣpartnerMDR+residual=GROSS): all 5 paid deposits exact — L1b 817.02+8.32+6.66=832.00; L1f-2 468.41+4.77+3.82=477.00; L1f-3 854.34+8.70+6.96=870.00; L1g2-a 492.96+5.02+4.02=502.00; L2c 818.01+8.33+6.66=833.00. fee=distribute+residual each. mdr_shared (5×2 partners) = ledger mdr_distribute.
2. EXACTLY-ONE-CALLBACK: every (source,event) dedup_key = exactly 1 callback_queue row. deposit.paid payload.amount byte-matches deposit GROSS (=matched bank_statement amount). 4 deposit.paid delivered 2xx; L2c deposit.paid dead-lettered ON PURPOSE (failing endpoint → §ADR-15 must-page). No duplicate deliveries.
3. balance≥frozen (& frozen≥0): DB CHECK-enforced (wallet_balance_gte_frozen, structurally impossible to violate) + independently min(available)=49932.82≥0; client-002 frozen chain 0→0; wallet.frozen=0 final.
4. MONEY-IN/OUT-ONCE: each paid deposit exactly 1 deposit_credit (= final_amount); each payout exactly 1 freeze + (1 settle | 1 unfreeze); no double-move.

R3 LEGS:
- L1g2-degenerate-fifo (§FA1 same-client, amount 502): OLDEST a-old (created 06:44:01)→paid, matched, 1 deposit_credit=492.96; NEWER b-new (06:44:04)→0 credit, unmatched. Matched statement match_status=matched (NOT review), matched_request_id=L1g2-degen-a-old-81764891, candidates=[]. FIFO-oldest, no double-credit. (Nuance: charge expected newer='pending'; raw shows 'expired' — never matched then TTL-expired by run-end; 0-credit money-safety identical, benign end-state label.)
- L1m-deposit-idem (client 002): exactly 1 deposit row (L1m-deposit-idem-81764891), 0 credit (expired); idempotency_keys exactly 1 completed row key=idem-dep-81764891 (deposit-create 201). Replay→no dup/no credit; diff-body→no resource.
- L4k-payout-idem (client 002): exactly 1 payout row PAY81764891IDEM, 1 payout_freeze (frozen 0→1616.90→0, frozen-once not doubled), success; idempotency_keys exactly 1 completed row key=idem-pay-81764891 (payout-create 200). Replay→no dup; diff-body→no resource.
- L1g cross-client park (cl002 vs cl003, amount 823): both candidates 0 deposit_credit, 0 deposit.paid callback (only benign terminal deposit.expired, dead-lettered); statement d72a878a amt 823 IN match_status=review, matched_request_id=null, 2 candidates populated. Money-safe park, no wallet move on either.

KEY TRAP / METHOD NOTE: wallet.balance is HARNESS-managed — journey-tri-epic.ts:ensureFunded + per-payout funding directly PATCH wallet.balance via REST (bypassing the ledger), so the cross-operation balance snapshots in wallets_change_logs do NOT form a continuous chain (decode as 50000+payout-amount). This is documented test scaffolding, NOT a gateway double-move. Do NOT flag it as a violation. The TRUE payout money-safety proof is the `frozen` chain (frozen_before/frozen_after) — pure gateway logic, never PATCHed — which chains perfectly 0→0. Verify payouts on frozen, not balance.

---
*Added via Oracle Learn*
