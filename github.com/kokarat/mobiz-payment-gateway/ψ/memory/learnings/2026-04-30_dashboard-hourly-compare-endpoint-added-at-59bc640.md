---
title: Dashboard hourly-compare endpoint added at 59bc640 (PR #334, 2026-04-29). New su
tags: [technical-writer, repo:mobiz-payment-gateway, current, dashboard, api-surface, business-day-window]
created: 2026-04-30
source: controllers/DashboardController.go:1133-1315@59bc640, routes/dashboard.go:23-27@59bc640
project: github.com/kokarat/mobiz-payment-gateway
---

# Dashboard hourly-compare endpoint added at 59bc640 (PR #334, 2026-04-29). New su

Dashboard hourly-compare endpoint added at 59bc640 (PR #334, 2026-04-29). New surface: `GET /api/v1/dashboard/hourly-compare` returns 24 hourly buckets each of deposit + payout activity (`amount` + `count`) for today and yesterday, scoped to the same business-day window the hourly Telegram report uses (02:00 BKK → 01:59 next morning). Buckets are returned in business-day order (index 0 = 02:00, index 22 = 00:00, index 23 = 01:00) so the frontend can plot left-to-right without reasoning about the midnight wrap; each bucket also carries the wall-clock `Hour` for x-axis labels. Today is partial (cumulative through "now"); yesterday is the full 24-hour window so it forms a stable reference line. Status filter: deposits `paid` + payouts `completed` (success only). Implementation choice: hour-of-day extracted with cheap integer math from `created_date_bkk` (already YYYYMMDDHHMMSS in BKK timezone) via `$mod($floor($divide($created_date_bkk, 10000)), 100)` — no `$dateToParts` / `$hour` timezone conversion needed. Four aggregations per request (deposit/payout × today/yesterday). 15-second context timeout. Tenant scoping inherited from the existing `dashboard:view` permission gate. Read replica path. Response shape: `{ deposit: { today[], yesterday[] }, payout: { today[], yesterday[] }, today_label, yesterday_label, generated_at }`. Powers a new dashboard chart.

---
*Added via Oracle Learn*
