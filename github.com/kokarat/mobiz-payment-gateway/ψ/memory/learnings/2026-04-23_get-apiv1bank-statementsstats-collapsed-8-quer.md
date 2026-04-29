---
title: GET /api/v1/bank-statements/stats collapsed 8 queries into 1 (#271, 2026-04-22).
tags: [technical-writer, repo:mobiz-payment-gateway, current, bank-statements, mongodb, perf]
created: 2026-04-23
source: controllers/BankStatementController.go:381-463@da223fa
project: github.com/kokarat/mobiz-payment-gateway
---

# GET /api/v1/bank-statements/stats collapsed 8 queries into 1 (#271, 2026-04-22).

GET /api/v1/bank-statements/stats collapsed 8 queries into 1 (#271, 2026-04-22). Prior impl fired 7 CountDocuments (total + direction in/out + match_status matched/unmatched/pending/fee) + 1 sum aggregate, each scanning the same matched doc set (7-day window ≈ 80–100k docs × 8 passes on secondary). Replaced with a single $group pipeline emitting every count + every sum in one pass; same response shape so no frontend change. Decode is defensive about int32/int64/float64 since counts come back in different widths depending on magnitude. Pattern generalizes: when the frontend consumes N counts off the same $match filter, collapse to one $group with N {$cond} branches instead of N separate CountDocuments calls.

---
*Added via Oracle Learn*
