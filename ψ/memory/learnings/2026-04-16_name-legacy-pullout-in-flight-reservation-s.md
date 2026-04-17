---
title: legacy pullout in-flight reservation — subtract pendingOut × MaxAmount from source balance
name: legacy pullout in-flight reservation — subtract pendingOut × MaxAmount from source balance
description: As of 4919e45 (2026-04-16, PR #167), the legacy pullout scheduler path reserves task.MaxAmount per pending pullout from the same source bank before checking effective balance. Refill chains already had this via CountPendingPulloutsFromSource.
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - scheduler
  - pullout
  - race-condition
source: scheduler/scheduler.go:208-270 @ 3b7e0f1; services/pulloutDemand.go:66-91 @ 3b7e0f1
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

# Legacy pullout in-flight reservation

## Fact

The non-refill (legacy) branch of `scheduler.Scheduler.executeTask` now calls `services.CountPendingPulloutsFromSource(ctx, systemBank.ID)` and computes:

```
reserved := float64(pendingOut) * task.MaxAmount
effectiveBalance := systemBank.Balance - reserved
```

The scheduler then clamps the random amount against `effectiveBalance` instead of `systemBank.Balance`. If `effectiveBalance < task.MinAmount` the task is skipped via `advanceNextRunSkipped` with a reason that includes both `pendingOut` and `reserved`.

## Why

On 2026-04-16 two tasks with the same source (SCB 5014674469, ~50k balance) fired in the same tick: PLO17762684029ZB8AX (42,181) and PLO1776279782VCRL6U (35,341). Each read the same stale `systemBank.Balance` and assumed the whole amount was theirs — combined 77k overshot the real balance.

The refill-chain path (`services.EvaluatePulloutRefill`) already blocked when `pendingOut > 0` (see `pulloutDemand.go` rule 1 "zero pending from source"). The legacy path adopts a looser semantic — over-reserves by assuming every pending is at `MaxAmount` (conservative upper bound). The worst case is one extra skipped tick; cheaper than queuing an unfundable item.

## How to apply

- When reading `system_banks.balance` from a scheduler path, ask: "is there a pending queue item that will spend this balance before my item dispatches?" If yes, subtract. This is the pattern — `CountPendingPulloutsFromSource` is the helper.
- Refill chain keeps the stricter semantic (block on any pending). Don't relax that — refill amount is tighter and over-sending is a bigger issue there.
- The upper-bound reservation is conservative by design. Do not "optimise" it by querying each pending's exact amount without weighing the extra DB round-trip against the cost of a missed tick.

## Trace

commit `3b7e0f1` (specifically `4919e45` #167) → docs/current-system.md §5 PullOutScheduler row → resolution PR #173
