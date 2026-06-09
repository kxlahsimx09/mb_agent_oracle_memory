# pg-writer — campaign p2pdoc — CURRENT-PRODUCTION grounding for §ADR-17 (P2P matching)

Read-only grounding lens. Ground truth: Go `kokarat/mobiz-payment-gateway`@8315189 + live dpay (read-only). Full findings in worktree root `pg-writer_p2pdoc_findings.md`.

**Verdict:** ADR-17 directionally sound, but carries ONE load-bearing match-field error + THREE must-respect production constraints.

## MUST-RESPECT (next-architect):
- **F1 🔴 load-bearing (MC3/MC4):** `final_amount = amount − fee`; the withdrawer's dest account RECEIVES `final_amount` (e.g. 398.8), NOT gross `amount` (400). 100% of payouts & deposits carry a fee (payout ~0.4%, deposit ~1.8%). The POC's `deposit.amount == payout.amount` (gross==gross) is NOT the physical transfer identity. It is realizable only if the gateway lets the withdrawer receive *gross* (over-credit by the payout fee, forgoing ~0.4% of routed volume ≈ ~480K THB/38d — same order as the whole promo budget). MC3 "exact gross" must state this; MC4 "transparent" actually means withdrawer gets slightly MORE on a P2P leg. → **dpay RE-VERIFY:** re-run POC under `deposit.amount == payout.final_amount` to size the match-rate collapse.
- **F2 🟠 (MC5/Q3):** today's dest/receiver match (`slipFraudCheck.go::VerifySlipReceiverMatchesDeposit`) is FAIL-OPEN and compares a PromptPay PROXY last-4 vs `deposit.promptpay_id`. P2P has NO system-bank statement backstop (both legs bypass system bank) and matches a BANK ACCOUNT NUMBER. ADR-17 dest-match must be FAIL-CLOSED + account-number-shaped (reuse `withdrawal_queue.dest_account_last4`). Real fraud cascade grounds it: 90d scan ~905 receiver-mismatch cases / ~1.07M THB. transRef unique-index + `slip_duplicate_of` guard reusable verbatim (Q3/Q5).
- **F3 🟠 (Q5):** NO depositor KYC identity in the data model. Deposits carry only `payer_name`/`payer_account` (self-asserted from slip) + `client_username` (the merchant's client). Q5's "KYC binding + per-KYC rate-limit" assumes an identity primitive that doesn't exist; `payer_account` is the weak proxy a fraudster rotates. → **dpay RE-VERIFY:** confirm any end-customer identity is captured before Q5 rate-limit is specced.
- **F4 🟡 realism (Q4):** production models only SOURCE/system-bank caps; DESTINATION receiving ceilings unmodeled (POC caveat #5 confirmed). dpay: dest concentration is high (one acct 569 payouts; one 2.08M THB/300). P2P routes many small unknown-counterparty transfers into busy dest accounts → daily inbound-count/AML bounces, worst at the ≥5K/≥10K tail where 1:1 already misses. Independently supports Q4 "skip P2P for big amounts."

## Confirmed sound:
- `selectBank()` neighbor: deposits → least-used system bank (atomic deposit_count); payouts → withdrawal_queue + dispatcher.findBestBankForItem (`SelectBankForPayout` is DEAD/deprecated). P2P bypasses both → no system-bank touch (architect's "system bank never eats the loss" correct).
- Q2 re-enqueue lands on real `withdrawal_queue` (status pending/processing/success/failed/cancelled — no P2P hold state yet); withdraw is reserved-not-debited → release is money-safe. ✓
- Q1 EDF-FIFO: no production blocker, net-new on withdrawal_queue. ✓

Owner: 2 items need brew-ops dpay-verify (F1 match-field re-run, F3 identity capture).
