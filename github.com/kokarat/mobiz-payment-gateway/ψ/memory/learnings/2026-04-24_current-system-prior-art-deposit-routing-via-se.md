---
title: Current-system prior art — deposit routing via `SelectBankForDeposit` (sync pick
tags: [system-architect, repo:cross, repo:mobiz-payment-gateway, current, repo:mb-next-payment-gateway, next, prior-art, deposit, bank-rotation, selectBank, atomic-pick-increment, findOneAndUpdate, least-count-lru, sync-at-api-time, pool, w1-input-5]
created: 2026-04-24
source: services/bankRotation.go:40-306 + controllers/DepositRequestController.go:204 + controllers/BotConfigController.go:651-726 @ mobiz 19e0bed (Input 5 direct read 2026-04-24 GMT+7)
project: github.com/kokarat/mobiz-payment-gateway
---

# Current-system prior art — deposit routing via `SelectBankForDeposit` (sync pick

Current-system prior art — deposit routing via `SelectBankForDeposit` (sync pick+increment at API request time).

## Entry point + call chain

`DepositRequestController.go:204` → `services.BankRotationService.SelectBankForDeposit(clientID, amount, excludeBankCode)` → returns `*SelectedBank` with account + PromptPay details.

**Synchronous at customer API request time** — opposite of withdrawal routing (which happens async at dispatcher tick via `findBestBankForItem`).

## Full body — `services/bankRotation.go:40-306`

### Pool resolution chain (lines 95-116)
- `client.PoolID → merchant.PoolID → error "no pool configured"` — same chain as withdrawal.
- Pool active check: `pool.Status == 1`.

### Pool membership — trust-live-method pattern (lines 130-150)
- Enumerate `pool.BankAccounts[].BankID` — treat as pure ID list.
- **Do NOT trust `pool.bank_accounts[].method`** (stale snapshot, drift 2026-04-11). Method filter delegated to `system_banks.method` (live source of truth) at the query below.

### Filter stack (lines 161-233)
1. `system_banks._id ∈ pool's bank IDs`
2. `status == 1` (active)
3. `NOT IsInBankMaintenanceWindow(bank.MaintenanceTime)` — runtime filter (maintenance not in DB; computed from time ranges + current BKK time).
4. `method == "deposit"` (live method from system_banks, not pool snapshot).
5. `excludeBankCode` (case-insensitive) — used by deposit flow to route KTB payers AWAY from KTB system banks (intra-bank auto-matching quirk breaks statement reconciliation, per 2026-04-11 incident). Fallback: if filter yields 0 → re-run without the filter + log warning (never fail customer over pool composition).
6. Amount gates (deposit-specific):
   - `deposit_min_amount == 0 OR ≤ amount`
   - `maximum_deposit_amount == 0 OR ≥ amount`
   - `maximum_number_of_deposits == 0 OR stale_date OR deposit_count < max` (the "max per bank per day" ceiling)

### Atomic pick+increment (lines 242-275) — the critical pattern

```go
updatePipeline := bson.A{
    bson.M{"$set": bson.M{
        "deposit_count": bson.M{
            "$cond": bson.A{
                bson.M{"$eq": bson.A{"$deposit_count_date", todayBKK}},
                bson.M{"$add": bson.A{"$deposit_count", 1}},  // today → +1
                1,                                             // stale → reset to 1
            },
        },
        "deposit_count_date": todayBKK,
        "last_deposit_at":    now,
    }},
}
findOpts := options.FindOneAndUpdate().
    SetSort(bson.D{
        {Key: "deposit_count_date", Value: 1},
        {Key: "deposit_count", Value: 1},
    }).
    SetReturnDocument(options.After)

db.GetCollection("system_banks").FindOneAndUpdate(ctx, filter, updatePipeline, findOpts).Decode(&selectedBank)
```

**Key atomicity property:** sort + pick + increment happen in **one MongoDB round-trip**. Concurrent deposit API requests can't both observe the same "lowest count" bank — the first's increment reorders before the second's sort evaluates.

Sort key is `{deposit_count_date ASC, deposit_count ASC}`:
- Bank with stale `deposit_count_date` (int YYYYMMDD < today) sorts first — fresh-day reset treated implicitly by comparing date + picking count=0 effectively.
- Among today's banks, lowest `deposit_count` wins — strong LRU.

Returned `options.After` document reflects the post-increment state; caller gets final count in response for logging.

## Daily reset

`BankRotationService.ResetDailyDepositCounts()` (lines 443-453) — scheduled at midnight BKK; `UpdateMany({}, {$set: {deposit_count: 0}})` — blanket zero for all system banks. Resets the per-bank deposit counter so next day starts fresh. Paired with `deposit_count_date` freshness check: if counter hasn't been reset by midnight job but date is stale, `SelectBankForDeposit` pipeline's `$cond` handles it (treats as 1-first-pick for today).

## Reconcile with reality

`controllers.BotConfigController.syncBankTransactionCounts` (BotConfigController.go:651-726) reconciles `deposit_count` with scraped statement truth:
```go
"deposit_count": bson.M{
    "$cond": bson.A{
        {"$eq": [deposit_count_date, todayBKK]},
        {"$max": [deposit_count, int(inCount)]},  // today → take max
        int(inCount),                              // stale → reset to scraped count
    },
},
"deposit_count_date": todayBKK,
```

Where `inCount = CountDocuments(bank_statements WHERE direction='in' AND bank AND today)`.

Why `$max`: `SelectBankForDeposit` already incremented in-flight (customer hasn't paid yet); scraped statement count is bot's view of what actually landed. Keep the higher number — protects against understating in-flight pressure.

## Differences from withdrawal routing (cross-cutting reference)

| Aspect | Deposit (this learning) | Withdrawal (findBestBankForItem) |
|---|---|---|
| When | Sync at customer API request | Async at dispatcher tick |
| Pick method | `FindOneAndUpdate` + pipeline | `FindOne` + in-memory map loop |
| Counter mutation at pick | Atomic `+1` (or reset=1) in pipeline | **No persistent mutation** — in-memory `bankDailyTxn[++]` only |
| Counter field | `deposit_count` (incoming) | `daily_transactions` via MarkSuccess or sync (outgoing) |
| Race prevention | Single FindOneAndUpdate serializes | Distributed lock + in-memory map |
| Daily reset | `ResetDailyDepositCounts` midnight BKK | `DailyTransactionsDate` gate + MarkSuccess + sync |
| Amount gates | min/max + maximum_number_of_deposits | balance ≥ amount + withdrawal min/max + MaximumOutstandingWithdrawal |
| Admin filter | `excludeBankCode` (intra-bank quirk) | None comparable |
| Reconcile source | `bank_statements WHERE direction='in'` | `bank_statements WHERE direction='out'` |

## Cross-cutting observation: 2 independent LRU counters

- `deposit_count` rotates on incoming only.
- `daily_transactions` rotates on outgoing only.
- **No cross-visibility** between the two rotations — a bank with heavy deposits + light withdrawals can still receive more withdrawals because withdrawal LRU only sees withdrawal count.
- Anti-detection implication: bank portal sees total activity (both directions); current-system rotations don't coordinate, so total-activity skew is possible without either rotation detecting it.
- Next-system design opportunity: unified LRU metric (`deposit_count + daily_transactions`) for both rotations, or weighted blend. Not current-system parity; explicit Phase-2 design choice.

## Implication for next-system design

**Deposit routing is NOT §ADR-8 scope** (source-flow decides bank at API time; not gateway-dispatched work to bot).

Port target:
- Inline in `deposit-request` Edge Function, or shared TS module if multiple source flows need it.
- Atomic pick+increment: Postgres `UPDATE system_banks SET deposit_count = ... WHERE id = (SELECT id FROM system_banks WHERE ... ORDER BY ... LIMIT 1 FOR UPDATE) RETURNING *` or CTE with update.
- Daily reset: `pg_cron` job at midnight BKK.
- Reconcile: via deposit auto-match lane (§ADR-4's other half, ADR-N future pass) — same `$max` semantics against bot-submitted statements.

## Cross-references

- `controllers/DepositRequestController.go:204` — the sole production caller.
- `controllers/DepositRequestController.go:353` — comment confirming "deposit_count is already incremented atomically inside SelectBankForDeposit()".
- `services/bankRotation.go:155-159` — dual-source comment on deposit_count.
- `services/bankRotation.go:131-146` — pool-method drift note (2026-04-11 incident).
- `controllers/BotConfigController.go:651-726` — syncBankTransactionCounts reconcile logic.
- Learning `2026-04-22_current-system-prior-art-pool-data-model-shar` — pool data model (shared deposit+payout).
- Learning `2026-04-20_bank-rotation-selectbank-at-f694dcd-now-sorts-by-a` — prior pg-writer learning on compound sort key.
- Learning `2026-04-16_name-ktb-deposit-routing-exclude-intra-bank` — excludeBankCode origin.
- Learning `2026-04-24_current-system-prior-art-findbestbankforitem-u` — withdrawal-side counterpart; being corrected in same pass (withdrawal-only, not cross-direction).

## Cited call sites

- `services/bankRotation.go:40-59` (SelectBankForDeposit entry + fallback)
- `services/bankRotation.go:67-306` (selectBank body — the workhorse)
- `services/bankRotation.go:95-116` (pool resolution)
- `services/bankRotation.go:131-150` (pool membership + live-method pattern)
- `services/bankRotation.go:184-233` (filter stack + amount gates)
- `services/bankRotation.go:235-275` (atomic pick+increment)
- `services/bankRotation.go:443-453` (ResetDailyDepositCounts)
- `controllers/DepositRequestController.go:204` (sole caller)
- `controllers/BotConfigController.go:651-726` (reconcile)

Verified @ mobiz HEAD `19e0bed` (2026-04-24 GMT+7). Pair with the corrected withdrawal-side learning filed in the same pass.

---
*Added via Oracle Learn*
