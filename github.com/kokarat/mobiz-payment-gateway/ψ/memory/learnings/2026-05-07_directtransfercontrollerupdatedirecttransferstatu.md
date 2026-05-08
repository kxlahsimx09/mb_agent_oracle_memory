---
title: DirectTransferController.UpdateDirectTransferStatus now syncs withdrawal_queue +
tags: [technical-writer, repo:mobiz-payment-gateway, current, direct-transfer, withdrawal-queue, sse, deposit-refund]
created: 2026-05-07
source: controllers/DirectTransferController.go:771-879@68fbb18
project: github.com/kokarat/mobiz-payment-gateway
---

# DirectTransferController.UpdateDirectTransferStatus now syncs withdrawal_queue +

DirectTransferController.UpdateDirectTransferStatus now syncs withdrawal_queue + fires refund hook + emits SSE (68fbb18 #414, 2026-05-07).

`PUT /api/v1/direct-transfers/:id/status` (the "Mark Success / Mark Failed" admin-reconcile button on /direct-transfer page) used to flip only `direct_transfers.status` — leaving the matching `withdrawal_queue` row stuck and (for refund DTs) the linked deposit out of sync with the manual review.

Now after the status flip the handler also:
1. Reads the existing transfer first (404 if missing — was previously implicit via UpdateOne).
2. Syncs `withdrawal_queue` with the same status guard PayoutController uses: UpdateOne({source_id, source_type:"direct_transfer", status: $in [pending,processing,waiting_to_review]}, $set: {status, updated_at}). On `completed`/`failed` also stamps `completed_at`; on `failed` copies `input.failure_reason` → `queue.error_message`. Dispatcher-authoritative terminal rows (success/failed/cancelled) are never trampled by design. Queue-update errors are warning-logged — they don't fail the request.
3. Fires `services.SyncDepositRefundStatus` in a goroutine when `existing.transfer_type=="refund"` AND `existing.refund_for_deposit_id != nil`. Mapping: completed → "success" (deposit becomes refunded), failed → "cancelled" (deposit reverts to paid + wallet credited back). Same hook the bot's /queue/:id/success and /queue/:id/failed endpoints fire — manual and automatic review paths now stay semantically consistent.
4. Publishes a `withdrawal-queue` SSE event `status_changed` with `{source_type:"direct_transfer", source_id, status}` so the /queue admin page reflects the override without manual refresh.

Pure additive — bot-driven pending/processing/completed paths are unchanged. Existing /direct-transfers/:id/status callers (admin corrections outside the new modal) inherit the upgraded behaviour for free.

---
*Added via Oracle Learn*
