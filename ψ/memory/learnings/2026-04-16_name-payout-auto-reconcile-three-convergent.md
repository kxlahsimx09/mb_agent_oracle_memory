---
title: payout auto-reconcile — three convergent paths on one helper
name: payout auto-reconcile — three convergent paths on one helper
description: Failed payouts that actually transferred now flip back to completed via services.ReconcileFailedPayoutToCompleted. Three callers converge on the helper (matcher, post-MarkFailed goroutine, admin endpoint); idempotency handled by ErrPayoutAlreadyReconciled.
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - payout
  - reconciliation
  - callback
  - matcher
source: services/payoutReconciliation.go:56-291 @ 3b7e0f1
project: github.com/kokarat/mobiz-payment-gateway
related:
  - 2026-04-15_drift-payout-bson-camelcase.md
created: 2026-04-16
---

# Payout auto-reconcile — three convergent paths on one helper

## Fact

As of 2026-04-16 HEAD `3b7e0f1`, a failed `ts_payouts` row that the bank did in fact transfer is reconciled back to `completed` via `services.ReconcileFailedPayoutToCompleted(ctx, payoutID, opts)` (`services/payoutReconciliation.go:56`). Three distinct callers exist:

1. `services.transactionMatcher.finalizePayout` (`services/transactionMatcher.go:1017-1052@3b7e0f1`) — runs when a bank statement is matched to a withdrawal_queue item whose status is `failed`. Introduced in PR #161 (`4828a6a`).
2. `services.withdrawalQueue.tryReconcileAfterMarkFailed` (`services/withdrawalQueue.go:982-1030@3b7e0f1`) — goroutine spawned after `MarkFailed` commits for a payout source; covers the race where the matcher ran while the item was still `processing`. Introduced in PR #172 (`c1ee2da`).
3. `controllers.PayoutController.ConfirmPayoutCompleted` (`controllers/PayoutController.go:1525-1825@3b7e0f1`) — admin endpoint `PUT /api/v1/payouts/:id/confirm-completed` behind `PermApprove("payout")`. Introduced in PR #160 (`4720f20`).

## Behaviour (single MongoDB session transaction, ordered)

- `ts_payouts`: `{_id, status:"failed"}` filter → `status:"completed"`; unset `failed_at`; set `completed_at`, `completed_date_bkk`, `confirmed_completed_at`, `confirmed_completed_by`, `confirmed_completed_by_username`, `confirm_completed_reason` (used as double-confirm guard), optional `bank_transaction_id`.
- `wallets`: `$inc balance/available -= (amount + payout_fee)` with `balance >= totalDeduct` guard in the filter.
- `wallets_change_logs`: `payout_confirm_completed` entry on the client wallet.
- Inline MDR fan-out: for each partner in the MDR profile with `PayoutPercentage > 0` AND `partner.Status == 1` → `$inc` partner wallet by `CalculateFee(amount, percentage)`, insert `mdr_distribution` log.
- `mdr_shared`: single row summarising distributions (only if non-empty).
- `withdrawal_queue`: `{source_type:"payout", source_id:payoutID}` → `status:"success"`, clear `failed_at` + `error_message`.

## Idempotency

Sentinel errors:

- `ErrPayoutNotFound` — hard error.
- `ErrPayoutNotFailed` — concurrent flip or already-completed payout; treat as no-op.
- `ErrPayoutAlreadyReconciled` — `confirm_completed_reason` already set; treat as no-op.

MDR fan-out is **inlined** in the session because the existing `services.distributeMDRFees` helper uses its own context and cannot participate. This creates two code paths producing structurally identical `mdr_shared` + `mdr_distributions` records; a test pinning the parity does not exist and is a future-regression risk.

Callback + SSE side-effects live in the callers (not in the helper). Matcher and post-MarkFailed paths fire `SendPayoutCallback(EventPayoutCompleted)` in a goroutine and `PublishSSE("payouts", "auto_reconciled", …)`. The admin endpoint fires `SendPayoutCallback` and publishes `PublishEvent("payouts", "confirmed_completed", …)`.

## Why

The specific incidents this closes are PAY17762677921B3TNC (2026-04-11) and the 22 money-gone cases observed on 2026-04-15. Root cause: matcher set `bank_statements.matched_queue_id` + `matched_request_id` when it linked a debit to a failed payout but never touched the payout or queue status, so the client wallet stayed refunded and the merchant saw a `failed` callback while our wallet showed `completed`. Merchants then refunded their end-user on their side while we had effectively paid them — double-refund setup.

## How to apply

- When writing any new caller that cancels or refunds a payout, treat the combination of a matched `bank_statements` row and a `failed` queue item as an auto-reconcile signal, not as a "cancelled" signal.
- Do not call `distributeMDRFees` inside a session — it opens its own context.
- The `confirm_completed_reason` raw-BSON read is the canonical "this payout was auto-reconciled" signal. Tools that deduplicate or audit payouts should check this field, not the status alone.
- The double-confirm guard is raw-BSON because `confirm_completed_reason` may not be in every build of the strongly-typed `models.Payout` struct; keep it that way when adding new guards.

## Trace

commit `3b7e0f1` (range `379e984..3b7e0f1`, specifically `4828a6a` #161, `c1ee2da` #172, `4720f20` #160) → docs/current-system.md §3.2.1 + §6.5 → resolution PR #173
