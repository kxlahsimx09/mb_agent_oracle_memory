---
title: Current-system prior art — `Pool` data model (shared between deposit and payout)
tags: [system-architect, repo:cross, prior-art, repo:mobiz-payment-gateway, current, repo:mb-next-payment-gateway, next, pool, bank-rotation, data-model, migration-map, withdrawal-queue, deposit, payout, drift-known, w1-input-5]
created: 2026-04-22
source: services/bankRotation.go + models/pool.go @ kokarat/mobiz-payment-gateway HEAD, read 2026-04-22 GMT+7; W1 workflow §Input 5 direct-code-read policy ("always emit a summarizing arra_learn so the next session reads Input 1 cost")
project: github.com/kxlahsimx09/mb_agent_oracle_memory
---

# Current-system prior art — `Pool` data model (shared between deposit and payout)

Current-system prior art — `Pool` data model (shared between deposit and payout).

Confirmed via direct read of `services/bankRotation.go` and `models/pool.go` at `kokarat/mobiz-payment-gateway@HEAD` (2026-04-22 session, system-architect role, filed per W1 workflow "summarize expensive source so next session reads Input 1").

**Q: Is Pool shared between deposit and payout, or separate?**  
**A: Shared.** One `Pool` serves both. Method selection happens at the bank-account level inside the pool, not at the pool level.

## Structure (verbatim from code)

`models/pool.go`:

```go
type PoolBankAccount struct {
    BankID        primitive.ObjectID
    BankName      string
    AccountNumber string
    AccountName   string
    BankCode      string
    Method        []string  // ["deposit", "payout", "topup", "settlement"]
    PromptpayType string
    Promptpay     string
    LastUsed      *primitive.DateTime
    UsageCount    int
}

type Pool struct {
    ID           primitive.ObjectID
    PoolName     string
    Description  string
    BankAccounts []PoolBankAccount  // list of accounts in this pool
    Status       int                // 0=inactive, 1=active
    CreatedAt    primitive.DateTime
    UpdatedAt    primitive.DateTime
}
```

`services/bankRotation.go`:

- `SelectBankForDeposit(clientID, amount, excludeBankCode)` calls `selectBank(..., "deposit", ...)`
- `SelectBankForPayout(clientID, amount)` calls `selectBank(..., "payout", "")`
- Both dispatch through the same `selectBank` function — same pool resolution, same bank_accounts list.

## Client → Pool resolution chain (lines 96–111 of selectBank)

```
if client.PoolID != ""  → use client.PoolID
else                    → load merchant → use merchant.PoolID
if merchant.PoolID == "" → error "no pool configured"
```

Pool is determined through **client** first, **merchant** as fallback. Neither is optional at runtime; every rotation call needs a resolved pool.

## Method filter is at system_banks (live), not pool snapshot

`pool.bank_accounts[].method` is a **frozen snapshot** taken when a bank is added to the pool. It does NOT track later edits to `system_banks.method`. Known drift incident 2026-04-11: admin enabled `deposit` on SCB banks 4352312351 / 4352298400 after they were added to a pool with `method=["payout","settlement"]`. The pool snapshot stayed stale → `selectBank("deposit")` rejected them → every deposit routed to KTB (counts 17/14/13 vs 0).

Workaround (lines 143–146 + 400–424): treat `pool.bank_accounts` as a **pure membership list**; always filter `method` against the live `system_banks.method` field. This is load-bearing — any new deposit/payout caller must not rely on the pool snapshot.

## Rotation algorithm (different for deposit vs payout)

- **Deposit** — `FindOneAndUpdate` with pipeline that atomically increments `system_banks.deposit_count` with a daily reset (`deposit_count_date` compared to `helpers.GetDateBKK()`). Sort: `deposit_count_date ASC, deposit_count ASC`. Race-free by construction.
- **Payout** — plain `FindOne` (no count mutation). Payout uses `daily_transactions` / `balance` reconciled by `BotConfigController.syncBankTransactionCounts` using `$max` (`services/bankRotation.go:155-159` comments).

## Additional method-specific filters (lines 198–233)

- Deposit: `deposit_min_amount`, `maximum_deposit_amount`, `maximum_number_of_deposits` (vs `deposit_count`).
- Payout: `withdrawal_min_amount`, `withdrawal_max_amount`, `balance >= amount`.

## Related APIs

- `SelectBankByID(bankID, poolID)` — manual bank selection (for admin overrides). Validates the bank is in the pool.
- `GetPoolBanksForMethod(clientID, method)` — returns all eligible banks for a method. Also uses `system_banks.method` (live), not pool snapshot.
- `ResetDailyDepositCounts()` — called daily at midnight BKK to clear `deposit_count`.

## Files read (frozen snapshot for audit)

- `services/bankRotation.go` @ current HEAD (all 453 lines)
- `models/pool.go` @ current HEAD (28 lines)

## Implications for `mb-next-payment-gateway` ADR-4a (withdrawal dispatch refinement)

1. Pool is a **first-class entity** in the data model, not an optional field.
2. Pool is shared across deposit + payout; `method` filtering is per-bank-account and must stay at the bank level (Postgres equivalent: `bank_account_method` junction table — do NOT embed `method[]` on `bank_account` as a snapshot, or we recreate the 2026-04-11 drift).
3. Client → Pool resolution chain must be preserved: `client.pool_id` → fallback `merchant.pool_id` → error if neither.
4. Realtime broadcast filter on `withdrawal_queue` INSERT should be `pool_id` (inherited from client at enqueue), not `bank_code`.
5. Payout rotation uses `balance` as a hard filter, not just count. The next-system wallet design (ADR-3) needs to consider how `bank_account.balance` stays authoritative when bot is offline — may affect claim ordering.
6. Next-system RPC `claim_withdrawal_items` must validate `bot.bank_account` supports `required_method` from the row (e.g. `payout` or `settlement`) — per-bank method filtering is the architectural equivalent of current-system's `filter["method"] = method`.
7. Atomic rotation pattern (Mongo `FindOneAndUpdate` pipeline with daily reset) translates cleanly to Postgres `UPDATE … RETURNING` with a CTE for the daily-reset branch. Worth preserving at RPC level.

---
*Added via Oracle Learn*
