---
title: fact — PayoutExpiryScheduler fails closed on app_settings read error
name: fact — PayoutExpiryScheduler fails closed on app_settings read error
description: If reading payout_auto_cancel_enabled from app_settings errors, the scheduler skips the tick rather than defaulting to enabled — prevents a briefly-unavailable DB from re-enabling auto-cancel that an operator has turned off.
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - payout
  - scheduler
source: scheduler/payout_expiry.go:86-105 @ 379e984
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-15
---

# Fact — fail-closed design for payout auto-cancel

## Fact

`scheduler/payout_expiry.go:97-105` uses the strict variant `helpers.GetAppSettingBoolStrict(...)`:
```go
enabled, flagErr := helpers.GetAppSettingBoolStrict(SettingKeyPayoutAutoCancel, true)
if flagErr != nil {
    log.Printf("[PayoutExpiry] Skipping tick — failed to read %s: %v (failing closed)", ...)
    return
}
if !enabled { return }
```

The comment directly above explains why:

> Use the strict variant so we can distinguish "operator disabled" from
> "database briefly unreachable." The old code funnelled both cases through
> a `fallback=true` default, which meant a single 5-second Mongo context
> timeout would silently re-enable the flag for up to 30 seconds (TTL cache)
> and cancel pending payouts the operator had explicitly paused. For a
> money operation we fail CLOSED: if we cannot confirm the flag is on, we
> do not cancel.

## Why it matters

- This is a financial-ops invariant: operator intent ("pause auto-cancel") must dominate transient DB errors.
- Any future refactor tempted to use `GetAppSettingBool` (which may have a fallback-true behavior) on a cancel/refund flag needs to think twice.

## How to apply

- When documenting the PayoutExpiryScheduler in runbooks, mention that DB errors silently pause the cancellation, not resume it.
- Any doc cloning this flag pattern for another money operation should use the strict variant.
