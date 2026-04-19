---
title: drift — flow:payout-request (a) wallet refund-on-DB-insert-failure has no wallet
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, followup, flow, payout-request, audit-log, wallets-change-logs, payout]
created: 2026-04-18
source: controllers/PayoutRequestController.go:411-422@4e84ad5 + thread #8
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — flow:payout-request (a) wallet refund-on-DB-insert-failure has no wallet

drift — flow:payout-request (a) wallet refund-on-DB-insert-failure has no wallets_change_logs row.

Location: controllers/PayoutRequestController.go:411-422 @ 4e84ad5.

What happens: Step 3 of the payout flow atomically deducts the client wallet (amount + fee) and writes a wallets_change_logs row with operation="payout", reference_id=payoutID. If the subsequent ts_payouts InsertOne (Step 4) fails, the controller calls helpers.AtomicBalanceAdd to refund the deduction — but writes NO matching audit row. The Step 3 deduction therefore stays in wallets_change_logs unmatched by any reversal, pointing at a payoutID that was never persisted to ts_payouts.

What every other refund path does: writes a paired wallets_change_logs row with operation="payout_refund" (services/withdrawalQueue.go:1349 for bot-failed refund; controllers/PayoutRequestController.go:702-721 for the legacy unreachable cancel handler; the same pattern for settlement_refund at services/withdrawalQueue.go:1412). This is the only refund path that does not.

Author awareness: TODO comments at controllers/PayoutRequestController.go:417-418 explicitly call out the missing alerting + failed_refunds reconciliation collection. The path is recognised as incomplete.

Human ruling (2026-04-18, Oracle thread #8): "(a),(b),(c) เป็นช่องโหว่ที่ควรจะแก้ภายหลัง" — drift / coverage gap, fix later, not intentional design.

Recommended minimum fix: insert a wallets_change_logs row in the refund branch with operation="payout_refund", reference_id=payoutID (same id used for the deduction row), changed_by="system", and a note like "Refunded due to ts_payouts insert failure: <error>". Pairs the audit log without changing the wallet semantics. ~10 LoC.

Source: docs/flows/payout-request.md@a91cb76 §Resolved questions (a) + controllers/PayoutRequestController.go:411-422@4e84ad5
W8 root trace: ba99f3b3-6e59-4348-8878-f180a1fee17e
Ratification thread: #8
Queued for: W4 reconciliation pass.

---
*Added via Oracle Learn*
