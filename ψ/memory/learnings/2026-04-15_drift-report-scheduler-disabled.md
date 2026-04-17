---
name: drift — ReportScheduler is disabled in-process; external cron drives hourly reports
description: main.go:170-173 has ReportScheduler commented out; routes/telegram.go:25-26 exposes public trigger endpoints used by the external cron. CLAUDE.md mentions the scheduler without noting the in-process disablement.
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - scheduler
  - drift
source: main.go:170-173 + routes/telegram.go:25-26 + scheduler/report_scheduler.go @ 379e984
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-15
---

# DRIFT — ReportScheduler lives in code but does not run in-process

## Fact

`main.go:170-173`:
```go
// Hourly report scheduler disabled - using external cron instead
// To enable internal scheduler, uncomment below:
// reportScheduler := scheduler.NewReportScheduler()
// reportScheduler.Start()
// log.Println("Hourly report scheduler started")
```

`routes/telegram.go:25-26` exposes the trigger endpoints publicly:
```go
telegram.Post("/report/hourly", telegramController.TriggerHourlyReport)
telegram.Post("/report/daily", telegramController.TriggerDailyReport)
```

CLAUDE.md §"Scheduler Architecture" lists the hourly report scheduler alongside the active schedulers without noting it is not running in-process.

## Why it matters

- Anyone debugging "why are reports not firing?" will read the scheduler file and conclude it must be broken. Actual answer: the external cron may be misconfigured or absent.
- Running the scheduler in-process in addition to the external cron would cause duplicate reports.

## How to apply

- When describing the scheduler roster, always note this one is disabled in-process and served via public HTTP triggers.
- Runbook for "report missing" must start at the cron / CI scheduler, not at Go code.

## Trace

commit `379e984` → docs/current-system.md §5 + §9 DRIFT-10 → resolution PR (this PR)
