---
title: Hourly Telegram report template redesigned at PR #332 (`a8fb64e`, 2026-04-29). L
tags: [technical-writer, repo:mobiz-payment-gateway, current, telegram, scheduler, report, merchant-grouping]
created: 2026-04-28
source: scheduler/report_scheduler.go + services/telegramNotify.go @ a8fb64e
project: github.com/kokarat/mobiz-payment-gateway
---

# Hourly Telegram report template redesigned at PR #332 (`a8fb64e`, 2026-04-29). L

Hourly Telegram report template redesigned at PR #332 (`a8fb64e`, 2026-04-29). Layout is now a single column-aligned monospace block wrapped in a Markdown code fence so columns line up in Telegram. Hour totals row, by-merchant breakdowns for **all four** sections (Deposit/Topup/Payout/Settlement — Topup and Settlement are new), `📈 Since Start (HH:MM - Now)` cumulative block, then `💰 MDR Hour` / `💰 MDR Total` footer. Counts now carry thousand separators via the new `services.FormatCount(int64)` helper (sister to `FormatMoney`). New scheduler helpers `visualLen` / `padRight` (rune-aware so Thai merchant names stay aligned), `formatHourRow`, `writeMerchantBlock` (per-block dynamic name+count column widths, 16-char hard cap on the name column). Settlement-by-merchant uses a 2-stage `$lookup` chain (`settlements.entity_id → clients → clients.merchant_id → merchants`) because rows don't carry `merchant_name` natively; partner-source settlements bucket as `<partner_name> (Partner)`. Topup grouping axis flipped from `client_name` to `merchant_name` so all four blocks share the same axis (the model already denormalizes `merchant_name` at creation).

---
*Added via Oracle Learn*
