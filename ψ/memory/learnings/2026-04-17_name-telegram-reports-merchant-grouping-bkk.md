---
title: Telegram hourly/daily reports at ed45b7e — merchant-grouped, Total MDR, BKK TZ
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - telegram
  - scheduler
  - reports
source: scheduler/report_scheduler.go:16-277@ed45b7e, controllers/TelegramController.go:970-1050,1100-1424@ed45b7e, main.go:170-173@ed45b7e
created: 2026-04-17
project: github.com/kokarat/mobiz-payment-gateway
---

# Telegram hourly/daily reports at ed45b7e — merchant-grouped, Total MDR, BKK TZ

## Pattern

PRs `#198` (128+/274- net revamp) and `#199` (hourly tz fix) reshaped the hourly and daily report generation. Shape at HEAD:

- **Grouping:** deposits and payouts are grouped by `merchant_name` via MongoDB `$group` aggregation; settlements by `entity_name`. `groupByMerchant` in `TelegramController.go:1100–1120` tallies count + sum per group and sorts amount-desc.
- **Total MDR:** `getTotalMDRForPeriod` / `getTotalMDRForReport` sums `mdr_shared.total_fee` over the report window. The total appears as its own line in the message body.
- **Timezone:** every timestamp is rendered via an explicit `time.LoadLocation("Asia/Bangkok")` load — previously the hourly report relied on process-level `time.Local` which drifted if the process ran in a non-BKK container.
- **Public triggers unchanged:** `POST /api/v1/telegram/report/hourly` and `/daily` (both in the public routes block) call `TriggerHourlyReport` / `TriggerDailyReport` in the controller. An external cron hits these.
- **In-process scheduler:** the code in `scheduler/report_scheduler.go` (`Start()`, `run()`) was also revamped to the same shape, but the scheduler is still commented out in `main.go:170–173` ("using external cron instead"). The in-process methods `GenerateReportNow` / `GenerateDailyReportNow` exist but have no HTTP route — they are callable from tests only.

## Why

The prior report was a flat transaction list that ops had to skim manually to infer per-merchant volume; MDR was absent. The revamp lets the on-call see (a) which merchants drove the hour's activity, (b) how much fee revenue that implied, at a glance. TZ fix is a correctness patch — the hourly report was occasionally labelling the wrong hour when the container restarted in UTC.

## How to apply

- New merchants appear in the report automatically as long as `merchant_name` is populated on the deposit/payout/settlement document.
- If the external cron stops, there is no in-process fallback at HEAD — the schedule is **only** driven by the cron hitting the public endpoint.
- The in-process `ReportScheduler` code is kept live (not dead-stripped) so a future re-enable is a one-line `main.go` change, not a rewrite.
