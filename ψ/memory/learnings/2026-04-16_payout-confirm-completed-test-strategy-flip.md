---
title: Payout confirm-completed test reverted from real-bot to short-circuit (wrong-setup)
type: learning
tags:
  - tester
  - repo:mobiz-payment-gateway
  - current
  - payout
  - withdrawal-queue
  - wrong-setup
  - discovered-while-testing
related:
  - 2026-04-14_principle-code-is-truth-docs-are-claims
source: |
  services/withdrawalQueue.go:893-979 (services.MarkFailed)
  services/withdrawalQueue.go:1208-1270 (processPostCompletion for SourceTypePayout)
  controllers/PayoutController.go:1552-1847 (ConfirmPayoutCompleted)
  routes/bot.go:32 + routes/withdrawalqueue.go:25 (both → withdrawalQueueCtrl.MarkFailed)
  integration-tests/test-payout-confirm-completed.sh
  Commit ec09d2e on feat/tester-test-payout-confirm-completed
  PR #179 (https://github.com/kokarat/mobiz-payment-gateway/pull/179)
created: 2026-04-16
project: github.com/kokarat/mobiz-payment-gateway
---

# Payout confirm-completed test — wrong-setup in earlier rev

## What was claimed

The test at `integration-tests/test-payout-confirm-completed.sh` (PR #179) was
reworked in commit `f6f6716` from a short-circuit `MarkFailed` API call to a
"real bot + mock-bank hide-approver" flow. The header comment justified this:

> Earlier versions of this test short-circuited by calling the admin
> withdrawal-queue MarkFailed API directly. That was wrong — MarkFailed
> requires status=processing (which the bot sets during claim), and it
> skips the real wallet-refund side-effect path. This version uses
> the LIVE bank-bot + mock-bank...

## What the code actually does

`services.MarkFailed` (`services/withdrawalQueue.go:893`) does both halves of
the work:

1. **Atomic transaction**: WQ → `failed` (guarded on `status: processing`),
   source row → `failed` (via `getSourceStatusUpdate` at L1167; payout sets
   `status:"failed"` + `failed_at`).
2. **Post-commit goroutine** at L958: `processPostCompletion(item, "failed")`.
   For `SourceTypePayout` + non-success (L1213-1270):
   - Refunds `payout.Amount + payout.PayoutFee` back to client wallet.
   - Inserts `wallets_change_logs` with `Operation: "payout_refund"`.
   - Sends `EventPayoutFailed` callback.

So the wallet refund **is** the MarkFailed path. The earlier rev's claim
that MarkFailed "skips the real wallet-refund side-effect path" was wrong.

Both endpoints route to the same controller → same service:
- `POST/PUT /api/v1/bot/queue/:id/failed` (`routes/bot.go:32`) →
  `withdrawalQueueCtrl.MarkFailed` → `services.MarkFailed`
- `PUT /api/v1/withdrawal-queue/:id/failed` (`routes/withdrawalqueue.go:25`) →
  `withdrawalQueueCtrl.MarkFailed` → `services.MarkFailed`

## Why the rework went wrong

`f6f6716` was right that "short-circuit needs status=processing first" — that
constraint is real (atomic update guard at L914 requires
`status: models.QueueStatusProcessing`). But the conclusion drawn — that you
need a real bot to drive the failure — was over-strong. The status-processing
requirement can be satisfied by either:

1. Calling the `/bot/queue/claim` endpoint with X-Bot-Secret (atomic
   pending → processing).
2. Mongo-direct update on the WQ row (status + system_bank_id) — what the
   reverted test does, since the dispatcher race is hard to schedule from
   bash.

Once status=processing is set, `MarkFailed` produces the exact same
side-effects whether the call comes from the Playwright bot or from a
direct API call.

## Why the conclusion was attractive but wrong

The bot path is the production path. "Use the real thing" is a sound
default for integration tests in general. The trap here was that the
endpoint under test (`PUT /api/v1/payouts/:id/confirm-completed`) has no
dependency on **how** the payout reached the `failed` state — only that
it's currently `failed` and `confirm_completed_reason` is empty (guards
at PayoutController.go:1605 and :1616). Time spent driving the bot was
not buying coverage of code under test; it was buying ~6 minutes of
test runtime per CI run.

## Generalisable rule

For tests of admin-repair endpoints (anything that operates on an
already-bad state — confirm-completed, override-status, manual-resolve
flows): drive the source state via the cheapest path that produces an
indistinguishable downstream commit. The path that originally produced
the bad state is irrelevant unless the endpoint under test inspects it
(e.g. inspects `failed_at` source, error_message text, etc.). Cross-check
with `grep` on the controller body before assuming you need to recreate
the natural failure mode.

## Diff

Branch: `feat/tester-test-payout-confirm-completed`
- Reverted commit: `f6f6716`
- New commit: `ec09d2e`
- Net: -185 / +127 lines
- Runtime: ~7 min → ~30-60 s
