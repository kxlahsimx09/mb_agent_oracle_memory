---
title: ## WithdrawalDispatcher behavior at `386f0a71` — idle-only + FIFO + tier-based p
tags: [repo:mobiz-payment-gateway, scheduler, technical-writer, withdrawal-dispatcher, current, flow:payout]
created: 2026-04-19
source: pg-writer-oracle W2 @ 386f0a71
project: github.com/kokarat/mobiz-payment-gateway
---

# ## WithdrawalDispatcher behavior at `386f0a71` — idle-only + FIFO + tier-based p

## WithdrawalDispatcher behavior at `386f0a71` — idle-only + FIFO + tier-based per-bank cap

Observed in `scheduler/withdrawal_dispatcher.go` at commit `386f0a71` (mobiz-payment-gateway main, 2026-04-20):

### Candidate bank selection (`#239` idle-only filter)
- Lines 188-192: candidate pool filters to banks with `working_status != busy`. Prior behavior attempted to acquire the per-bank lock on every eligible bank and let the DB reject busy ones; current behavior short-circuits at query time.
- Net effect: dispatcher loop no longer contends with bots mid-claim on the same banks — reduces failed `FindOneAndUpdate` attempts and noisy warn logs.

### FIFO sort within a bank (`#240`)
- Lines 319-328 + 387-396: after assignment, pending items are re-sorted `priority ASC, created_at ASC` before being handed to `FindOneAndUpdate` for the lock-and-assign atomic. Oldest pending item within a given priority wins — no more "random item in the same priority tier got picked first" starvation.

### Per-bank cap tier (still single-value, not per-bank independent)
- Lines 222-237: `perBankCap` picked ONCE from pending-count tier and applied to ALL idle banks in this tick.
  - `pending >= 100`: cap = 5
  - `pending >= 20`: cap = rand[4..5]
  - `pending >= 5`: cap = rand[3..5]
  - `pending < 5`: cap = rand[1..5]
- Inline comment at 210-211 ("Each bank's cap is picked independently…") is stale — filed as DRIFT-12 in `docs/current-system.md` §9.

### Why
- Operator wanted a cheap way to throttle aggressive banks when queue was deep without starving small-tail cases. Single-tier-per-tick is the pragmatic compromise chosen over per-bank independence.

### How to apply
- When diagnosing "why did bank X only get N items this minute" in production: read the pending-count at that tick, not the bank-local count. Cap is a pool-wide parameter.
- Do not claim "per-bank independent" until code actually iterates banks to draw a cap each.

citations: `scheduler/withdrawal_dispatcher.go:188-192,210-211,222-237,319-328,387-396@386f0a71`
baseline: pg-writer-oracle W2 pass from `1ffafc13..386f0a71` (docs/track-386f0a7 branch)

---
*Added via Oracle Learn*
