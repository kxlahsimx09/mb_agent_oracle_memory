---
title: `bank_statements` DISTINCT_SCAN backing for the matcher retry ticker (`7557402` 
tags: [technical-writer, repo:mobiz-payment-gateway, current, bank-statements, matcher, index, perf]
created: 2026-04-24
source: db/indexes.go:335-345@7557402
project: github.com/kokarat/mobiz-payment-gateway
---

# `bank_statements` DISTINCT_SCAN backing for the matcher retry ticker (`7557402` 

`bank_statements` DISTINCT_SCAN backing for the matcher retry ticker (`7557402` #298). `services/transactionMatcher.go` ReMatchUnmatchedByDirection fires every 30s (direction=in) and 60s (direction=out) and runs `Distinct("account_number", {direction, match_status: {$in:[pending,unmatched]}, created_at >= 1h ago})`. None of the prior 13 `bank_statements` indexes covered this shape — they all key on `transaction_date_bkk` (bank booking time), not `created_at` (insertion timestamp). The new compound `{direction:1, match_status:1, created_at:-1, account_number:1}` is key-ordered to let the planner pick DISTINCT_SCAN: equality first (`direction`), then `$in` (`match_status`), then range (`created_at`), with the distinct key (`account_number`) last for dedup. No code change; planner picks it up automatically on restart.

---
*Added via Oracle Learn*
