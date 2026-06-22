---
title: drift — DRIFT-20 settlement block window + list/export/search bounding behaviors undocumented
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - settlement
  - perf
  - drift
created: 2026-06-17
source: middlewares/settlementWindow.go + helpers/maintenance.go:52-78,145-157 + helpers/cache.go (CachedCountCapped) + helpers/export_date_filter.go:9-19 + controllers/BankStatementController.go:172-177 @ 03d6383
related:
  - 2026-06-17_decision-range-a011daf-03d6383-w1-sized-escalate
project: github.com/kokarat/mobiz-payment-gateway
---

# DRIFT-20 — Settlement window + list/export/search bounding, undocumented

Four small but observable API-contract changes from the 2026-06 range, recorded as deferred drift (current-system.md §9 DRIFT-20).

Evidence (post-change @ 03d6383):
- **`52c8b75` #535 — settlement block window.** New `middlewares/settlementWindow.go SettlementWindowGuard()` returns **`503 SETTLEMENT_WINDOW_CLOSED`** on settlement create/approve/reject/confirm-review during an operator-configured daily window. Config in `app_settings`: `settlement_block_enabled` (master switch, default OFF) + `settlement_block_window` (`HH:MM-HH:MM`, default `22:30-02:00` Asia/Bangkok). Reuses `helpers/maintenance.go:52-78 isInWindowString` (handles overnight windows); **fails OPEN** on malformed/missing config (`helpers/maintenance.go:145-157`). Recovery routes `override` / `confirm-completed` are deliberately NOT guarded (`routes/settlement.go:42-43`) so admins can intervene during the window. Live status surfaced via `GetMaintenanceStatus()`.
- **`5cf693d` #534 — list-count cap.** deposit/payout/topup/settlement list endpoints now return a **`total_capped`** boolean and cap the count query at 10,000 matches (`helpers/cache.go CachedCountCapped`). Counts beyond 10,000 show as "10,000+" (cosmetic, 500 pages @ 20/page) — observable contract change.
- **`82734df` #536 — bounded CSV exports.** deposit/payout/topup/settlement CSV exports hard-cap at 100,000 rows (`helpers.ExportMaxRows`, `helpers/export_date_filter.go:9-19`) with an **`X-Export-Truncated`** response header on hit. A date-less export no longer streams the entire collection — it silently truncates and signals the operator to narrow the date range. Also: OTP-log search now routes masked `x####` input to an indexed exact match on `dest_account_last4`.
- **`c7e616f` #527 — masked-account search semantics.** Bank-statement search recognises masked `x####` (e.g. `x4380`) and routes to an indexed exact match on `dest_account_last4` instead of the broad 3-field regex (`controllers/BankStatementController.go:172-177`) — faster but a search-semantics narrowing.

Resolution path: folds into the W1-sized backlog. Note for W1: these touch §3.2 (list/export query params + response flags), §3.4 (settlement create gating), and the bank-statement/OTP search sections.
