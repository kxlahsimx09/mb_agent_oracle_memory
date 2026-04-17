---
name: drift — scheduler intervals diverge from CLAUDE.md
description: WithdrawalDispatcher runs every 30s (not 1m) and Payout matcher runs every 1m (not 2m as the inline comment claims)
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - scheduler
  - withdrawal-queue
  - drift
source: main.go:124 + scheduler/transaction_matcher.go:36 @ 379e984
project: github.com/kokarat/mobiz-payment-gateway
related:
  - 2026-04-15_drift-payout-bson-camelcase.md
created: 2026-04-15
---

# DRIFT — Scheduler interval mismatch

## Fact

`main.go:124` starts `scheduler.NewWithdrawalDispatcher(30 * time.Second)`. CLAUDE.md §"Withdrawal Queue" states "Runs every 1 minute via `scheduler/withdrawal_dispatcher.go`". Code wins (P-004): actual interval is **30 s**.

`main.go:165` says `// Start transaction matchers (deposit: 30s, payout: 2m)` but `scheduler/transaction_matcher.go:36` starts the payout matcher with `1*time.Minute`. The inline comment is stale.

## Why it matters

- Capacity planning reads interval docs. 30 s vs 60 s is a 2× difference for dispatch latency under load.
- The reconciliation matcher cadence determines the worst-case window before an unmatched bank row is re-considered.

## How to apply

- In any doc mentioning dispatcher cadence, cite `main.go:124` with `30s`.
- In any doc mentioning payout matcher cadence, cite `scheduler/transaction_matcher.go:36` with `1m`.
- File a follow-up to fix the stale `// 2m` comment in `main.go:165` — that's a code-comment bug, not a doc fix.

## Trace

commit `379e984` → docs/current-system.md §5 + §9 DRIFT-1 → resolution PR (this PR)
