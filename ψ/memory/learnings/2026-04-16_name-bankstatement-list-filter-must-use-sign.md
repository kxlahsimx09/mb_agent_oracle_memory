---
title: bank_statement list filter must use signed amount — credit/debit fields are 0 today
name: bank_statement list filter must use signed amount — credit/debit fields are 0 today
description: As of deebd65 (2026-04-16, PR #166), /bank-statements list filters on signed amount via $or:[{amount:v},{amount:-v}] for exact and $expr:$abs for range. Bot writes 0 to credit_amount/debit_amount — old filter dropped 418/761 rows for a 200-amount search.
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - bank-bot
  - bank-statement
  - data-model
source: controllers/BankStatementController.go:215-285 @ 3b7e0f1
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

# Bank statement list filter must use signed amount

## Fact

The admin list endpoint `/api/v1/bank-statements` filters on the signed `amount` field, not on `credit_amount` / `debit_amount`.

- Exact filter: builds an `$or` of `[{amount: v}, {amount: -v}]` so the same search matches both an incoming +200 row and an outgoing -200 row. If the filter already had an existing `$or` (from a description text search), the two `$or` blocks get wrapped in an `$and` so they compose rather than overwrite.
- Range filter: builds `$expr: {$abs: $amount}` over the min/max window. Both an "in" row of +300 and an "out" row of -300 fall into a 200-500 band.
- Stats aggregation (`sum_in`, `sum_out`, `sum_fee`) was already using `$abs(amount)` — unchanged.

## Why

The current bot writes 0 into both `credit_amount` and `debit_amount` and puts the signed value in `amount`. DB reality check on 2026-04-16:

```
amount == 200          → 761 rows
amount == -200         → 4 rows
credit_amount == 200   → 343 rows (legacy data only)
credit_amount == -200  → 0 rows
```

A search for 200 was therefore matching only the 343 legacy rows and missing the 418 rows where `amount = ±200` but both credit/debit were 0.

`credit_amount` and `debit_amount` are still in the `BankStatement` model — they are stats-only residuals and should not be added to new filters.

## How to apply

- Any new code that filters bank statements by value must use `amount` with sign-aware predicates. Do not add `credit_amount` / `debit_amount` to a new filter.
- When writing aggregations that need signed totals, always `$abs(amount)` — do not try to reconstitute from credit/debit.
- If a future bank adapter re-populates credit/debit, that change is a breaking surface — add a migration + leave a `#drift` learning before relying on those fields again.
- The `$or` composition gotcha is general: if you're adding a second predicate set to a filter that may already contain `$or` (search, bank-code multi-select, etc.), wrap in `$and` to preserve both.

## Trace

commit `3b7e0f1` (specifically `deebd65` #166) → docs/current-system.md §3.2 bank-statements row + §2 BankStatement row → resolution PR #173
