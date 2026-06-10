---
title: Finance surface grows (#519 convert-selected + #518 importer LIMIT-200 fix) — still folded into DRIFT-16 W1 deferral
tags: [technical-writer, repo:mobiz-payment-gateway, current, finance, scheduler, drift, w2, track-commit]
created: 2026-06-08
source: controllers/FinanceController.go:1257@837f357, services/finance.go:328@837f357, scheduler/finance_settlement_importer.go:246@ae09c34
related:
  - 2026-06-01_drift-16-finance-api-deferred-to-w1
  - retro 2026-06-04_11.49_w2-track-commit-noop-a011daf-finance-deferred
project: github.com/kokarat/mobiz-payment-gateway
---

W2 pass 2026-06-08 (later, 23:35 GMT+7) folded two more in-territory Finance commits into the
existing DRIFT-16 deferral rather than fast-fixing them — the Finance API (`db65a15` #483) is a
new top-level feature area with **zero `current-system.md` coverage**, so any refinement to it is
captured in the DRIFT-16 register and queued for the owed Workflow 1 re-baseline. baseline held at
`a011daf`; `last-verified-at` → 2026-06-08T23:35.

**`837f357` #519 — operator-selected USDT conversion.** New route
`POST /api/v1/finance/transactions/convert-selected` (`routes/finance.go:29`) →
`FinanceController.ConvertSelectedTransactions` (`controllers/FinanceController.go:1257`) →
`services.ConvertSelectedRows(ctx, ids, rate)` (`services/finance.go:328`). Operators click-select
un-converted THB MDR-income rows that must share one cash account, pass a `rate`; the service sums
them into ONE USDT conversion pair and stamps `converted_pair_id` on each consumed row. Idempotency
contract identical to the day-level `AutoConvert`: rows already carrying `converted_pair_id` are
excluded via `converted_pair_id:{$exists:false}` so a row can't be converted twice. Motivation: the
day-level AutoConvert only catches `type=MDR-USDT` rows at the daily rate, but new settlement-note
rows import as `type=MDR` with the rate written into the note (e.g. "USDT เรท 33.08") and fell
through — operators buy USDT against MDR settlements one batch at a time, so this lets the UI
pre-fill the rate from each row's note and convert with one click.

**`ae09c34` #518 — importer LIMIT-200 starvation fix.** `scheduler/finance_settlement_importer.go`
sorts `completed_at` ASC with `SetLimit(200)` and previously only skipped already-imported rows
inside the loop (`settlement_ref` dup key). Once an owner crossed 200 lifetime settlements, every
cycle re-fetched the same oldest 200 (all skipped) and never reached settlement #201+ — the importer
silently stopped importing new settlements (5 Owner-MDR settlements, ~775k THB, completed past
position 200 were never imported). Fix: a new `finance_imported` settlement flag, stamped on both
import and dup-skip via `stampFinanceImported` and filtered out of the query with
`finance_imported:{$ne:true}` (`scheduler/finance_settlement_importer.go:246`). Now the 200-row
window only ever spans un-imported settlements so it advances. Self-healing — the dup-skip path
stamps the pre-existing backlog over the first 1–2 cycles (a companion one-shot backfill just makes
it instant); the 5 stuck rows were manually backfilled and the importer is idempotent on
`settlement_ref` so they won't double-import.

Both are in pg-writer territory (`controllers/*.go`, `services/*.go`, `scheduler/*.go`) but neither
is fast-fixable: there is no Finance section in `current-system.md` to edit. The owed W1 re-baseline
(or a dedicated finance doc pass) now has FIVE growth points to capture under DRIFT-16: #483 (the
base feature), #511 (env wiring → live in ampay), #515 (`book_value_thb`), #519 (`convert-selected`),
#518 (`finance_imported` importer fix).
