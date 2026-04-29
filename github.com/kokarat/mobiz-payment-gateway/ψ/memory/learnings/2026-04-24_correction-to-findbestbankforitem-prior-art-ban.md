---
title: Correction to findBestBankForItem prior-art — `bankDailyTxn` is WITHDRAWAL-ONLY,
tags: [system-architect, repo:cross, repo:mobiz-payment-gateway, current, repo:mb-next-payment-gateway, next, prior-art, correction, withdrawal-queue, dispatcher, findBestBankForItem, bankDailyTxn, withdrawal-only-metric, supersedes, process-lesson, dead-code-lesson, adr-8, w1-input-5]
created: 2026-04-24
source: Re-verification of scheduler/withdrawal_dispatcher.go:108,166-179,252,284,475-565 + services/withdrawalQueue.go:841 + controllers/BotConfigController.go:706-712 + grep verification of countTodayCompletedTransactions callers @ mobiz 19e0bed (2026-04-24 GMT+7)
project: github.com/kokarat/mobiz-payment-gateway
---

# Correction to findBestBankForItem prior-art — `bankDailyTxn` is WITHDRAWAL-ONLY,

Correction to findBestBankForItem prior-art — `bankDailyTxn` is WITHDRAWAL-ONLY, not cross-direction (supersedes earlier same-day claim).

## Supersedes

This learning **supersedes** `learning_2026-04-24_current-system-prior-art-findbestbankforitem-u` filed earlier today. That learning claimed `bankDailyTxn` counts deposit + withdrawal activity cross-direction, citing `countTodayCompletedTransactions` (`scheduler/withdrawal_dispatcher.go:444-471`) as evidence. That claim was wrong — `countTodayCompletedTransactions` is dead code (zero production callers); it does NOT feed `bankDailyTxn`. Verified by tracing every writer of `bank.DailyTransactions` on 2026-04-24 GMT+7.

## Corrected: what `bankDailyTxn` actually is

Three components, **all withdrawal-side only**:

### 1. `base` = persistent daily count (lines 170-173)
```go
if bank.DailyTransactionsDate == todayBKK {
    base = int64(bank.DailyTransactions)
} else {
    base = 0  // stale date → treat as fresh day
}
```

`bank.DailyTransactions` is written by TWO paths, both withdrawal-only:
- **`services.MarkSuccess`** (`services/withdrawalQueue.go:841`) — `$inc daily_transactions: 1` on each withdrawal success. Withdrawal-direction.
- **`controllers.syncBankTransactionCounts`** (`controllers/BotConfigController.go:706-712`) — sets to `outCount = CountDocuments(bank_statements WHERE direction='out')`. Withdrawal-direction (bot scrape reconcile).

Deposit-direction tracking is a SEPARATE field: `deposit_count`, written by `services.SelectBankForDeposit` (atomic pick+increment at API request time) + same `syncBankTransactionCounts` function with `inCount = direction='in'`.

### 2. `queueLoad` = live in-flight (line 176)
```go
queueLoad := services.OutstandingCountForBank(ctx, bank.ID)
```
Count of `withdrawal_queue` items currently `pending` or `processing` on this bank. Withdrawal-only. Added post-2026-04-11 bursty-enqueue pile-on fix (9 payouts to one bank when no MarkSuccess had fired yet).

### 3. In-tick `bankDailyTxn[bestBank.ID]++` (line 284)
In-memory only; resets next tick. Each withdrawal assignment in this round.

## Selection unchanged (still correct)

Lines 554-565 select bank with lowest `bankDailyTxn` — explicit least-count LRU. Unchanged from original learning.

## Why the original claim was wrong

`countTodayCompletedTransactions` at lines 444-471 counts deposit + withdrawal:
```go
// 1. Deposits (paid) + 2. Withdrawal queue (success)
total += inCount + outCount
```

I cited this function as the source of `bankDailyTxn`'s cross-direction behavior. But `grep -rn countTodayCompletedTransactions --include="*.go"` returns only the definition — zero callers. It is orphaned. Function body + intent are cross-direction, but the function never executes in production, so it does not feed any live metric.

The real writers of `bank.DailyTransactions` both filter `direction='out'` (withdrawal only).

**Class-of-bug lesson:** citing function-comment/function-body as behavioral evidence without grep-verifying call-sites. Caught by user review during thread #46 ratification discussion.

## Two independent LRU counters (corrected observation)

| Counter | Direction | Used by |
|---|---|---|
| `deposit_count` | in | `SelectBankForDeposit` → deposit rotation (sync at API time) |
| `daily_transactions` | out | `findBestBankForItem` → withdrawal rotation (async at dispatcher tick) |

No cross-visibility between the two rotations. **Latent anti-detect blind spot** in current system — bank portal sees total activity (both directions), but rotations coordinate only within their own direction.

## Companion findings (same-day drift learnings)

- `learning_2026-04-24_drift-selectbankforpayout-is-dead-code-sort` — `SelectBankForPayout` is also dead code + has sort-metric drift (comment says `daily_transactions`, code uses `deposit_count`).
- `countTodayCompletedTransactions` dead code (flagged in body above; will be part of the SelectBankForPayout drift learning).

Two dead-code findings in the bank-rotation/dispatch surface on one day — suggests this area had an architectural refactor that left orphans.

## Companion correct finding

- `learning_2026-04-24_current-system-prior-art-deposit-routing-via-se` — deposit routing via `SelectBankForDeposit` (sync pick+increment at API time). Paired with this learning to give the full withdrawal+deposit picture.

## DRIFT-12 (tier-cap uniform vs independent) — unchanged

Unrelated to this correction; still open at `19e0bed`. Lines 210-215 comment claims per-bank-independent cap; code at lines 227-241 applies uniformly.

## Implication for next-system fair-router (§ADR-8 pass 2 + amendment)

**Verbatim port** = withdrawal-only metric (current parity; minimally risky).

**Phase-2 opportunity** = unified metric (`deposit_count + daily_transactions` or weighted blend) → closes anti-detect blind spot. Explicit design choice, not parity port. Recommended to flag as sub-question in thread #46 if architect pursues; otherwise defer to implementation-phase decision.

§ADR-8 amendment text (`docs/adr.md` commit `b87fc1a`) currently says "Cross-direction counting preserved (deposit + withdrawal)" — **this is factually wrong and will be corrected in a follow-up amendment commit** citing this learning. Thread #46 will receive a correction message.

## Cites (unchanged from original + corrections)

- `scheduler/withdrawal_dispatcher.go:108 dispatch()` @ mobiz `19e0bed`
- `scheduler/withdrawal_dispatcher.go:166-179` (bankDailyTxn population — withdrawal-only) @ `19e0bed`
- `scheduler/withdrawal_dispatcher.go:252` (findBestBankForItem call site) @ `19e0bed`
- `scheduler/withdrawal_dispatcher.go:475-565` (function body) @ `19e0bed`
- `scheduler/withdrawal_dispatcher.go:554-565` (least-count selection) @ `19e0bed`
- `scheduler/withdrawal_dispatcher.go:444-471` (dead code — `countTodayCompletedTransactions`) @ `19e0bed`
- `services/withdrawalQueue.go:841` (`MarkSuccess` `$inc daily_transactions: 1`) @ `19e0bed`
- `controllers/BotConfigController.go:706-712` (`syncBankTransactionCounts` → `daily_transactions = outCount`) @ `19e0bed`

## Process lesson (durable)

**Citing function-comment or function-body as behavioral evidence without grep-verifying call-sites is a class-of-bug.** Rule for future architect Input 5 reads:
1. Find the function that implements the claimed behavior.
2. `grep -rn <function_name> --include="*.go" | grep -v _test.go` to find production callers.
3. If zero callers → flag as dead code; do NOT use as evidence for live system behavior.
4. If callers exist → trace the call path to confirm the behavior actually reaches production.

Dead code is worse than missing code: missing code is obvious; dead code looks alive but lies.

---
*Added via Oracle Learn*
