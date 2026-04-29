---
title: Current-system prior art — withdrawal_queue: pool usage differs by source_type (
tags: [system-architect, repo:cross, prior-art, repo:mobiz-payment-gateway, current, repo:mb-next-payment-gateway, next, pool, withdrawal-queue, source-type, settlement, pullout, direct-transfer, payout, data-model, migration-map, drift-candidate, w1-input-5]
created: 2026-04-22
source: services/withdrawalQueue.go + controllers/{Settlement,PullOutTask,DirectTransfer}Controller.go @ kokarat/mobiz-payment-gateway HEAD, read 2026-04-22 GMT+7
project: github.com/kxlahsimx09/mb_agent_oracle_memory
---

# Current-system prior art — withdrawal_queue: pool usage differs by source_type (

Current-system prior art — withdrawal_queue: pool usage differs by source_type (Pool-rotation vs admin-direct).

Confirmed via direct read of `services/withdrawalQueue.go`, `controllers/SettlementController.go`, `controllers/PullOutTaskController.go`, `controllers/DirectTransferController.go` at `kokarat/mobiz-payment-gateway@HEAD` (2026-04-22 session, system-architect role, W1 Input 5 summarizing pass).

## Question asked

Do settlement and pullout use Pool rotation, or specify bank directly at enqueue?

## Answer

**Split.** The four withdrawal-queue source types divide into TWO enqueue-time shapes:

| Source Type | `SystemBankID` at enqueue | Assigned by | Pool involvement |
|---|---|---|---|
| **Payout** | empty | Dispatcher (`AssignBankToItems`) | Validated at request but not at dispatch |
| **Settlement** | empty | Dispatcher (`AssignBankToItems`) | Validated at request but not at dispatch |
| **Pullout** | **required** (`validate:"required"`) | Admin at API call | ❌ not used |
| **Direct Transfer** | **required** (`validate:"required"`) | Admin at API call | ❌ not used |

## Source evidence

`services/withdrawalQueue.go:199-207` (EnqueueWithdrawalParams):

```go
// System bank fields - optional at enqueue time
// For pullout/direct_transfer: known at creation (set by caller)
// For payout/settlement: assigned later by dispatcher
SystemBankID      primitive.ObjectID
```

`services/withdrawalQueue.go:702-724` (BankSupportsSource — single source of truth):

```go
// source_type "pullout"         → ANY bank (internal sweep)
// source_type "direct_transfer" → ANY bank (admin manual select)
// source_type "payout"          → bank.method must contain "payout"
// source_type "settlement"      → bank.method must contain "settlement"
if sourceType == models.SourceTypePullout ||
   sourceType == models.SourceTypeDirectTransfer {
    return true
}
for _, method := range bank.Method {
    switch method {
    case "payout":     if sourceType == models.SourceTypePayout     { return true }
    case "settlement": if sourceType == models.SourceTypeSettlement { return true }
    }
}
return false
```

Comment explaining the rationale (:682-696):

> The `method` array describes which CUSTOMER-FACING services a bank account is exposed for; it does NOT constrain admin-driven internal transfers. In real operations: a topup-only bank still has to be able to sweep its accumulated balance out to a payout bank (Pullout); a deposit-only bank has to be able to top up another working account (Pullout); when a customer is refunded from the exact bank they deposited into, the admin manually selects that bank even if its method is topup/deposit only (Direct Transfer). Both Pullout and Direct Transfer are admin-driven manual operations, so the method array does not restrict them.

`controllers/PullOutTaskController.go:36-43` (enqueue shape):

```go
SystemBankID  string `json:"system_bank_id" validate:"required"`
SystemBankName string `json:"system_bank_name"`
// ... source bank pre-populated by admin in request
```

`controllers/DirectTransferController.go:36` — same `validate:"required"` pattern.

`controllers/SettlementController.go:315` — settlement record created with `// SystemBank fields assigned later by withdrawal dispatcher` comment. Enqueue only requires `merchant.PoolID` to exist (validation gate), not to pre-select a system bank.

## Surprising finding (drift candidate for current-system, design note for next)

The **dispatcher's `AssignBankToItems` filter has NO `pool_id` / `client_id` check** (services/withdrawalQueue.go:340-348):

```go
filter := bson.M{
    "status":      models.QueueStatusPending,
    "source_type": bson.M{"$in": supportedSources},
    "$or": []bson.M{
        {"system_bank_id": primitive.NilObjectID},
        {"system_bank_id": bson.M{"$exists": false}},
    },
}
```

This means a Payout item belonging to Client-A (Pool-Alpha) could theoretically be assigned a bank from Pool-Beta at dispatch time, provided that bank supports `method=payout`. Pool isolation is enforced only at:

1. Enqueue validation (merchant must have a pool assigned — prevents orphan settlements).
2. DEPOSIT rotation (`bankRotation.SelectBankForDeposit` / `SelectBankForPayout` scopes candidates to the client's pool).

Withdrawal-queue dispatcher does NOT re-verify the pool at assignment. The current system apparently relies on:
- Deployment practice where banks are effectively single-pool, OR
- Admin UI constraint where banks are only ever added to one pool, OR
- This is a latent multi-tenancy leak that simply hasn't surfaced because the system runs with a single pool in practice.

**Status:** Worth opening a drift thread with `pg-writer` (mobiz technical-writer) to confirm whether this is intended or latent. For the next-system ADR-4a, user's proposed pool-level broadcast filter is stricter than current and fixes this asymmetry.

## Implications for mb-next-payment-gateway ADR-4a

The next-system design must accommodate BOTH enqueue shapes cleanly:

### Mode 1 — Pool-broadcast (Payout, Settlement)

- `withdrawal_queue` row has `pool_id` (inherited from client at enqueue) and `required_method IN ('payout','settlement')`
- `system_bank_id` / `bank_account_id` NULL until claim
- Realtime broadcast filter: `pool_id = :bot_pool AND required_method IN :bot_bank_methods`
- Bots in that pool race to claim; `claim_withdrawal_items` RPC enforces invariants atomically

### Mode 2 — Direct-address (Pullout, Direct Transfer)

- `withdrawal_queue` row has `required_bank_account_id` (set by admin at request) and `required_method IS NULL` (method check bypassed — matches current `BankSupportsSource` policy)
- Realtime broadcast filter: `required_bank_account_id = :bot_bank_account_id`
- Only one bot receives the broadcast — no competition
- `claim_withdrawal_items` RPC still enforces the one-batch-per-bank invariant (so if that specific bot is busy with another batch, the pullout waits until it's done — consistent with thread #29 design intent from mobiz)

### Schema sketch

```sql
CREATE TABLE withdrawal_queue (
    id uuid PRIMARY KEY,
    source_type source_type_enum,     -- payout|settlement|pullout|direct_transfer
    source_id uuid,
    -- Mode 1 fields
    pool_id uuid,
    required_method method_enum NULL, -- NULL for admin-driven (mode 2)
    -- Mode 2 fields
    required_bank_account_id uuid NULL,
    -- Filled at claim time (both modes)
    bank_account_id uuid NULL,
    batch_id uuid NULL,
    status queue_status_enum,
    ...
    CHECK (
      (source_type IN ('pullout','direct_transfer') AND required_bank_account_id IS NOT NULL)
      OR
      (source_type IN ('payout','settlement') AND pool_id IS NOT NULL AND required_method IS NOT NULL)
    )
);
```

The CHECK constraint encodes the source_type → enqueue-shape rule as a database invariant rather than convention.

## Files read (frozen for audit)

- `services/withdrawalQueue.go` lines 180-399, 650-724 — enqueue params, AssignBankToItems, BankSupportsSource
- `controllers/SettlementController.go` lines 150-340 — settlement enqueue (pool required, bank empty)
- `controllers/PullOutTaskController.go` lines 36-150 — pullout enqueue (system_bank_id required)
- `controllers/DirectTransferController.go` lines 34-150 — direct transfer enqueue (system_bank_id required)

All read at current HEAD (2026-04-22 session). Commit-sha pinning not captured this pass; the next refine pass should pin if cited in an ADR `#decision`.

---
*Added via Oracle Learn*
