---
title: CountDocuments has no early-termination — every pagination page-load scans the e
tags: [technical-writer, repo:mobiz-payment-gateway, current, mongodb, perf, count-scan]
created: 2026-04-23
source: db/indexes.go:84-132@4fe2493, controllers/DepositController.go:438-446@1848ffd
project: github.com/kokarat/mobiz-payment-gateway
---

# CountDocuments has no early-termination — every pagination page-load scans the e

CountDocuments has no early-termination — every pagination page-load scans the entire filter match to return N. Index design must cover count-style queries specifically, not just the list filter+sort. On ts_deposits/ts_payouts a 7-day range with only {created_date_bkk:-1} ran IXSCAN+FETCH+filter-on-is_deleted (thousand-level FETCHes per count). PR #295 added {created_date_bkk:-1, is_deleted:1} compound indexes so count runs as COUNT_SCAN (index-only). PR #291 aligned the list sort with the filter field (created_date_bkk DESC) so a single index covers both. Rule of thumb: if a list page shows "1–N of M", both the list filter+sort AND the count predicate need index coverage — otherwise the count path silently dominates the list page's server time.

---
*Added via Oracle Learn*
