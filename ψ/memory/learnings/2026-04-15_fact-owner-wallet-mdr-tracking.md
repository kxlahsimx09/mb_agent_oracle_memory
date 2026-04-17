---
title: fact — wallets.is_owner marks the system-owner wallet for MDR tracking
name: fact — wallets.is_owner marks the system-owner wallet for MDR tracking
description: One wallet row carries IsOwner=true; super-admin sets it via PUT /wallets/:id/owner. Everything else in the MDR distribution flow treats this wallet as the residual bucket.
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - wallet
  - mdr
source: models/wallets.go:19 + routes/wallet.go:30 @ 379e984
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-15
---

# Fact — system-owner wallet

## Fact

`models/wallets.go:19`:
```go
IsOwner bool `json:"is_owner" bson:"is_owner"` // true = this is the system owner's wallet (for MDR owner tracking)
```

`routes/wallet.go:30`:
```go
wallets.Put("/:id/owner", middleware.RequireRole(helpers.RoleSuperAdmin), walletController.SetOwnerWallet) // super_admin only
```

There is also `wallets.Get("/owner", ...)` for reading the current owner wallet.

## Why it matters

- MDR distribution to partners is the documented path; the residual (total fee - partner shares) presumably flows to this owner wallet. [UNVERIFIED — precise residual routing not traced in this pass.]
- Only one wallet should carry `is_owner=true` at a time. [UNVERIFIED — code enforcement of single-owner invariant not traced.]

## How to apply

- When describing MDR economics, the partner split is not the full picture — mention the owner wallet as the residual-holder.
- Any Wallet diagram must include this one special wallet.

## Follow-up

- Trace `SetOwnerWallet` controller code to verify single-owner invariant.
- Trace the residual-distribution path end-to-end and update docs/current-system.md §6.1.
