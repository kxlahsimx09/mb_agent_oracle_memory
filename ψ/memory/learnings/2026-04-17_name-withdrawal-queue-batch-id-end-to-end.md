---
title: withdrawal_queue.batch_id — mirrored onto source docs on bot claim
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - withdrawal-queue
  - bot
source: controllers/WithdrawalQueueController.go:483-498@ed45b7e, services/withdrawalQueue.go@ed45b7e, models/withdrawal_queue.go:76@ed45b7e
created: 2026-04-17
project: github.com/kokarat/mobiz-payment-gateway
---

# withdrawal_queue.batch_id — mirrored onto source docs on bot claim

## Pattern

`models/withdrawal_queue.go:76` added field `BatchID string` (PR #193). On every `POST /api/v1/bot/queue/claim` call, the controller stamps the same `batch_id` onto every item claimed in that call **and** mirrors it onto the matching source document (`ts_payouts`, `pullout_logs`, `direct_transfers`, `settlements`) via the `CopyBatchIDToSource` helper added in PR #194.

The response body now carries a top-level `batch_id` alongside the items array.

## Why

Operator debugging: "which payouts went out on the same SCB approver login?" previously required cross-referencing timestamps. Now every source document carries the claim-batch id, so a single query gives the set.

## How to apply

- When reconstructing an incident, group by `source_doc.batch_id` to see the claim-batch.
- New integrations that read `ts_payouts` (etc.) gain a `batch_id` field they may not have expected — not a breaking change (the field is absent for pre-2026-04-16 rows).
- The field is **not** the same as `request_id` — `request_id` identifies a single transaction, `batch_id` identifies the bot-claim call that picked it up.
