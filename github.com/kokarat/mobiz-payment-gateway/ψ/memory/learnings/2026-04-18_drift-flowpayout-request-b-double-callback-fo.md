---
title: drift — flow:payout-request (b) double callback for the same payout via post-fai
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, followup, flow, payout-request, callback, auto-reconcile, race-condition, api-contract, withdrawal-queue]
created: 2026-04-18
source: services/withdrawalQueue.go:983-985,1000-1047@4e84ad5 + thread #8
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — flow:payout-request (b) double callback for the same payout via post-fai

drift — flow:payout-request (b) double callback for the same payout via post-fail auto-reconcile.

Location: services/withdrawalQueue.go:983-985 (goroutine spawn) + :1000-1047 (tryReconcileAfterMarkFailed body) @ 4e84ad5.

What happens: When a bot reports PUT /bot/queue/:id/failed, services.MarkFailed runs an atomic Mongo txn flipping queue+payout to failed, then SYNCHRONOUSLY calls processPostCompletion(item, "failed") which sends the EventPayoutFailed callback and refunds the client wallet (amount + fee). AFTER processPostCompletion returns, MarkFailed spawns a goroutine `go tryReconcileAfterMarkFailed(item)`. That goroutine looks up bank_statements by matched_queue_id + match_status="matched" + matched_request_id=item.RequestID; if a row is found AND its description contains the request_id, it calls ReconcileFailedPayoutToCompleted (flips payout failed → completed, deducts wallet again, distributes MDR), then sends a SECOND callback with EventPayoutCompleted. Result: the client integration receives `failed` followed by `completed` for the same txnId.

Why removing tryReconcileAfterMarkFailed isn't an option: the comment at services/withdrawalQueue.go:973-985 cites a real incident (PAY1776286617S2B53L on 2026-04-16 — statement scraped at 21:00:54 UTC while item still processing, bot timed out at 21:07:19 and marked failed; without auto-reconcile the wallet stayed refunded but the bank actually transferred). The function exists to plug a real money-loss bug.

PR #189 (commit 052c382, 2026-04-16+) narrowed the trigger by adding the request_id gate in the matcher so only confidently-matched statements fire the auto-reconcile. The narrowing reduces false-positive frequency but does NOT change the dispatch shape (two callbacks remain possible).

Human ruling (2026-04-18, Oracle thread #8): drift / undocumented contract, fix later. The current behaviour is operationally Contract B (eventual consistency with corrections — last callback within N minutes is authoritative) but no public API doc declares this contract. Merchants integrate without knowing the race exists.

Recommended fix (lightest first):
1. Add `is_correction: true` (or equivalent) flag to the second callback so client integrations can distinguish it from the first. Estimated <30 LoC + API doc update.
2. Document the contract in /api-docs and the merchant onboarding guide so integrators know to expect possible correction callbacks.
3. (Heavier alternative) Redesign dispatch via an intermediate `pending_reconcile` payout status with a 30s reconcile window — single callback per payout. Trade-off: refund delayed by reconcile window. Estimated several hundred LoC + behaviour change.

Related: thread #2 (PR #189 request_id gate: sufficient to un-hold PR #179/#180) — a tester-side question about whether the same gate is sufficient to un-hold the test_payout_confirm_completed and test_payout_auto_reconcile PRs. Same race, different consumer.

Source: docs/flows/payout-request.md@a91cb76 §Resolved questions (b) + services/withdrawalQueue.go:971,983-985,1000-1047@4e84ad5
W8 root trace: ba99f3b3-6e59-4348-8878-f180a1fee17e
Ratification thread: #8
Queued for: W4 reconciliation pass; cross-reference with thread #2 (tester domain).

---
*Added via Oracle Learn*
