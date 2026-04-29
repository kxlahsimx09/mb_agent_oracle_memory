---
title: GET /api/v1/deposits/checking-count (NEW #290, 2026-04-22) is an index-backed po
tags: [technical-writer, repo:mobiz-payment-gateway, current, deposit, polling, perf]
created: 2026-04-23
source: routes/deposit.go:25@e430a06, controllers/DepositController.go:1400-1435@e430a06
project: github.com/kokarat/mobiz-payment-gateway
---

# GET /api/v1/deposits/checking-count (NEW #290, 2026-04-22) is an index-backed po

GET /api/v1/deposits/checking-count (NEW #290, 2026-04-22) is an index-backed polling replacement for /deposits/stats on the admin-page hot path. Response shape: {success, data: {checking_count: N}}. Query is CountDocuments({status:"checking", is_deleted: {$ne: true}}) via GetReadCollection, backed by the compound index {status, is_deleted, created_at}. Response time dropped from 200–500ms (12-conditional-sum $group full scan) to <5ms (index count). Wired at routes/deposit.go:25 behind JWT + PermView("deposit"); tenant-scoped via ApplyDepositTenantFilters. Pattern generalizes: a polling hot path should never reuse a broad $group stats aggregate — a dedicated index-backed count is always cheaper.

---
*Added via Oracle Learn*
