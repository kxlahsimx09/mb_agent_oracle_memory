---
title: resolution — scheduler-intervals drift closed (DRIFT-1)
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - scheduler
  - withdrawal-queue
  - resolution
source: CLAUDE.md:844-846 + main.go:124 + scheduler/transaction_matcher.go:36,47 @ a4d806f
supersedes:
  - 2026-04-15_drift-scheduler-intervals
related:
  - 2026-04-15_drift-scheduler-intervals
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

# Resolution — DRIFT-1 scheduler intervals

## Drift class (original)

WithdrawalDispatcher actual interval is 30 s (not 1 m as CLAUDE.md claimed). Payout matcher actual interval is 1 m (not 2 m as the inline `main.go:165` comment claims).

## Resolution path (taken)

(A) fix-doc.

## What changed

- Doc: CLAUDE.md §"Withdrawal Queue" → "Dispatcher (Go Ticker)" bullet rewritten from "Runs every 1 minute via `scheduler/withdrawal_dispatcher.go`" to "Runs every 30 seconds via `scheduler/withdrawal_dispatcher.go` (ticker interval set at `main.go:124`)".
- Code: unchanged.

## Residual

The stale `// 2m` comment in `main.go:165` (startup-log comment claiming payout matcher runs every 2 minutes) is **out-of-territory** for the writer — it is a code-comment defect owned by the backend team. The drift's `How to apply` note about filing a follow-up for that comment is preserved in the original learning (P-001). The runtime truth is printed by `scheduler/transaction_matcher.go:47` at startup: "Deposit: 30s, Payout: 1m".

## How I verified

Read `main.go:115-175` — `NewWithdrawalDispatcher(30 * time.Second)` at line 124. Read `scheduler/transaction_matcher.go:25-48` — payout ticker built with `1*time.Minute` at line 36, startup log at line 47. Re-read CLAUDE.md §"Withdrawal Queue" → "Dispatcher (Go Ticker)" at lines 844-846 post-edit.
