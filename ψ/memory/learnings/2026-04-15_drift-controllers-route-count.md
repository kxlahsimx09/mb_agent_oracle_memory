---
name: drift — controller/route count far exceeds CLAUDE.md's listed set
description: HEAD has 41 controllers and 39 route files. CLAUDE.md §Project Structure lists ~26 controllers. Feature-complete deltas include ActivityLog, AppSettings, BankAccount, Bank (master list), CallbackLog, ClientAPI, DirectTransfer, MDRShared, Pool, PullOutLogs, PullOutTask, Resource, Telegram{,Config,BroadcastMessage}, TwoFactor.
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - drift
source: controllers/ + routes/ + CLAUDE.md @ 379e984
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-15
---

# DRIFT — Project structure drift

## Fact

`ls controllers/ | wc -l` → 41. `ls routes/ | wc -l` → 39. CLAUDE.md §"Project Structure" enumerates roughly 26 controllers with annotations.

Missing entirely from the CLAUDE.md listing (each has both a controller file and at least one route):

- `ActivityLogController` + `/api/v1/activity-logs`
- `AppSettingsController` + `/api/v1/app-settings`, `/api/v1/maintenance/status`
- `BankAccountController` + `/api/v1/bank-accounts`
- `BankController` + `/api/v1/banks`
- `CallbackLogController` + `/api/v1/callback-logs/:source_type/:source_id`
- `ClientAPIController` + `/api/v1/client/{balance,bank/list/code,banks}`, `/api/v1/jwt/create`, `/api/v1/hash/verify`
- `DirectTransferController` + `/api/v1/direct-transfers`
- `MDRSharedController` + `/api/v1/mdr-shared`
- `PoolController` + `/api/v1/pools`
- `PullOutLogsController` + `/api/v1/pullout-logs`
- `PullOutTaskController` + `/api/v1/pullout-tasks`
- `ResourceController` + `/api/v1/resources`, `/api/v1/actions`
- `TelegramController`, `TelegramConfigController`, `TelegramBroadcastMessageController` + `/api/v1/telegram*`
- `TwoFactorController` + `/api/v1/2fa`, `/api/v1/auth/2fa/verify`

## Why it matters

- Anyone using CLAUDE.md as a system map will have a materially incomplete picture of what exists.
- The gap covers security-relevant surfaces (2FA, audit/activity logs, callback logs, app settings) and cross-cutting revenue surfaces (Pools, Direct Transfers, MDR Shared).

## How to apply

- Treat CLAUDE.md §"Project Structure" as orientation, not as ground truth. `ls controllers/ routes/` is ground truth.
- When baselining, walk the routes directory top-down; do not rely on a pre-existing table.

## Trace

commit `379e984` → docs/current-system.md §2 + §3 + §9 DRIFT-6 → resolution PR (this PR)
