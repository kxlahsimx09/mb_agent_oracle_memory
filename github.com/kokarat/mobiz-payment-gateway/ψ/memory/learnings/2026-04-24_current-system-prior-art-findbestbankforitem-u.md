---
title: Current-system prior art — `findBestBankForItem` uses explicit least-daily-count
tags: [system-architect, repo:cross, repo:mobiz-payment-gateway, current, repo:mb-next-payment-gateway, next, prior-art, withdrawal-queue, dispatcher, bank-rotation, fairness, load-balance, least-count-lru, findBestBankForItem, tier-cap-drift, adr-8, w1-input-5]
created: 2026-04-24
source: scheduler/withdrawal_dispatcher.go:108,166-179,252,475-565 @ mobiz 19e0bed (Input 5 direct read 2026-04-24 GMT+7 for ADR-8 pass 2 fairness evaluation)
project: github.com/kokarat/mobiz-payment-gateway
---

# Current-system prior art — `findBestBankForItem` uses explicit least-daily-count

Current-system prior art — `findBestBankForItem` uses explicit least-daily-count LRU selection, not FIFO spread (withdrawal dispatcher).

## Verified call-site (Input 5 direct read, mobiz HEAD `19e0bed`)

**File:** `scheduler/withdrawal_dispatcher.go`
**Line 252:** `findBestBankForItem(...)` called once per unassigned item inside `dispatch()` loop.
**Lines 475-565:** function body.

## Filter sequence (eligibility gate)

For each candidate bank in `idleBanks`:
1. **Method support** — `bankSupportsSource(bank, item.SourceType)` (lines 493-496).
2. **Remaining balance** — `bank.AvailableBalance - bankAssignedAmount[bank.ID]` must be ≥ `item.Amount`. Note subtraction: balance is decremented in-memory as items are assigned in this tick (lines 497-501).
3. **`MaximumOutstandingWithdrawal`** — admin-set per-bank ceiling on total outstanding amount (pending + processing + this-round). `0 = unlimited` (lines 505-510).
4. **Per-bank tier cap** — `inflight = bankInitialQueueLoad[bank.ID] + bankAssignedCount[bank.ID]` must be `< cap`. Where `cap = bankCaps[bank.ID]` (defaults to 5 if unset). **Also `bankAssignedCount[bank.ID] < cap`** separately enforced (lines 523-533).
5. **Pool membership** — if `resolvePoolBankIDs` returns non-nil, bank must appear in that list (lines 534-546).

## Selection (the critical finding)

**Lines 554-565:**

```go
// Pick bank with lowest daily_transactions (load balance)
best := &candidates[0]
bestCount := bankDailyTxn[best.ID]
for i := 1; i < len(candidates); i++ {
    count := bankDailyTxn[candidates[i].ID]
    if count < bestCount {
        best = &candidates[i]
        bestCount = count
    }
}
return best
```

**This is explicit least-daily-count LRU selection — strictly fair by usage.** Not round-robin. Not best-fit by balance. Not weighted random. Simply: "candidate bank with fewest transactions today wins."

## How `bankDailyTxn` is populated (lines 166-179)

```go
todayBKK := helpers.GetDateBKK()
bankDailyTxn := make(map[primitive.ObjectID]int64)
for _, bank := range idleBanks {
    var base int64
    if bank.DailyTransactionsDate == todayBKK {
        base = int64(bank.DailyTransactions)
    }
    queueLoad := services.OutstandingCountForBank(ctx, bank.ID)
    bankInitialQueueLoad[bank.ID] = queueLoad
    bankDailyTxn[bank.ID] = base + queueLoad
}
```

Three components:
1. **Stored count** (`bank.DailyTransactions`) — written persistently by `services.MarkSuccess` (first successful withdrawal of day) and `controllers.syncBankTransactionCounts` (first statement scrape of day). Stale count silently treated as 0 (lines 137-151).
2. **Queue load** (`OutstandingCountForBank`) — pending + processing items currently on the bank. Added to handle bursty-enqueue pile-on observed in 2026-04-11 production (9 payouts to one bank because no MarkSuccess yet, daily count stayed 0 for all).
3. **In-tick assignments** — `bankDailyTxn[bestBank.ID]++` after each successful assignment (line 284), so subsequent iterations in this tick see the updated count.

## Cross-activity counted

`bank.DailyTransactions` counts **deposits + withdrawals** (via `countTodayCompletedTransactions` at lines 446-471: `ts_deposits` with status=paid + `withdrawal_queue` with status=success). Fairness metric is **bank's total activity**, not withdrawal-only — consistent with anti-detection: banks see unified account activity regardless of direction.

## Drift: line 210-215 comment lies

Comment at lines 210-215 says:
> "Each bank's cap is picked independently (different random value per bank) so the pattern stays varied across banks instead of every bank receiving the exact same count."

But lines 227-241 draw ONE `perBankCap` value and apply it uniformly to all banks:

```go
perBankCap = mrand.Intn(5) + 1  // etc per tier
bankCaps := make(map[primitive.ObjectID]int, len(idleBanks))
for _, bank := range idleBanks {
    bankCaps[bank.ID] = perBankCap  // same value for every bank
}
```

This is **DRIFT-12** in mobiz `docs/current-system.md` §9. Still open at HEAD `19e0bed`; only the tier-table values drift (1-3 vs 1-5) was resolved by `d951641` per thread #29, not this one. Operational behavior: pool-wide uniform cap per tick (not per-bank independent).

## Implication for next-system design

**Previous architect learning** (`2026-04-22_current-system-prior-art-withdrawalqueue-pool` and pass-1 ADR-8 thinking) characterized current fairness as "statistical / per-tick cap." That framing **undersells current behavior** — current has explicit LRU-by-usage selection that is strong fairness, not statistical.

**For ADR-8 pass 2 (push-vs-pull re-evaluation):**
- **Pull + RPC tier-cap bolt-on (Option D+A) does NOT replicate current fairness.** To replicate, the RPC would need to know "is this bank among the lowest-count banks in its pool right now?" — which requires pool-wide view at claim time. The race-to-claim nature of pull means bots don't inherently coordinate on "whose turn is it by count." A fast bot on a high-count bank would grab items it shouldn't in the current-system's fairness model.
- **Fair-router EF (Option F) is the natural port of this logic.** The function body at lines 475-565 is ~90 lines of straightforward pool-aware least-count selection with cap + balance guards — ports cleanly to TypeScript. Same decision surface, different language.
- **Strong fairness is NOT aspirational in current system** — it's coded and active. Any next-system design that preserves current fairness semantics must have centralized (or coordinated) bank selection; pull alone does not get there.

## Related drifts observed this read

- Line 210-215 comment drift (DRIFT-12, still open).
- `resolvePoolBankIDs` at line 569-624: nil-fallback when client + merchant both lack `PoolID` (already filed by pg-writer as `2026-04-22_drift-resolvepoolbankids-nil-fallback-silentl`, thread #43 Hypothesis 3 ratified).

## Cites

- `scheduler/withdrawal_dispatcher.go:108 dispatch()` @ mobiz `19e0bed`
- `scheduler/withdrawal_dispatcher.go:166-179` (bankDailyTxn population) @ `19e0bed`
- `scheduler/withdrawal_dispatcher.go:252` (findBestBankForItem call site) @ `19e0bed`
- `scheduler/withdrawal_dispatcher.go:475-565` (findBestBankForItem body) @ `19e0bed`
- `scheduler/withdrawal_dispatcher.go:554-565` (least-count selection — the critical lines) @ `19e0bed`
- `scheduler/withdrawal_dispatcher.go:444-471` (countTodayCompletedTransactions: deposit + withdrawal cross-activity) @ `19e0bed`
- `scheduler/withdrawal_dispatcher.go:210-215` (comment drift) @ `19e0bed`

Production incident informing the design: 2026-04-11 "9 payouts to one bank" burst pile-on — fixed by including queue load in daily count.

---
*Added via Oracle Learn*
