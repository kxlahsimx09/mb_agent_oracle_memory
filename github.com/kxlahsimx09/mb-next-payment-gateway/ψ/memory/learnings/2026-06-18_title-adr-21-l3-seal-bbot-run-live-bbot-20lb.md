---
title: title: "§ADR-21 L3 seal — bbot run live-bbot-20lb-r3-1781745519 MONEY-SAFE-GREEN
tags: []
created: 2026-06-18
source: raw sinuwgsqqyqzlpaavimf tables + evidence/live/bbot/live-bbot-20lb-r3-1781745519
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# title: "§ADR-21 L3 seal — bbot run live-bbot-20lb-r3-1781745519 MONEY-SAFE-GREEN

title: "§ADR-21 L3 seal — bbot run live-bbot-20lb-r3-1781745519 MONEY-SAFE-GREEN (cross-client L1g park)"

next-investigator FINAL L3 money-invariant recompute, done INDEPENDENTLY from raw gateway Postgres sinuwgsqqyqzlpaavimf (service-role read-only; tables ts_deposits/ts_payouts/wallets_change_logs/bank_statements/callback_queue/withdrawal_queue), keyed by single X-Request-Id. Harness self-report (16 GREEN/2 SKIP) NOT trusted. Independence check: deposit time-window count (7) == request_id count (7).

VERDICT: MONEY-SAFE-GREEN — all 4 money invariants HOLD to the satang.

INV1 conservation: 4 paid deposits GROSS=NET+ΣpartnerMDR+residual, residual-to-zero 0.00 each (711=698.20+7.11+5.69; 802=787.56+8.02+6.42; 634=622.59+6.34+5.07; 712=699.18+7.12+5.70). 3 payouts freeze=amount+fee=settle-debit, MDR=fee (1225.11/1518.44/1489.01). L4f 967.30 freeze→unfreeze net-zero.
INV2 exactly-one callback: 11 rows / 11 sources, zero dup. 
INV3 balance≥frozen: 0 violations (peak frozen 4232.56 vs balance 54170.00).
INV4 in/out exactly once: each paid deposit 1 credit; each payout 1 settle; parked/expired 0 rows.

L1g CROSS-CLIENT PARK CONFIRMED 0-credit-both: bank_statements d496f29d (647.00,in) match_status='review', matched_request_id=null, match_candidates=2 spanning DISTINCT clients (pkA 546bc273 Client B/…0002, pkB ebd5a5f6 Client C/…0003). Both expired, is_matched=f, matched_statement_id=null, 0 deposit_credit, 0 wallet move, NO deposit.paid (only deposit.expired). Client …0003 wallet pristine 50000.00/frozen 0.

GOTCHA recorded: on this test substrate the client-…0002 wallet has TWO balance step-ups with NO wallets_change_logs row (52108.35→54170.00 pre-payout; 49937.44→50953.00 pre-L4f) and client_topups empty — these are harness SETUP funding seeds (direct service-role balance set, §ADR-21) to fund payout legs, NOT business ops; they create no phantom credit/debit and don't touch the 4 invariants (which are computed over ledgered ops). On a PRODUCTION ledger an out-of-ledger balance set would itself be a finding; on the live-test substrate it is expected. When recomputing INV1/INV4, scope to ledgered deposit/payout operations, not absolute balance-trail continuity.

Also: payout settle reconciliation must use a NON-fanned query — joining ts_payouts→withdrawal_queue→change-logs AND the payout MDR rows multiplies the settle row (1225.11×4=4900.44 artifact). Verify settle debits one-row-per-withdrawal.

tags: next-investigator, repo:mb-next-payment-gateway, next, verify-live, l3, epic-seal, bbot, cross-client-park, gotcha
source: poc/integration/evidence/live/bbot/live-bbot-20lb-r3-1781745519/ + raw sinuw tables (read-only)

---
*Added via Oracle Learn*
