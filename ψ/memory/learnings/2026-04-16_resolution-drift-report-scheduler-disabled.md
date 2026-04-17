---
title: resolution — ReportScheduler drift closed as obsolete premise (DRIFT-10)
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - scheduler
  - resolution
source: CLAUDE.md §"Scheduler Architecture" (grep: no match for "ReportScheduler" or "hourly report" outside bank-status) + main.go:169-173 + routes/telegram.go:27-28 @ a4d806f
supersedes:
  - 2026-04-15_drift-report-scheduler-disabled
related:
  - 2026-04-15_drift-report-scheduler-disabled
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

# Resolution — DRIFT-10 ReportScheduler disabled (obsolete premise)

## Drift class (original)

CLAUDE.md §"Scheduler Architecture" was claimed to list the hourly report scheduler alongside active schedulers without noting it is disabled in-process. The code fact: `main.go:169-173` has `ReportScheduler` commented out with note "Hourly report scheduler disabled - using external cron instead", and `routes/telegram.go:27-28` exposes public trigger endpoints (`POST /telegram/report/hourly`, `POST /telegram/report/daily`) used by that external cron.

## Resolution path (taken)

(C) obsolete — premise mis-stated at HEAD.

## Why this resolves as (C)

Re-verification at HEAD `a4d806f`: CLAUDE.md §"Scheduler Architecture" does **not** mention the hourly report scheduler. Grep on "report" inside CLAUDE.md matches only `/api/v1/bank-status/report` and the RBAC resource list — neither is a scheduler claim. The Scheduler Architecture table at CLAUDE.md:733-737 lists only four files (`scheduler.go`, `strategies.go`, `deposit_expiry.go`, `withdrawal_dispatcher.go`); it is silent on the report scheduler.

So the drift's doc-side premise is not present at HEAD. There is no stale doc claim for the writer to fix.

## What changed

- Doc: nothing. Row removed from `docs/current-system.md` §9.
- Code: unchanged.

## Durable fact (preserved in original drift learning)

`main.go:169-173` has `ReportScheduler` commented out. External cron hits `POST /api/v1/telegram/report/hourly` and `POST /api/v1/telegram/report/daily` (see `routes/telegram.go:27-28`). Anyone debugging "why are reports not firing?" should start at the external cron / CI scheduler, not at Go code. This fact lives forever in the superseded DRIFT-10 learning per P-001.

## Adjacent drift (not this resolution's scope)

CLAUDE.md's Scheduler Architecture table at line 733-737 is itself incomplete — it does not list `scheduler/transaction_matcher.go`, `scheduler/maintenance_cancel.go`, `scheduler/payout_expiry.go`, or `scheduler/report_scheduler.go`. This is a separate drift (table completeness), not the one closed here. A future Workflow 1 pass should catch it; for now it's implicitly covered under the parked DRIFT-9.

## How I verified

Grepped CLAUDE.md for all regex variants of report / Report / ReportScheduler / hourly_report / hourly report. Read CLAUDE.md lines 708-745 (the Scheduler Architecture section). Read `main.go:165-175`. Read `routes/telegram.go:20-30` (confirmed in the DRIFT-10 drift's own listing).
