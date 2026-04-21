---
title: drift — payout-auto-cancel-pending-timeout (b) CancelBySource return value silen
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, followup, flow:payout-auto-cancel-pending-timeout, error-handling, silent-error, queue, double-spend-risk]
created: 2026-04-21
source: docs/flows/payout-auto-cancel-pending-timeout.md + scheduler/payout_expiry.go:183@74689ec + services/withdrawalQueue.go:1148-1174,1049-1117@74689ec + thread #31 closed 2026-04-21
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — payout-auto-cancel-pending-timeout (b) CancelBySource return value silen

drift — payout-auto-cancel-pending-timeout (b) CancelBySource return value silently discarded. At `scheduler/payout_expiry.go:183`: `_ = services.CancelBySource("payout", payout.ID)`. If the `UpdateMany` on `withdrawal_queue` errors (Mongo transient, context timeout), the queue row stays `pending` — dispatcher could then assign it to a bank and bot could execute the transfer, while `ts_payouts.status` is already committed to `cancelled` and the client wallet has been refunded. Potential double-spend path. Ratified via Oracle thread #31 on 2026-04-21 as drift — should fix. Quick-win fix: log the error so ops can alert on it — `if err := services.CancelBySource("payout", payout.ID); err != nil { log.Printf("[PayoutExpiry] WARN: CancelBySource failed for payout %s: %v", payout.ID.Hex(), err) }`. Full fix: if paired with (a)'s atomic-transaction scope, the queue-cancel error will abort the transaction and leave the payout pending — solving (b) by construction. Downstream question not hand-traced: the `MarkSuccess` branching for a `source.status=cancelled` payout row in `services/withdrawalQueue.go:getSourceStatusUpdate:1049-1117` — if the bot still reports success on an orphan queue row, the source-status-update path's behavior for a cancelled payout is `[UNVERIFIED]` and should be traced as part of the fix. Queued for W4 pickup.

---
*Added via Oracle Learn*
