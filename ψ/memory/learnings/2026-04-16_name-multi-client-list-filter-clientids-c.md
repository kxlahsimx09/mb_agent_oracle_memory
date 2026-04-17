---
name: multi-client list filter — client_ids (comma-separated, $in) on /deposits + /payouts
description: As of eedf215 (2026-04-16, PR #168), GetAllDeposits and GetAllPayouts accept a new client_ids query param. Comma-separated ObjectID list, matched via $in. Legacy single client_id still works — client_ids wins when both supplied. Empty/malformed ids are silently dropped.
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - deposit
  - payout
  - filters
source: controllers/DepositController.go:200-220 @ 3b7e0f1; controllers/PayoutController.go:119-138 @ 3b7e0f1
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

# Multi-client list filter — client_ids

## Fact

`controllers.DepositController.GetAllDeposits` and `controllers.PayoutController.GetAllPayouts` accept `?client_ids=<csv>` in addition to the legacy `?client_id=<id>`.

Semantics:

- Comma-separated list of ObjectID hex strings.
- Empty strings and malformed ids are silently dropped from the list.
- If the resulting list is empty, the filter falls back to "all clients" (no `client_id` predicate added) — a stray `?client_ids=` never produces zero rows.
- When both `client_id` and `client_ids` are supplied, `client_ids` wins.
- Access-control paths for client / sub-client / partner users are unchanged — those still auto-filter to their own scope and ignore both query params.
- Merchant filter still wraps through `ApplyMerchantFilter` on `client_id`.

## Why

Ops needed the `/deposit` and `/payout` admin pages to show data for 2-3 clients at once, the same way `/bank-transactions` already lets you multi-select bank accounts.

## How to apply

- When extending any other list endpoint to multi-select, mirror this pattern: comma-separated, silently drop malformed, fallback to "all" on empty, and make the plural key win over the singular.
- Do not OR `client_ids` with an access-control filter — the current code short-circuits per user_type. New roles that need multi-client scope must have their own scope rule; multi-select is a UI filter, not an auth elevation.
- Strip trailing comma and whitespace around ids from the list before converting to ObjectIDs.

## Trace

commit `3b7e0f1` (specifically `eedf215` #168) → docs/current-system.md §3.2 deposits/payouts rows → resolution PR #173
