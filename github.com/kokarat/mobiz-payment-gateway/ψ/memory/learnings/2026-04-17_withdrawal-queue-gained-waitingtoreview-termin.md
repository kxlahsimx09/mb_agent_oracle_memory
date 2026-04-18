---
title: withdrawal-queue gained `waiting_to_review` terminal-but-non-final status (PR #2
tags: [technical-writer, repo:mobiz-payment-gateway, current, withdrawal-queue, payout, bank-bot]
created: 2026-04-17
source: services/withdrawalQueue.go:1049-1117@76326c0, controllers/WithdrawalQueueController.go:403-435@76326c0, routes/bot.go:33@76326c0, models/withdrawal_queue.go:27-32@76326c0
project: github.com/kokarat/mobiz-payment-gateway
---

# withdrawal-queue gained `waiting_to_review` terminal-but-non-final status (PR #2

withdrawal-queue gained `waiting_to_review` terminal-but-non-final status (PR #208, 76326c0).

Bot can now report `waiting_to_review` instead of `success` or `failed` when it is unsure whether the bank transfer actually went through (root case: SCB approver popup that times out before the bot can read confirmation). Endpoint: `PUT /api/v1/bot/queue/:id/waiting-to-review`. Body: `{ reason?: string, error_screenshot_url?: string }` — `reason` defaults to `"Bot unsure — needs manual review"`.

Behaviour of `services.MarkWaitingToReview` (services/withdrawalQueue.go:1049-1117@76326c0):
- CAS-guarded: only `processing → waiting_to_review` (returns "not found or not processing" otherwise).
- Sets `error_message`, `updated_at`, `completed_at` on the queue row.
- Mirrors `status="waiting_to_review"` onto the source document (e.g. `payouts`), so admin UIs that filter on payout status see it.
- Unlocks the bank via `onBankItemDone(SystemBankID)` so dispatch can continue.
- Publishes SSE: `withdrawal-queue/waiting_to_review`, plus `payouts/waiting_to_review` when source is a payout.
- **Does NOT update wallet balance and does NOT send a callback.** That distinction is the whole point of the new state — the system is suspended pending admin confirmation; no money moves and no merchant gets a `completed`/`failed` notification yet.

PayoutController also accepts `waiting_to_review` in `UpdatePayoutStatus` validation (PayoutController.go:510@76326c0) — admin can set it manually too.

Why this matters for callers: any frontend or downstream consumer that switches on payout/queue status must handle the new value or it will treat these items as "unknown" / hide them. The auto-reconcile path (`tryReconcileAfterMarkFailed`) is unaffected because it triggers on `MarkFailed`, not on `MarkWaitingToReview`.

---
*Added via Oracle Learn*
