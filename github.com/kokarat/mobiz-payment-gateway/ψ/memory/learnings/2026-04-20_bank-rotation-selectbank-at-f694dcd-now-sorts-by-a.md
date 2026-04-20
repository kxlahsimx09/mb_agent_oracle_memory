---
title: Bank rotation selectBank at f694dcd now sorts by a compound key {deposit_count_d
tags: [repo:mobiz-payment-gateway, services, technical-writer, bank-rotation, current, flow:deposit]
created: 2026-04-20
source: pg-writer-oracle W2 @ f694dcd
project: github.com/kokarat/mobiz-payment-gateway
---

# Bank rotation selectBank at f694dcd now sorts by a compound key {deposit_count_d

Bank rotation selectBank at f694dcd now sorts by a compound key {deposit_count_date ASC, deposit_count ASC} instead of deposit_count alone, in both the deposit branch (FindOneAndUpdate, services/bankRotation.go:263-268) and the payout branch (FindOne, services/bankRotation.go:277-281).

Why: deposit_count_date is stored as an int YYYYMMDD. A bank that did not draw traffic yesterday carries both the stale date and a leftover count (e.g., 1758). Sorting by count alone froze that bank out of rotation on the next day — the freshly-reset today-banks always had lower counts. With the compound sort, yesterday's int (20260419) < today's int (20260420), so the stale-date bank sorts first and gets picked. The deposit $set pipeline then rewrites deposit_count to 1 (stale-date branch of the $cond), giving the bank a clean count for today.

How to apply: when operators report "bank X not getting traffic today", check system_banks.deposit_count_date vs today (Asia/Bangkok). If it is a prior day and count is large, the pre-f694dcd bug would have kept it excluded; post-f694dcd the next selectBank call reclaims it. Payout rotation uses the same compound sort for symmetry but does not mutate counts (no $set pipeline on FindOne).

Pre-existing drift touched (not fixed here): docs/current-system.md §6.2 introductory sentence still says "Selection prefers banks with the lowest DailyTransactions." The actual sorted field has always been deposit_count, not DailyTransactions. The f694dcd doc update adds a SUPERSEDED pointer but leaves the prior sentence per P-001.

citations: services/bankRotation.go:243-288@f694dcd
baseline: pg-writer-oracle W2 extension pass from 148bb70..f694dcd (docs/track-386f0a7 branch, PR #242 amendment)

---
*Added via Oracle Learn*
