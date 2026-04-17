---
title: drift — Payout bson tags are camelCase while other models use snake_case
name: drift — Payout bson tags are camelCase while other models use snake_case
description: models/payout.go:89-91 uses bson:"createdAt" / bson:"updatedAt" (camelCase). Most other models use snake_case. This caused a silent production bug once (payout_expiry.go:126-128 self-documented).
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - payout
  - data-model
  - drift
source: models/payout.go:89-91 + scheduler/payout_expiry.go:126-132 @ 379e984
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-15
---

# DRIFT — Bson tag convention inconsistency on Payout

## Fact

`models/payout.go:89-91`:
```go
CreatedAt  time.Time `json:"created_at,omitempty" bson:"createdAt,omitempty"`
UpdatedAt  time.Time `json:"updated_at,omitempty" bson:"updatedAt,omitempty"`
```

Compare to `models/wallets.go:22`:
```go
CreatedAt time.Time `json:"created_at,omitempty" bson:"created_at,omitempty"`
```

The inconsistency once caused a scheduler bug documented in `scheduler/payout_expiry.go:126-132`:

> Note: bson tag on Payout.CreatedAt is `createdAt` (camelCase).
> The previous filter used `created_at` (snake_case) which matched
> zero records, so auto-cancel never fired in production.

## Why it matters

- Any new filter against `ts_payouts.created_at` (via snake_case) will match zero records. Must use `createdAt`.
- The mixed convention is actively dangerous because most other collections in this DB do use snake_case.

## How to apply

- When writing Mongo filters against `ts_payouts`, always use `createdAt` / `updatedAt`.
- When writing schedulers or reports against payouts, cross-check the bson tag in `models/payout.go` before writing the filter.
- A potential future fix is to migrate the field name (breaking), not worth it without a concrete driver.

## Trace

commit `379e984` → docs/current-system.md §2 + §9 DRIFT-8; prior bug fixed in commit `850409a` — "fix(payout-expiry): camelCase bson field + enable/timeout from /setting/general (#143)"
