---
title: pullout refill amount is randomized in [MinAmount, upper] — no more identical repeat statements
name: pullout refill amount is randomized in [MinAmount, upper] — no more identical repeat statements
description: As of 0a30548 (2026-04-16, PR #163), pulloutDemand.EvaluatePulloutRefill picks a random integer baht in [task.MinAmount, min(need, source.Balance, task.MaxAmount)] instead of pinning to the exact upper bound. Prevents repeat-amount statements that look like a fraud pattern.
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - pullout
  - scheduler
  - operations
source: services/pulloutDemand.go:181-229 @ 3b7e0f1
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

# Pullout refill amount is randomised

## Fact

`services.EvaluatePulloutRefill` no longer pins the refill amount to the computed upper bound. Instead:

```
upper := min(need, source.Balance, task.MaxAmount)  // where need = cap - dest.Balance
if upper < task.MinAmount: SkipReason
decision.Amount = randomRefillAmount(task.MinAmount, upper)
```

`randomRefillAmount(min, max)` returns a random whole-baht amount in `[min, max]` using the shared `math/rand` source (no fresh seeding). `int64(min)` and `int64(max)` floor the inputs; if `hi <= lo` it returns `min`.

## Why

The demand-based refill was pinning the amount to exactly `cap - dest.Balance` (clamped). In production every time the destination ran itself down to the same level, the next refill landed on the exact same rounded figure — four consecutive refills from KTB 0170681475 to 4232204440 came out as 7,600.00 each. On the statement that pattern looks like fraud.

## How to apply

- Do not revert this to "exact upper". Keeping the floor+random path is the contract even without test coverage (there is none for `EvaluatePulloutRefill` yet, tracked as a follow-up).
- When adding a new demand-based payout/refill path, use the same pattern: compute an operator-bounded upper, floor to whole baht, random within `[min, upper]`.
- `upper < min` must skip via `SkipReason`; never silently clamp to `min` when the ceiling is lower.
- The `math/rand` shared source is seeded elsewhere by the scheduler; don't re-seed inside this code path.

## Trace

commit `3b7e0f1` (specifically `0a30548` #163) → docs/current-system.md §6.4 → resolution PR #173
