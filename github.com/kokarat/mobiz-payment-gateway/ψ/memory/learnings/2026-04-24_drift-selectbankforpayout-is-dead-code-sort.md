---
title: Drift — `SelectBankForPayout` is dead code + sort-metric drift (comment says `da
tags: [drift, repo:mobiz-payment-gateway, current, dead-code, bank-rotation, payout, withdrawal-queue, w4-candidate, comment-code-mismatch, cross-role-handoff, pg-writer]
created: 2026-04-24
source: services/bankRotation.go:61-64, 240-241, 276-287 @ mobiz 19e0bed + grep verification (2026-04-24 GMT+7, architect Input 5 sweep)
project: github.com/kokarat/mobiz-payment-gateway
---

# Drift — `SelectBankForPayout` is dead code + sort-metric drift (comment says `da

Drift — `SelectBankForPayout` is dead code + sort-metric drift (comment says `daily_transactions`, code sorts by `deposit_count`).

## Finding

At mobiz HEAD `19e0bed` (2026-04-24 GMT+7):

1. **`services.BankRotationService.SelectBankForPayout` is dead code.** `grep -rn SelectBankForPayout --include="*.go"` returns:
   - `services/bankRotation.go:61-64` — definition only
   - `tests/...` — test callers only
   - **Zero production callers.**

2. **Sort-metric drift within the dead code.** `SelectBankForPayout` → `selectBank(..., "payout", "")` → at `services/bankRotation.go:276-287`:

```go
} else {  // method == "payout"
    findOpts := options.FindOne().
        SetSort(bson.D{
            {Key: "deposit_count_date", Value: 1},
            {Key: "deposit_count", Value: 1},
        })
    err = db.GetCollection("system_banks").FindOne(ctx, filter, findOpts).Decode(&selectedBank)
}
```

But the comment at lines 240-241 says:
> "For payout: keep plain FindOne (no deposit_count mutation; **payout uses daily_transactions/balance** which are reconciled by syncBankTransactionCounts)."

Comment claims payout routing uses `daily_transactions/balance` but the actual sort keys are `deposit_count_date, deposit_count` (the deposit-direction counter). If any code path called `SelectBankForPayout`, it would rotate payouts based on **deposit** counts — nonsensical for payout-direction fairness.

## Why no impact in production

The ACTUAL payout pick happens in `scheduler/withdrawal_dispatcher.go findBestBankForItem` (lines 475-565) which correctly uses `bankDailyTxn` (withdrawal-direction via `bank.DailyTransactions` + `OutstandingCountForBank` queue load + in-tick assignments).

`SelectBankForPayout` appears to be either:
- A legacy function from earlier sync-payout-pick architecture, retired in favor of dispatcher (async tick-based).
- A never-used stub pending future refactor.

Tests reference it (test files in `tests/...`) but production does not.

## Drift classification

- **Dead-code drift:** function exists, documented, tested, but has no production call site. Risk surface: a future contributor might re-introduce a caller + inherit the metric bug.
- **Comment/code drift:** comment claims `daily_transactions` metric; code uses `deposit_count`. Safe only because dead.

## Companion drift same day

`countTodayCompletedTransactions` (`scheduler/withdrawal_dispatcher.go:444-471`) is also dead code in the same repo, filed separately during 2026-04-24 Input 5 sweep. Cross-direction counting function defined but never called.

Two dead-code findings on cross-direction / payout-rotation logic in a single pass suggests this area had an architectural refactor that didn't clean up orphans. Worth a brief archaeology pass to confirm.

## How to apply / W4 candidate

Recommended disposition for pg-writer W4 (drift resolution):
- **Option 1 (safe):** delete `SelectBankForPayout` + companion dead code; remove test references to orphaned functions.
- **Option 2 (revive):** add a production caller that needs sync payout pick — e.g., a new admin "re-route payout" endpoint. Fix the metric while at it (sort by `daily_transactions_date, daily_transactions`).
- **Option 3 (document):** mark function with `// DEPRECATED: replaced by scheduler/withdrawal_dispatcher.findBestBankForItem` + same for `countTodayCompletedTransactions`.

## Cites

- `services/bankRotation.go:61-64` (definition)
- `services/bankRotation.go:276-287` (the sort-drift code path)
- `services/bankRotation.go:240-241` (the comment that contradicts the code)
- `scheduler/withdrawal_dispatcher.go:444-471` (companion dead code — `countTodayCompletedTransactions`)
- Tests: `tests/dispatcher/payout_pool_method_test.go` + `tests/withdrawal_queue/*` reference SelectBankForPayout in test-only contexts

Verified @ mobiz `19e0bed` (2026-04-24 GMT+7) during architect Input 5 sweep for ADR-8 pass-2 fairness verification.

## Not a blocker for next-system

Next-system `fair-router` ports `findBestBankForItem` (the live code), not `SelectBankForPayout` (the dead code). Drift is current-system hygiene only — no next-system design impact.

---
*Added via Oracle Learn*
