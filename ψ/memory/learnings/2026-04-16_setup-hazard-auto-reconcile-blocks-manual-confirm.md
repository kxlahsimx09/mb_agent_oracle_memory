---
title: Setup hazard — auto-reconcile fires after WQ MarkFailed and can silently flip payout to completed before admin ever calls confirm-completed
type: learning
tags:
  - tester
  - repo:mobiz-payment-gateway
  - current
  - payout
  - withdrawal-queue
  - discovered-while-testing
  - setup-hazard
related:
  - 2026-04-16_decision-2026-04-16-gmt7-introduced-the-tes
source: >
  services/withdrawalQueue.go:971 (triggers tryReconcileAfterMarkFailed as a goroutine
  after MarkFailed commits) + services/withdrawalQueue.go:987 (the reconcile function
  that looks up a matching bank_statement and calls
  services.ReconcileFailedPayoutToCompleted). Observed while designing
  integration-tests/test-payout-confirm-completed.sh under workflow-2.
created: 2026-04-16
project: github.com/kokarat/mobiz-payment-gateway
---

# Setup hazard — auto-reconcile fires after WQ MarkFailed and can silently flip payout to completed before admin ever calls confirm-completed

## The gotcha

When `services.MarkFailed` commits the WQ transition to `failed`, it
fires `go tryReconcileAfterMarkFailed(item)` as a post-commit goroutine.
That goroutine looks for a `bank_statements` row whose account / amount /
direction matches the failed payout's destination. If it finds one, it
calls `ReconcileFailedPayoutToCompleted` — which runs the same logic the
admin's `PUT /payouts/:id/confirm-completed` handler runs: flip status
back to completed, deduct wallet, distribute MDR, fire callback as
`EventPayoutCompleted`, mark WQ back to success.

This is by design — it is the automated self-heal for false-negative
failures. But it is a test-setup hazard: a test that wants to exercise
the *manual* admin confirm path needs the payout to **stay** in failed
state long enough for the test to call the admin endpoint. If the test
setup inadvertently lands a matching statement before MarkFailed commits,
auto-reconcile wins the race and the test's confirm-completed call
returns 400 "Can only confirm failed payouts as completed" — looking
exactly like a handler bug when it is actually a test setup leak.

## How to design around it

For **manual-confirm** tests (like test-payout-confirm-completed.sh):

- Do **not** insert into `bank_statements` before calling MarkFailed.
- Do **not** call `${MOCK_BANK_URL}/admin/simulate-payout` before the
  test reaches the admin confirm step. That helper path can cause a
  statement to land via the mock-bank → backend sync.
- Poll `ts_payouts.status == "failed"` **and** wait a beat after the
  poll succeeds to make sure auto-reconcile has actually given up
  (not found a match, exited quietly). The test currently polls the
  wallet-refund side-effect, which is enough since refund lives on the
  non-reconcile path too — but if refund timing ever changes, the poll
  must be on a reconcile-specific negative signal.

For **auto-reconcile** tests (the upcoming
test-payout-auto-reconcile.sh):

- **Do** insert a matching bank_statement before MarkFailed — same
  account, same amount, direction=out, recent enough that
  `matchBankStatementToFailedPayout` accepts it.
- Assert the payout flips to completed *without* any admin call.
- The effects should be identical to the manual confirm path (same
  service function underneath) — tag the change log entries the same
  way (`operation=payout_confirm_completed`) but with
  `changed_by="system:auto-reconcile"` instead of the admin username.

## Why this is non-obvious

Two things obscure the race:

1. The goroutine is fired after the main transaction commits, with no
   acknowledgement back to the caller. A test that short-circuits to
   "check payout status" right after `MarkFailed` returns can miss the
   window where auto-reconcile has decided to fire but has not yet
   committed.

2. The reconcile service's "double-confirm guard" (check of
   `confirm_completed_reason`) prevents a manual call from *also*
   running if auto-reconcile wins — which makes the test fail with a
   reason-already-set error, not a "can only confirm failed" error,
   which is a confusingly indirect symptom.

## Applies to

- Writing any new integration test that touches the failed-payout path
  (`workflow-2`).
- Reviewing existing payout tests (`workflow-1 validate`) to see if any
  of them race against this goroutine in their assertions.
- The upcoming Test B (`test-payout-auto-reconcile.sh`) must deliberately
  land a matching statement first — this learning is the setup recipe.

## Source lines

- `services/withdrawalQueue.go:971` — goroutine fire site
  (`go tryReconcileAfterMarkFailed(item)`).
- `services/withdrawalQueue.go:987` — `tryReconcileAfterMarkFailed`
  function. Reads `bank_statements`, then delegates to
  `ReconcileFailedPayoutToCompleted`.
- `services/payoutReconciliation.go:56` — the shared reconcile
  function. Used by *both* the auto path (here) and the admin HTTP
  path (`ConfirmPayoutCompleted` in `controllers/PayoutController.go`).
