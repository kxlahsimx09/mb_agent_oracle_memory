---
title: ## PR #179 + #180 ON_HOLD: MarkFailed double-callback race condition
tags: [tester, repo:mobiz-payment-gateway, current, payout, callback, race-condition, on-hold, decision]
created: 2026-04-17
source: conversation with user 2026-04-17 + dev confirmation
project: github.com/kokarat/mobiz-payment-gateway
---

# ## PR #179 + #180 ON_HOLD: MarkFailed double-callback race condition

## PR #179 + #180 ON_HOLD: MarkFailed double-callback race condition

Both payout test PRs (PR #179 confirm-completed, PR #180 auto-reconcile) are ON_HOLD pending a callback behavior redesign.

### The problem

`services.MarkFailed` (services/withdrawalQueue.go:958,971) spawns two goroutines concurrently:
- `processPostCompletion(item, "failed")` → sends `EventPayoutFailed` callback, then refunds wallet
- `tryReconcileAfterMarkFailed(item)` → if matched statement exists, calls `ReconcileFailedPayoutToCompleted` which sends `EventPayoutCompleted` callback

The two goroutines race. If the auto-reconcile goroutine's `EventPayoutCompleted` callback arrives at the client BEFORE `processPostCompletion`'s `EventPayoutFailed`, the client sees: completed → failed. The client's last-received status is wrong.

### Decision

Dev confirmed 2026-04-17 that the callback behavior will be redesigned. Until the code is updated, both PRs should not merge and their test-index.md rows are marked ON_HOLD.

### What needs to happen after code update

1. Check what the new callback behavior is (single callback? sequenced? suppressed on auto-reconcile?)
2. Rework test assertions if the wallet trajectory or audit-log expectations changed
3. Re-run both tests
4. Upgrade test-index.md rows from ON_HOLD → VALID
5. Update PR descriptions + remove ON_HOLD comments

---
*Added via Oracle Learn*
