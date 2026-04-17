---
name: wallet_change_logs — reference_id links client deduction to partner MDR credits
description: As of 2026-04-16 (PR #171), wallet_change_logs carries reference_id + reference_type fields. Rows written before that date have both empty. Frontend /wallet-change-logs pairs rows sharing reference_id into a coloured row group.
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - wallet
  - payout
  - mdr
  - audit-trail
source: models/wallet_change_logs.go:23-29 @ 3b7e0f1; controllers/PayoutController.go:666-668,867-869 @ 3b7e0f1; services/withdrawalQueue.go:109 @ 3b7e0f1
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

# wallet_change_logs — reference_id links client deduction to partner MDR credits

## Fact

`models.WalletChangeLog` gained two optional fields on 2026-04-16 (`f300c47`, PR #171):

- `ReferenceID primitive.ObjectID bson:"reference_id,omitempty"`
- `ReferenceType string bson:"reference_type,omitempty"` — values observed: `payout`, `topup`, `settlement`, `deposit`.

Both are populated wherever we already write a payout-related change log:

- `controllers.PayoutController.UpdatePayoutStatus`: MDR partner-credit loop AND the `failed`-branch refund both set `reference_id = objectID` (the payout `_id`).
- `controllers.PayoutRequestController.CreatePayout`: client wallet deduction entry. To enable this, the payout `ObjectID` is now generated up front (`primitive.NewObjectID()`) before the struct literal so it can be referenced in the deduction log written before `payout.InsertOne`.
- `services.distributeMDRFees`: every partner row gets the source document's `_id` as `reference_id`, `reference_type` set per source.

Records written before the upgrade have both fields empty. Frontend renders: rows that share a `reference_id` get a coloured border/group; rows without `reference_id` render as a flat entry.

## Why

`/wallet-change-logs` is sorted by `created_at`, so a payout deduction and its partner MDR credits appear on adjacent rows but had no visible link to each other. When two payouts happened in the same second the rows interleaved and ops could not tell which MDR pair went with which payout.

## How to apply

- When adding a new payout/topup/settlement wallet-mutation path, populate both fields. Never leave `ReferenceID` zero on a row that has an obvious owner.
- When writing a migration that back-fills `reference_id`, lean on the `CreatedAt` proximity plus the wallet owner to pair rows. Do not over-pair — an orphan row is better than a wrong pair.
- `ReferenceType` is free-form string today — do not introduce a fifth value without updating the front-end visualisation code that maps types to colours.

## Trace

commit `3b7e0f1` (specifically `f300c47` #171) → docs/current-system.md §2 (WalletChangeLog row) + §4 item 8 → resolution PR #173
