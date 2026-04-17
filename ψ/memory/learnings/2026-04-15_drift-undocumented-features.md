---
name: drift — multiple feature areas have no CLAUDE.md section
description: 2FA, Telegram (webhook + config + broadcast), Bank Accounts (approval workflow), Direct Transfers, Pools, Activity Logs, Audit Trail middleware, App Settings, Callback Logs, MDR Shared logs, Bank Statements, Banks master list, Maintenance window — all live in code but missing from CLAUDE.md.
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - rbac
  - mdr
  - drift
source: routes/{2fa,telegram,bankaccount,directTransfer,pool,activitylog,appsettings,callbacklog,mdrshared,bankstatement,bank}.go + middlewares/auditTrail.go @ 379e984
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-15
---

# DRIFT — Entire feature areas absent from CLAUDE.md

## Fact

Each of the following has a route file, a controller, a model, and is registered in `main.go`, but has no dedicated section in `CLAUDE.md`:

- **2FA (TOTP)** — `/api/v1/2fa/*`, `/api/v1/auth/2fa/verify`, admin `PUT /users/:id/two-factor`, `PUT /users/:id/reset-2fa`. `models/users.go:45-48` carries `TwoFactorEnabled`, `TwoFactorSecret`, `IsLocked`, `LockedAt`.
- **Telegram** — `/api/v1/telegram/webhook`, `/api/v1/telegram-config/*`, broadcast messages with fan-out to all clients with `telegram_chat_id`.
- **Bank Accounts (approval)** — `/api/v1/bank-accounts/*`. Partner/client-owned accounts; status 0=pending, 1=approved, 2=rejected; `Purpose []string ["topup","settlement"]`.
- **Direct Transfers** — `/api/v1/direct-transfers/*`. Internal employee-initiated transfers; status string-valued.
- **Pools** — `/api/v1/pools/*`. Container of system bank references for client/merchant-scoped rotation.
- **Activity Logs** — `/api/v1/activity-logs/*`. Application-level audit per entity.
- **Audit Trail middleware** — global `AuditTrailMiddleware` in `main.go:90`; writes every POST/PUT/PATCH/DELETE to `audit_trail` with sensitive-field masking.
- **App Settings / Maintenance window** — `/api/v1/app-settings/*` (admin), `/api/v1/maintenance/status` (public). Key-value store for `payout_auto_cancel_enabled`, `pullout_refill_*`, etc.
- **Callback Logs** — per-attempt log rows queryable via `GET /callback-logs/:source_type/:source_id`.
- **MDR Shared logs** — `/api/v1/mdr-shared/*` — distribution audit surface.
- **Bank Statements** — admin view of scraped SCB/KTB statements (`/api/v1/bank-statements/*`).
- **Banks master list** — `/api/v1/banks` (JWT-only read, used for bank code lookup).

## Why it matters

- Anyone onboarding from CLAUDE.md alone will miss security-relevant surfaces (2FA, audit/activity logs) and revenue-relevant surfaces (pools, direct transfers, MDR shared).
- Gap is too wide to fix inline in a baseline; needs follow-up doc PRs per area.

## How to apply

- Reference `docs/current-system.md` §3 for the complete route surface, not CLAUDE.md.
- Future PRs should add per-area docs (start with a `docs/feature-areas/` directory or expand `CLAUDE.md` itself). Not in scope for this session.

## Trace

commit `379e984` → docs/current-system.md §3 + §9 DRIFT-9 → resolution PR (this PR baselines; follow-ups tracked in Oracle as `#next-task`)
