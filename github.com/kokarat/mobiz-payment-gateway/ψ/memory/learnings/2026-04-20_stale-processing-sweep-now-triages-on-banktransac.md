---
title: Stale-processing sweep now triages on bank_transaction_id (PR #249, 8bf3a52, 202
tags: [technical-writer, repo:mobiz-payment-gateway, current, withdrawal-queue, stale-sweep, waiting-to-review, invariant, thread-22-ratified]
created: 2026-04-20
source: scheduler/withdrawal_dispatcher.go:768-800@d01d9b2, PR #249 8bf3a52
project: github.com/kokarat/mobiz-payment-gateway
---

# Stale-processing sweep now triages on bank_transaction_id (PR #249, 8bf3a52, 202

Stale-processing sweep now triages on bank_transaction_id (PR #249, 8bf3a52, 2026-04-20). The 10-minute `releaseStaleLocksIfNeeded` in scheduler/withdrawal_dispatcher.go no longer blindly calls MarkFailed on every stale `processing` queue item. When `bank_transaction_id != ""` — i.e. the bot already posted /set-txn-id, meaning the maker submitted the transfer to the bank — it now calls MarkWaitingToReview instead. Rationale: MarkFailed triggers the wallet-refund path, which double-credits the client if the bank actually processed the transfer. Empty bank_transaction_id (bot crashed before submit) still takes the original MarkFailed branch. This upholds the "failed is proof-negative-only; uncertainty belongs in waiting_to_review" invariant ratified via Oracle thread #22. Observed incident that motivated the fix: payout PAY1776690030PRNZFA, 2026-04-20 20:03:18 bot /set-txn-id with TRANSFERd6759b07…, bot then stalled, stale sweep at 20:12:58 marked failed + refunded wallet, but bank statement later confirmed money actually left the account; admin manually ran confirm-completed at 20:23:05.

---
*Added via Oracle Learn*
