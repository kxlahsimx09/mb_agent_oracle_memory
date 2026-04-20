---
title: decision — flow:payout-confirm-completed (b) queue row rewrite concern is moot u
tags: [technical-writer, repo:mobiz-payment-gateway, current, decision, flow, payout-confirm-completed, queue-row-rewrite-moot-under-invariant, payout, thread-22-partial-ratification]
created: 2026-04-19
source: controllers/PayoutController.go:2000-2009@0d968fa + services/withdrawalQueue.go:1052-1118@0d968fa + docs/flows/payout-confirm-completed.md + thread #22 partial ratification 2026-04-19
project: github.com/kokarat/mobiz-payment-gateway
---

# decision — flow:payout-confirm-completed (b) queue row rewrite concern is moot u

decision — flow:payout-confirm-completed (b) queue row rewrite concern is moot under the payout state invariant. The original question asked whether Step 7's `$unset failed_at, error_message` on `withdrawal_queue` during `ConfirmPayoutCompleted` rewrites the queue row's history and whether additional fields (e.g. `previously_failed_at`) should preserve it. Under the 2026-04-19 ratified invariant (`failed` = proof-negative-only; uncertainty → `waiting_to_review`), the canonical path through `ConfirmPayoutCompleted` is `waiting_to_review → completed`. On this canonical path the queue row was set by `MarkWaitingToReview` which **never writes `failed_at` or `error_message`** — there is no history to preserve on the queue row, only status progression. The concern only applies to the `failed → completed` defensive-patch branch, which is itself slated for deprecation per learning `2026-04-19_drift-flowpayout-confirm-completed-a-failed`. Human ruling 2026-04-19 (thread #22 partial ratification): moot-under-invariant on the canonical path; the transitional concern fades once the failed-entry branch is removed. No action required on the queue schema; the §Postconditions section correctly describes the canonical-path state.

---
*Added via Oracle Learn*
