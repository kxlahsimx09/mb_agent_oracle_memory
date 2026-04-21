---
title: Flow: payout-admin-cancel — admin-discretion cancel terminal for pending payouts
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, payout-admin-cancel, payout, admin-cancel, wallet-refund, withdrawal-queue, callback, reverse-engineered, ratification-pending, s4]
created: 2026-04-21
source: docs/flows/payout-admin-cancel.md@aff85e1
project: github.com/kokarat/mobiz-payment-gateway
---

# Flow: payout-admin-cancel — admin-discretion cancel terminal for pending payouts

Flow: payout-admin-cancel — admin-discretion cancel terminal for pending payouts. A JWT-authenticated admin with `payout:approve` permission invokes `PUT /api/v1/payouts/:id/cancel` to stop an in-flight payout before the bot claims its withdrawal-queue row. The gateway reads the queue row first and hard-rejects with 400 if the bot is already `processing` (admin cannot override in-flight bank transfers through this endpoint). If the queue row is `pending`, the gateway CAS-cancels it, publishes an SSE, then CAS-flips `ts_payouts` from `pending` to `cancelled` with admin audit fields, refunds `amount + payout_fee` to the client wallet via `$inc`, writes a `wallets_change_logs` row with `operation=add` and `reference_type=payout`, publishes a second SSE on the `payouts` channel, and spawns an async goroutine that fires a `payout.cancelled` HMAC-signed webhook to the client's `callback_url`.

Sibling to `payout-auto-cancel-pending-timeout` (scheduler-triggered) and mutually exclusive with `payout-confirm-completed` (which reverses `failed|waiting_to_review → completed` — this flow drives `pending → cancelled`). The dedicated-endpoint invariant is load-bearing: PR #228 explicitly removed `cancelled` from `UpdatePayoutStatus`'s validator so that only `CancelPayout` can drive the transition, preventing the earlier double-refund hazard where both the generic status handler and a queue-initiated refund could touch the same wallet row. The payout row is terminal on reaching `cancelled` — no admin endpoint reverses it at HEAD `aff85e1`.

Four open drift questions folded into Oracle ratification thread #34, all paired with sibling flow rulings: (a) non-transactional write sequence — drift, should fold into the same transactional-refactor PR as `payout-auto-cancel-pending-timeout` (a); (b) queue-cancelled-but-payout-not-pending race window — likely "narrow, not drift" if (a) lands; (c) blind wallet `$inc` with silent failure mode — drift, same shape as sibling (b); (d) callback not resend-safe on goroutine-kill — regression-candidate, scope-extends the existing unified callback-resend-with-idempotency learning to a third rail.

Reverse-engineered from `controllers/PayoutController.go:913-1079@aff85e1` + `routes/payout.go:31@153a4f6` + `services/callbackService.go:176-268@aff85e1`. Endpoint introduced PR #228 (`153a4f6`, 2026-04-19). Current-system.md §3.2.3 already documented at code level; this flow doc adds intent-level framing (admin semantics, actor contract, relationship to sibling cancel/confirm paths). Claim strength S4 until thread #34 ratifies.

---
*Added via Oracle Learn*
