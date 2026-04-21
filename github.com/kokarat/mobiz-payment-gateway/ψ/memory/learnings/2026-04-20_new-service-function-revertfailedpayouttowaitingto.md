---
title: New service function RevertFailedPayoutToWaitingToReview (services/payoutReconci
tags: [technical-writer, repo:mobiz-payment-gateway, current, payout, reconciliation, waiting-to-review, service-api]
created: 2026-04-20
source: services/payoutReconciliation.go:286-419@d01d9b2, services/withdrawalQueue.go:1000-1040@d01d9b2
project: github.com/kokarat/mobiz-payment-gateway
---

# New service function RevertFailedPayoutToWaitingToReview (services/payoutReconci

New service function RevertFailedPayoutToWaitingToReview (services/payoutReconciliation.go:286-419@d01d9b2, PR #249, 2026-04-20). Semantic counterpart to ReconcileFailedPayoutToCompleted; both live in the same file and share ReconcileOptions + sentinel errors (ErrPayoutNotFound, ErrPayoutNotFailed, ErrPayoutAlreadyReconciled). Called today only by tryReconcileAfterMarkFailed in services/withdrawalQueue.go when the post-fail matcher finds a statement by amount+last4 but the description does NOT contain the literal RequestID (e.g. SCB statements that only carry the recipient name). Behavior in a Mongo session transaction: (1) refuse if status != failed or if confirm_completed_reason already set; empty Reason is an error before touching DB; (2) ts_payouts: status→waiting_to_review, clear failed_at/completed_at/completed_date_bkk, optionally set bank_transaction_id from opts.BankTransactionID (usually matched statement's _id hex); (3) wallets (client): $inc balance/available by -(amount + payout_fee) with balance >= totalDeduct guard — undoes MarkFailed's refund so the wallet matches the state /payouts/:id/confirm-completed expects for waiting_to_review source rows; (4) wallets_change_logs: one payout_revert_to_review entry; (5) withdrawal_queue: flip source_type=payout row to waiting_to_review, clear failed_at, set error_message. Does NOT fan out MDR, does NOT mark queue success, does NOT fire EventPayoutCompleted — those belong to confirm-completed once admin verifies the bank statement. Publishes payouts/waiting_to_review SSE via the caller.

---
*Added via Oracle Learn*
