---
title: resolution — admin deposit/payout create-update drift closed (DRIFT-4)
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - deposit
  - payout
  - resolution
source: CLAUDE.md:611-632 + routes/deposit.go:20-28 + routes/payout.go:20-28 @ a4d806f
supersedes:
  - 2026-04-15_drift-deposit-payout-create-update-removed
related:
  - 2026-04-15_drift-deposit-payout-create-update-removed
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

# Resolution — DRIFT-4 admin deposit/payout create/update

## Drift class (original)

CLAUDE.md §"Deposit Management" and §"Payout Management" listed `POST /api/v1/deposits` + `PUT /api/v1/deposits/:id` (and the same for payouts) as live endpoints. In `routes/deposit.go:21` and `routes/payout.go:22`, the `Post("/")` and `Put("/:id")` lines are commented out with notes: "deposits are created via qr-paypout-api" / "payouts are created via Node.js API".

## Resolution path (taken)

(A) fix-doc.

## What changed

- Doc: CLAUDE.md §"Deposit Management" — removed `POST /api/v1/deposits` and `PUT /api/v1/deposits/:id`; prepended a note that admin cannot create/update, with a cite to `routes/deposit.go:20-28`.
- Doc: CLAUDE.md §"Payout Management" — removed `POST /api/v1/payouts` and `PUT /api/v1/payouts/:id`; prepended the same shape of note, with a cite to `routes/payout.go:21-28`.
- Code: unchanged.

## What admin still has (per code)

**Deposits** (`routes/deposit.go` at `a4d806f`): `GET /`, `GET /export`, `GET /stats`, `GET /stats/amount-distribution`, `GET /:id`, `GET /client/:clientId`, `PUT /:id/status`, `PUT /:id/match-status`, `POST /:id/upload-slip`, `POST /:id/resend-callback`, `DELETE /:id`. Bot routes: `PUT /bot/deposit/:id/status`, `PUT /bot/deposit/:id/match-status`.

**Payouts** (`routes/payout.go`): `GET /`, `GET /export`, `GET /stats`, `GET /:id`, `GET /client/:clientId`, `PUT /:id/status`, `PUT /:id/override`, `PUT /:id/confirm-completed`, `POST /:id/resend-callback`, `DELETE /:id`. (`upload-slip`, `override`, and `confirm-completed` are still undocumented in CLAUDE.md — see DRIFT-9 carry-over in §9.)

## How I verified

Read `routes/deposit.go` full file (43 lines) and `routes/payout.go:15-35`. Re-read CLAUDE.md §"Deposit Management" and §"Payout Management" post-edit.

## Residual

Some admin endpoints (`upload-slip`, `resend-callback`, `override`, `confirm-completed`) are present in code but still not documented anywhere in CLAUDE.md. Captured under the open DRIFT-9 (scope-parked) in `docs/current-system.md` §9.
