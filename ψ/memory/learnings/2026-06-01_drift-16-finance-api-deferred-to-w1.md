---
title: drift-16 — Finance API (#483) is a new top-level feature area, deferred from W2 to a W1 re-baseline
tags: [technical-writer, repo:mobiz-payment-gateway, current, finance, drift, decision]
created: 2026-06-01
source: db65a15@db65a15 (controllers/FinanceController.go, routes/finance.go, scheduler/finance_settlement_importer.go, services/finance.go, middlewares/financeWhitelist.go, models/finance.go)
project: github.com/kokarat/mobiz-payment-gateway
---

`db65a15` #483 (2026-05-28) added the **Finance API** — ~3,097 LOC across 14 files: new controllers (`FinanceController.go` 1270, `FinanceAccountController.go` 320, `FinanceDailyRateController.go` 167), a new route group (`routes/finance.go`), a new whitelist middleware (`middlewares/financeWhitelist.go`), new models (`models/finance.go` + `models/users.go` +7), a new service (`services/finance.go` 458), and a **new scheduler** `scheduler/finance_settlement_importer.go` (487, Phase-2 multi-asset + auto-import). Phase 1 = cashbook + payroll; Phase 2 = multi-asset + auto-import.

Per `docs/current-system.md` §11 "Next baseline triggers", a new top-level feature area (new collections + new scheduler + new route group + new middleware) is a **Workflow 1 re-baseline** trigger, NOT a W2 fast-fix. The 2026-06-01 W2 pass (range `a011daf..bf57c0e`) **deliberately deferred** documenting it — faithfully summarising 3k LOC in a fast-fix would be a "wrong fast-fix → silent drift." Recorded as DRIFT-16 in §9 + a ⚠ banner in §11.

**Consequence:** `docs/.baseline` was NOT bumped past `a011daf` on this pass (in-territory file deferred → baseline stays at prior hash per W2 Step 7). Next owed action: a W1 re-baseline (or a dedicated finance doc pass) covering finance §3/§4/§5. `last-verified-at` (2026-05-28) is also approaching the 14-day window. Related: [[2026-06-01_payout-refund-reconcile-race-cas-guard]].
