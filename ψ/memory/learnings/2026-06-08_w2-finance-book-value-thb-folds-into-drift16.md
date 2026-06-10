---
title: W2 2026-06-08 — Finance book_value_thb (#515) folds into the deferred Finance surface (DRIFT-16)
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - finance
  - drift
created: 2026-06-08
source: controllers/FinanceController.go@dd66c08
related:
  - 2026-06-01_drift-16-finance-api-deferred-to-w1
project: github.com/kokarat/mobiz-payment-gateway
---

W2 pass 2026-06-08 (amend extending PR #513 to cumulative `a011daf..8315189`). Two new commits since the prior pass's covered HEAD `602b6e3`:

- **`dd66c08` #515 — `FinanceTransactionsBalance` now returns per-account `book_value_thb`.** For cash accounts it equals `balance` (THB is already cost basis); for USDT accounts it is `Σ (income − expense) × rate` per row (one aggregation). Lets the finance dashboard show Net Worth at *cost basis* and reconcile with the manual cashbook (which records USDT at the purchase rate per row and never revalues). Motivation: the dashboard previously marked all USDT to a single latest daily rate, drifting ~53k THB from the sheet on ampay. Additive field — older clients ignoring it are unaffected. This is **in pg-writer territory** (`controllers/*.go` → §3) but the whole Finance feature has **no `current-system.md` coverage** yet — it is the open W1 re-baseline item DRIFT-16 (`db65a15` #483, ~3,097 LOC). So #515 refines an endpoint inside the deferred surface: it is **folded into DRIFT-16, not fast-fixed**. Documenting one endpoint of a 3k-LOC undocumented feature would be a wrong fast-fix per W2 §fast-fix-vs-full-pass.
- **`8315189` #516 — k8s Deployment rolling-update `maxSurge/maxUnavailable = 1/1`** so the backend fits tight node pools. **Out of pg-writer territory** (devops/k8s). Recorded for context only.

**Disposition:** no new in-territory fast-fix. `docs/.baseline` hash **HELD at `a011daf`** (Finance W1 deferral still outstanding); `last-verified-at` bumped 2026-06-06 → 2026-06-08. DRIFT-16 row + §11 W1-trigger note refreshed to note #515. The Finance surface keeps accreting commits while deferred (#483 → #511 env-wiring → #515 endpoint refinement) — each W2 pass folds the new commit in and re-confirms the deferral; the owed action remains a **W1 re-baseline (or dedicated finance doc pass)**, now overdue and growing.

See [[2026-06-01_drift-16-finance-api-deferred-to-w1]].
