---
title: Hourly Telegram report revamped at d01d9b2 (PR #244, 2026-04-20). Shape at HEAD:
tags: [technical-writer, repo:mobiz-payment-gateway, current, telegram, scheduler, reports, cumulative, business-day]
created: 2026-04-20
source: scheduler/report_scheduler.go:99-189@d01d9b2, controllers/TelegramController.go:971-1022@d01d9b2, main.go:170-173@d01d9b2
project: github.com/kokarat/mobiz-payment-gateway
---

# Hourly Telegram report revamped at d01d9b2 (PR #244, 2026-04-20). Shape at HEAD:

Hourly Telegram report revamped at d01d9b2 (PR #244, 2026-04-20). Shape at HEAD: message combines an hourly block with a cumulative-since-business-day-start block. Business day starts at 02:00 BKK — businessDayStart(now) rolls back to yesterday 02:00 when current hour is before 2. Hourly: Deposit / Topup / Payout / Settlement totals + by-merchant breakdowns for Deposit and Payout (grouped on merchant_name via $group; settlements grouped on entity_name). Cumulative: same four totals for [dayStart, now). Footer: Total MDR for the hour + Total MDR Since Start, both summed from mdr_shared.total_fee. Topup from ts_topups via dedicated getTopupStats. Merchant names escaped via escapeMD. Trigger refactor: TelegramController.TriggerHourlyReport is now a 2-line delegator (scheduler.NewReportScheduler().GenerateReportNow()); build logic lives only in scheduler/report_scheduler.go:generateReport (lines 99-189@d01d9b2). TriggerDailyReport still builds inline via buildDailyReportMessage but was re-keyed: ReportTransactionItem gained MerchantName (hydrated from ts_deposits/ts_payouts in getDepositStatsForReport / getPayoutStatsForReport); groupByMerchant keys on MerchantName first with ClientName fallback (so settlement section still groups by entity_name). All "รายการ" labels replaced by "Txns" for consistency with hourly. Supersedes the prior "merchant-grouped only" shape documented in 2026-04-17_name-telegram-reports-merchant-grouping-bkk — new shape adds Topup + cumulative + business-day-start. main.go:170-173 scheduler invocation still commented out (external cron authoritative — see DRIFT-10); comment text reworded but Start() call not re-enabled.

---
*Added via Oracle Learn*
