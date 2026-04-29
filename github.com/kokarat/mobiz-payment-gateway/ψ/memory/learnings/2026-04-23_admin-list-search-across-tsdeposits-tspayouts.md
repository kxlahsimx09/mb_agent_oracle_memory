---
title: Admin list search across ts_deposits, ts_payouts, settlements, topups now uses t
tags: [technical-writer, repo:mobiz-payment-gateway, current, search-shape-routing, perf]
created: 2026-04-23
source: controllers/DepositController.go:321-346@4fe2493, controllers/PayoutController.go:182-228@b164e3d, controllers/SettlementController.go:419-454@7c571fc, controllers/TopupController.go:386-423@7c571fc
project: github.com/kokarat/mobiz-payment-gateway
---

# Admin list search across ts_deposits, ts_payouts, settlements, topups now uses t

Admin list search across ts_deposits, ts_payouts, settlements, topups now uses the same shape-routed template: len<3 skip; TYPE prefix (DEP/PAY/STL/TOP) → anchored ^TYPE on request_id hits the unique request_id index; all-digits≥8 → anchored prefix on account_number fields; otherwise → anchored case-insensitive ^prefix on ref_code + case-insensitive substring on 1–3 name/notes fields. regexp.QuoteMeta escapes user metacharacters. Replaces prior 2- to 8-field unanchored $or regex scans. Landed across #285 (deposits), #291 (payouts), #293 (ref_code casing + payout ref_code scope), #294 (settlements + topups, plus unique request_id indexes for STL/TOP).

---
*Added via Oracle Learn*
