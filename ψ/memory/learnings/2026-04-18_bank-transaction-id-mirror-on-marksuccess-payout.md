---
title: bank_transaction_id is now copied onto ts_payouts on MarkSuccess (payout source only)
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - payout
  - withdrawal-queue
  - bank-bot
created: 2026-04-18
source: services/withdrawalQueue.go:1261-1271@dfafa78
related: []
project: github.com/kokarat/mobiz-payment-gateway
---

# bank_transaction_id is now copied onto ts_payouts on MarkSuccess (payout source only)

Commit `dfafa78` (#213, 2026-04-18) extends `services.getSourceStatusUpdate` so that when a `withdrawal_queue` item of `source_type = payout` is marked `success`, the `$set` update on the source `ts_payouts` row now includes the queue item's `bank_transaction_id` (as long as it is non-empty). Prior behavior: the transfer ID lived only on the `withdrawal_queue` row and the admin payout list had to join to find it.

## Code-level shape at HEAD

```go
case models.SourceTypePayout:
    now := time.Now()
    if result == "success" {
        update := bson.M{
            "status":             "completed",
            "completed_at":       now,
            "completed_date_bkk": helpers.GetDateTimeBKK(),
            "updated_at":         now,
        }
        if item.BankTransactionID != "" {
            update["bank_transaction_id"] = item.BankTransactionID
        }
        return bson.M{"$set": update}
    }
    return bson.M{"$set": bson.M{"status": "failed", "failed_at": now, "updated_at": now}}
```

## Scope limits

- **Payout source only.** `SourceTypeSettlement`, `SourceTypeDirectTransfer`, `SourceTypePullOut` branches of `getSourceStatusUpdate` are unchanged. If the requirement extends to those source types later, it's a separate commit.
- **Only on the "success" result.** The failed-result branch still only writes `status="failed", failed_at, updated_at` — no bank_transaction_id copy.
- **Two write paths.** `bank_transaction_id` is now populated on `ts_payouts` from two distinct paths:
  1. Bot → `PUT /bot/queue/:id/success` with body `{bank_transaction_id, bank_reference}` → this commit's path (via `getSourceStatusUpdate`).
  2. Admin → `PUT /payouts/:id/confirm-completed` with body `{reason, bank_transaction_id?}` → `setFields["bank_transaction_id"] = input.BankTransactionID` at `controllers/PayoutController.go:1679-1681`.
- Both paths set the same field. Neither path overwrites the other inside a single payout lifecycle (the queue item and the confirm-completed are mutually exclusive by status).

## Docs updated (docs/current-system.md @ b886cc4 post-W2)

- §3.4 Bot-secret protected — `/queue/:id/success` bullet now notes the payout-source mirror.
- §6.1 Withdrawal queue — MarkSuccess bullet notes the payout-source mirror.
- §2 Payout row — notes `bank_transaction_id` is now populated from two paths.

No drift filed — commit is additive and internally consistent with the existing `setFields["bank_transaction_id"]` path in confirm-completed.
