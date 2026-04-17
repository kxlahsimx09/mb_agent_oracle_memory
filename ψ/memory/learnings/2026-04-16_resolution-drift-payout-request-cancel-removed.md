---
title: resolution — client-facing payout cancel drift closed (DRIFT-5)
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - payout
  - callback
  - resolution
source: CLAUDE.md:963-974 + routes/payoutRequest.go:16-30 @ a4d806f
supersedes:
  - 2026-04-15_drift-payout-request-cancel-removed
related:
  - 2026-04-15_drift-payout-request-cancel-removed
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

# Resolution — DRIFT-5 payout-request cancel

## Drift class (original)

CLAUDE.md §"Payout Request API" listed `POST /api/v1/payout-request/:requestId/cancel` as a live endpoint. In `routes/payoutRequest.go:23-26`, the `Post("/:txnId/cancel")` line is commented out with note "system handles cancellation automatically (maintenance window, processing timeout, etc). Clients should not cancel payouts manually once submitted."

## Resolution path (taken)

(A) fix-doc.

## What changed

- Doc: CLAUDE.md §"Payout Request API" — removed the `POST /:requestId/cancel` bullet; inserted a note that the client-facing cancel was removed and system handles cancellation automatically.
- Doc: same section — the "Refund on Cancel" feature bullet was rewritten to "Automatic Cancellation" to match the new cancellation model (maintenance window, processing timeout, admin override).
- Code: unchanged.

## How I verified

Read `routes/payoutRequest.go:15-30`. Re-read CLAUDE.md §"Payout Request API" post-edit.

## Residual

None. The client-facing surface matches code at HEAD `a4d806f`.
