---
name: drift — client-facing payout cancel route is disabled
description: routes/payoutRequest.go comments out POST /payout/:txnId/cancel with note "system handles cancellation automatically (maintenance window, processing timeout, etc)". CLAUDE.md still documents this endpoint.
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - payout
  - callback
  - drift
source: routes/payoutRequest.go:708-711 @ 379e984
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-15
---

# DRIFT — Client-facing payout cancel route removed

## Fact

`routes/payoutRequest.go:708-711`:
```
// Cancel route removed — system handles cancellation automatically
// (maintenance window, processing timeout, etc). Clients should not
// cancel payouts manually once submitted.
// payout.Post("/:txnId/cancel", middleware.APIKeyCheck(), ctrl.CancelPayout)
```

CLAUDE.md §"Payout Request API" still lists `POST /api/v1/payout-request/:requestId/cancel`.

## Why it matters

- A client SDK written against CLAUDE.md will include a `cancel()` method that returns 404.
- Auto-cancel paths replace the manual one: `MaintenanceCancelScheduler` (during maintenance window) and `PayoutExpiryScheduler` (after `payout_pending_timeout_minutes`, default 15 min). Both refund `amount + payout_fee` atomically and emit the `payout.cancelled` callback.

## How to apply

- Describe payout cancellation as system-driven only; cite the two schedulers.
- In any "client actions after create" table, payout cancel should not appear.

## Trace

commit `379e984` → docs/current-system.md §3.3 + §9 DRIFT-5 → resolution PR (this PR)
