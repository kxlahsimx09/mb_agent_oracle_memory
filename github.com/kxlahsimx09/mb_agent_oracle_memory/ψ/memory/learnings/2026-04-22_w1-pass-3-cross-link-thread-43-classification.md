---
title: W1 pass 3 — cross-link: thread #43 classification (pg-writer) ↔ ADR-4a fact corr
tags: [system-architect, repo:mb-next-payment-gateway, repo:cross, repo:mobiz-payment-gateway, next, current, adr, withdrawal-queue, dispatcher, pool, nil-pool-fallback, ops-config-surface, cross-link, thread-43, pg-writer-classification-accepted, w1, pass-3, hypothesis-3]
created: 2026-04-22
source: Oracle thread #43 (closed 2026-04-22 Hypothesis 3) + docs/adr.md@5d2d8f0 (pass-3 §Revision log entry)
project: github.com/kxlahsimx09/mb_agent_oracle_memory
---

# W1 pass 3 — cross-link: thread #43 classification (pg-writer) ↔ ADR-4a fact corr

W1 pass 3 — cross-link: thread #43 classification (pg-writer) ↔ ADR-4a fact correction.

## What happened

Pass-1 and pass-2 §ADR-4a cited `services.AssignBankToItems` (mobiz) as the dispatcher-side pool-filter missing-filter evidence, opening Oracle thread #43 to pg-writer for classification. pg-writer replied 2026-04-22 classifying as **Hypothesis 3** — my citation was the wrong call site; `AssignBankToItems` is test-only code with no production caller. The real dispatch path is in `scheduler/withdrawal_dispatcher.go`:

```
dispatch() :108
  → findBestBankForItem() :252 (HEAD aa8cde8; :475 @ 4e84ad5)
    → resolvePoolBankIDs() :569-624
        ├─ item.ClientID.IsZero()  → skip filter (pullout/DT)
        ├─ FindOne(clients, {_id: ClientID}) → client.PoolID
        ├─ fallback FindOne(merchants, {_id: MerchantID}) → merchant.PoolID
        └─ FindOne(pools, {_id, status:1}) → pool.BankAccounts[].BankID
```

So `ClientID` / `MerchantID` on `EnqueueWithdrawalParams` (with the "for pool-based bank selection" comment that I couldn't find a caller for) *are* used — in the scheduler package, not the services package I grepped.

## Why this is a cross-link learning (not a supersede)

Pass-2 §ADR-4a's **decision** is unchanged. The next-system design (pool-broadcast Mode 1 + direct-address Mode 2 + DB-enforced `NOT NULL pool_id` + CHECK constraint + RPC Layer 2a pool re-derivation) is still correct. Only the current-system *citation* needed correction.

In fact the justification for the next-system design got **stronger**, not weaker: instead of "close the gap where current system has no pool filter at all" (wrong), the reframe is "close the gap where current system has a pool filter conditional on ops-config completeness, and falls through to any-bank when config is incomplete" (correct and genuinely worth closing).

Therefore:
- `arra_supersede` NOT applied — pass-2 learning (`learning_2026-04-22_w1-refine-pass-2-withdrawal-dispatch-claim-ra`) remains the primary ADR record.
- This pass-3 learning is a **cross-link**: it connects pass-2's architect claim to pg-writer's `scheduler/withdrawal_dispatcher.go` classification and to pg-writer's forthcoming drift learning on the `nil poolBankIDs` fallback.

## The gentler gap that the next system still closes

`scheduler/withdrawal_dispatcher.go:596-598` (`resolvePoolBankIDs`): if both `client.pool_id` and `merchant.pool_id` are unset, returns `nil` → dispatcher falls through to "any idle bank of matching method". Ops-config-dependent, silent (no error, no metric), policy-level cross-pool routing.

Closed in next system by:
1. `withdrawal_queue.pool_id NOT NULL` for Mode 1 (payout/settlement) + CHECK constraint — a row with missing pool_id is rejected at INSERT time, not at dispatch time, by the database engine.
2. RPC Layer 2a re-derives `v_pool_id` from `bank_account_id` via `pool_bank_account` join — unconditional DB-authoritative pool check, not config-dependent.

## Cross-references

- My side:
  - `learning_2026-04-22_current-system-prior-art-withdrawalqueue-pool` (pass-2 Input-5 direct read — cited `AssignBankToItems`, the wrong call site. Still useful as a record of the source-type enqueue split; the AssignBankToItems citation within it is corrected by this pass-3 learning.)
  - `learning_2026-04-22_w1-refine-pass-2-withdrawal-dispatch-claim-ra` (pass-2 ADR record — the "gap closed" framing there pointed at `AssignBankToItems` per my pass-2 understanding at the time).
  - `docs/adr.md` §ADR-4a §Current-system shape + §Security boundary + §Prior art + §Revision log (pass-3 entry) at commit `5d2d8f0` on branch `claude/cool-snyder-6effcf`.

- pg-writer's side:
  - Oracle thread #43 (closed 2026-04-22) — the classification reply itself.
  - mobiz-side doc fix — `mobiz:docs/flows/payout-request.md:113` being corrected in the same pass-3 window to point at `dispatch` + `findBestBankForItem` + `resolvePoolBankIDs` and to call out `services.AssignBankToItems` as test-only.
  - **pg-writer's forthcoming drift learning** on the `nil poolBankIDs` fallback (`:596-598`) — accepted by me in the thread #43 closing message. When filed, its `related:` frontmatter will backlink to this cross-link learning.

## Process note for future architect sessions

When citing current-system behaviour, the grep-in-services-package-then-stop pattern is insufficient. Scheduler / dispatcher logic often lives in `scheduler/` package with its own helpers that shadow services-package test utilities with the same name prefix. Before citing a function as a dispatcher path, `git grep` for production callers of that function; if the only callers are `tests/`, the function is not on the dispatch path regardless of how its filter reads.

W1 workflow's "Input 5 is last resort" rule combined with "summarize to Input 1" principle partially mitigates this — but if a summarizing learning cites a call site without verifying it has a production caller, subsequent sessions compound the error. Added to the pass-3 retrospective's "what would make the next pass cheaper" section.

## Tags

system-architect, repo:mb-next-payment-gateway, repo:cross, repo:mobiz-payment-gateway, next, current, adr, withdrawal-queue, dispatcher, pool, nil-pool-fallback, ops-config-surface, cross-link, thread-43, pg-writer-classification-accepted, w1, pass-3, hypothesis-3

---
*Added via Oracle Learn*
