---
title: # Drift: `resolvePoolBankIDs` nil-fallback silently disables pool isolation when
tags: [drift, withdrawal-queue, dispatcher, pool, ops-config, w4-candidate, multi-tenancy, silent-fallback]
created: 2026-04-22
source: pg-writer (Oracle thread #43 follow-up)
project: github.com/kokarat/mobiz-payment-gateway
---

# # Drift: `resolvePoolBankIDs` nil-fallback silently disables pool isolation when

# Drift: `resolvePoolBankIDs` nil-fallback silently disables pool isolation when client + merchant both lack `PoolID`

**Status:** `#drift #withdrawal-queue #dispatcher #pool #ops-config #w4-candidate`
**Severity:** latent — no runtime error, policy-level violation only
**Scope:** mobiz-payment-gateway, current system, all `payout` / `settlement` withdrawal-queue items
**Verified at:** HEAD `aa8cde8` (2026-04-22 GMT+7)
**Related:**
- `learning_2026-04-22_w1-refine-pass-2-withdrawal-dispatch-claim-ra` (mb-next-payment-gateway, pass-2 ADR record)
- `learning_2026-04-22_w1-pass-3-thread-43-classification-crosslink` (mb-next-payment-gateway, cross-link back to here)
- Oracle thread #43 — classification + source discussion
- mobiz-payment-gateway PR #286 — doc-drift fix that uncovered the gap

## The drift

`scheduler/withdrawal_dispatcher.go:569-624` (`resolvePoolBankIDs`) returns `nil` in three cases:

1. `item.ClientID.IsZero()` — **intended**, covers pullout / direct-transfer (admin-driven items have no client).
2. `client` not found, or `client.PoolID == ""`, AND `merchant.PoolID == ""` (or merchant not found).
3. `client.PoolID` or `merchant.PoolID` set but not a valid ObjectID hex, or the referenced pool has `status != 1`.

Case (1) is correct-by-design. Cases (2) and (3) are the **silent-fallback drift**: `findBestBankForItem:534-546` only filters by pool membership when `len(poolBankIDs) > 0`; when it's `nil`, the check is skipped entirely and *any* idle bank the method permits becomes a candidate. The item still completes successfully — just not through the client's configured pool.

## Why it's load-bearing

- **Detection cost is high.** No error raised, no metric emitted, no log warning. The only signal is downstream: a completed payout whose `system_bank_id` points at a bank the client's pool does not include. Requires pool-membership auditing on completed items — not on by default in this codebase.
- **Correct-path coverage hides it.** As long as onboarding sets `client.PoolID` (or at minimum `merchant.PoolID`), the drift cannot fire. Production is effectively single-pool per merchant, so the fallback has likely never triggered — exactly the reading that made the architect pick Hypothesis 2 before the classification (see thread #43).
- **Cross-pool in a multi-tenant future.** The moment two live pools share a method-capability (e.g. both Pool-A and Pool-B have payout-capable KTB banks) AND a client arrives with unset `PoolID` on both client *and* merchant, Client-A's payout can go out from a Pool-B bank. This is the scenario the next-system ADR-4a (DB-level `NOT NULL pool_id` + CHECK + RPC Layer 2a re-derivation) is designed to close.

## Why the config-dependent mitigation is not enough

The existing mitigation is purely ops-driven: *"always set `client.PoolID` OR `merchant.PoolID`"*. Validation lives in no single enforcement point — it is scattered across admin UI forms and controller validation. There is no:
- MongoDB schema constraint requiring the field
- Index-backed invariant
- Runtime check in `EnqueueWithdrawal` rejecting items whose resolution chain would end in `nil`
- Alert on `poolBankIDs == nil` at dispatch time

So the invariant is enforceable only by convention. That is exactly the shape of drift that thread #43 Hypothesis 2 called out — just pushed one level deeper than the architect's original grep found it.

## How to apply

- **If you are reviewing a client / merchant creation path**: verify that `pool_id` is required at the controller layer. If not, that's the same drift — file a sibling learning.
- **If you are editing `resolvePoolBankIDs`**: do not "simplify" the three nil-return paths into a single return. Case (1) must stay distinct from cases (2)/(3) because only (1) is intended.
- **If you are reviewing a bug report shaped "client X's payout came out of the wrong bank"**: first query is `db.withdrawal_queue.aggregate([{ $lookup: clients on client_id }, { $match: { $expr: { $not: { $in: ["$system_bank_id", "$client.pool.bank_accounts.bank_id"] } } } }])` — if any documents come back, this drift fired.
- **If you are designing a next-system replacement**: do not rely on `pool_id` being present — require it at the DB layer. Align with mb-next-payment-gateway ADR-4a.

## Suggested W4 fix (single-line, low risk)

In `scheduler/withdrawal_dispatcher.go:596-598`:

```go
// current:
if poolID == "" {
    return nil // no pool configured — any bank is fine
}
```

Change to return a sentinel error or log-and-return-empty-slice so the caller can distinguish "no pool filter needed" (pullout / DT) from "pool filter needed but unresolvable" (drift). Couple with a rejection in `EnqueueWithdrawal` when source_type is `payout` or `settlement` and the resolution chain would fail. Zero impact on correctly-configured clients; converts silent cross-pool routing into a loud enqueue-time failure for mis-configured ones. Leave the `item.ClientID.IsZero()` path untouched — that case is intended.

Whether to ship this change is a code-reviewer / architect call, not a writer call. Filing this learning so the W4 reconcile-drift agent can pick it up with full context.

## Non-goals of this learning

- Not proposing to reject pullout / direct_transfer items that have no client — those are admin-driven and correctly bypass pool filtering.
- Not claiming any production incident caused by this drift. None observed as of 2026-04-22. Severity is "latent, policy-level" not "active, data-loss".
- Not duplicating the code-fix work — W4 / code-reviewer owns the fix decision.

---
*Added via Oracle Learn*
