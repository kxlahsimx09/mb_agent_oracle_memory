---
name: drift — admin-create/update for deposits and payouts are removed
description: routes/deposit.go and routes/payout.go have their POST and PUT /:id endpoints commented out ("created via qr-paypout-api" / "created via Node.js API") but CLAUDE.md still documents them.
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - deposit
  - payout
  - drift
source: routes/deposit.go:20-21 + routes/payout.go:672-673 @ 379e984
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-15
---

# DRIFT — Admin-create/update for deposits/payouts

## Fact

`routes/deposit.go:20-21` (commented out):
```
// NOTE: CreateDeposit and UpdateDeposit are commented out because deposits are created via qr-paypout-api
// deposits.Post("/", ...)
// deposits.Put("/:id", ...)
```

`routes/payout.go:672-673` (commented out): same pattern with the note "payouts are created via Node.js API".

CLAUDE.md §"Deposit Management" and §"Payout Management" still list `POST /api/v1/deposits` and `PUT /api/v1/deposits/:id` (and payout equivalents) as if they existed.

## Why it matters

- Admin UI callers that retained those endpoints after a CLAUDE.md refresh will 404. The actual creation path is `/api/v1/deposit/create` (API-Key auth, MAXPAY-compatible) and the Node.js bank-bot for payouts.
- The disabled admin path means deposit/payout status mutation is the *only* admin-controlled verb for those resources.

## How to apply

- In any new doc, describe deposits/payouts as "created via client-facing API-Key endpoints; admin cannot create." Cite `depositRequest.go` / `payoutRequest.go` + the commented-out lines.
- Admin surface is limited to `PUT /:id/status`, `PUT /:id/match-status`, `POST /:id/resend-callback`, `POST /:id/upload-slip` (deposit), `PUT /:id/override` (payout).

## Trace

commit `379e984` → docs/current-system.md §3.2 + §9 DRIFT-4 → resolution PR (this PR)
