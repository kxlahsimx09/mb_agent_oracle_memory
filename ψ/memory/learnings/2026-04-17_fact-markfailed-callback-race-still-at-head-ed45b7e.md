---
title: Fact — MarkFailed double-callback race is still present at HEAD ed45b7e
tags:
  - technical-writer
  - tester
  - repo:mobiz-payment-gateway
  - current
  - payout
  - callback
  - race-condition
  - on-hold
  - handoff
related:
  - 2026-04-17_pr-179-180-onhold-markfailed-double-callb
  - 2026-04-17_auto-reconcile-production-scenario-why-bankst
  - 2026-04-17_correction-auto-reconcile-otp-must-have-succ
source: services/withdrawalQueue.go@ed45b7e (lines 971, 984, 1000–1047, 1227–1287)
created: 2026-04-17
project: github.com/kokarat/mobiz-payment-gateway
---

# Fact — MarkFailed double-callback race is still present at HEAD ed45b7e

## Why this check was run

User (2026-04-17) asked the `pg-writer-oracle` instance whether any commit
between baseline `3b7e0f1` and HEAD `ed45b7e` had delivered the "callback
behaviour redesign" the dev promised when PR #179 (confirm-completed) and
PR #180 (auto-reconcile) were put ON_HOLD earlier today. Tests for both
scenarios remain ON_HOLD in `docs/test-index.md`, with the decision captured
in `ψ/memory/learnings/2026-04-17_pr-179-180-onhold-markfailed-double-callb.md`.

## What was verified at HEAD

Read `services/withdrawalQueue.go` at `ed45b7e`. The two callback paths flagged
in the ON_HOLD learning are both still present:

1. **`MarkFailed` → `processPostCompletion(item, "failed")`** (line 971). The
   function runs a goroutine (line 1230) that fetches the payout and sends
   `callbackService.SendPayoutCallback(&payout, EventPayoutFailed)` (line 1243),
   then refunds the wallet.

2. **`MarkFailed` → `go tryReconcileAfterMarkFailed(item)`** (line 984). If a
   `bank_statement` is already matched to this queue item and the request_id
   gate passes (lines 1006–1018), the goroutine calls
   `ReconcileFailedPayoutToCompleted` (line 1021) and then
   `callbackService.SendPayoutCallback(updated, EventPayoutCompleted)` (line 1036).

Both code paths fire in parallel after the MarkFailed transaction commits. If
path 2 completes before path 1 reaches the merchant, the last-received callback
is `EventPayoutCompleted` after an `EventPayoutFailed` — which is the correct
final state — but if the network ordering flips, the last-received callback is
`EventPayoutFailed` after `EventPayoutCompleted`, i.e. the client sees
completed → failed. The race is structural, not a transient timing bug.

## What dev HAS changed in this range (and why it is not a fix)

The matcher/reconcile area is the single most-edited surface between
`3b7e0f1..ed45b7e` (8 commits touching `services/transactionMatcher.go` or
`services/withdrawalQueue.go` + `services/payoutReconciliation.go`):

| Commit | PR | Summary |
|---|---|---|
| `80cea24` | #188 | Payout matcher: add PAY prefix, **disable** auto-reconcile branch, retry unmatched |
| `052c382` | #189 | **Re-enable** tryReconcileAfterMarkFailed but only when `matched_request_id == item.RequestID` AND description contains request_id |
| `661edf3` | #195 | Matcher last4 filter: regex instead of $expr/$substr |
| `6c65757` | #196 | Matcher uses deposit record for user bank info |
| `c0a5bd3` | #193 | `withdrawal_queue.batch_id` added on claim |
| `a29a7bc` | #194 | Copy `batch_id` to source documents on claim |
| `7add321` | #197 | Prepend `request_id` to wallet change-log notes for payout ops |
| `097c707` | #200 | Remove FIFO linking — skip when multiple candidates match |

None of these touch the callback sequence. The #189 re-enable narrows *when*
`tryReconcileAfterMarkFailed` fires (request_id gating reduces the probability
of a false-positive auto-flip) but keeps the structural two-callback dispatch.
If both goroutines still fire — which is exactly the ON_HOLD scenario — the
race still occurs.

## Verdict for the tester

No action on the ON_HOLD rows. `docs/test-index.md` should stay at
`ON_HOLD — callback race redesign pending` for both
`test-payout-confirm-completed.sh` and `test-payout-auto-reconcile.sh`.

When dev ships the callback-behaviour redesign (single emission? sequenced?
suppressed on auto-reconcile?), the resulting code change will likely land in
`services/withdrawalQueue.go` around lines 971–984 and 1033–1038; re-run this
verification against that commit and then follow the "After code update"
checklist in the original ON_HOLD learning.

## Handoff

Routed to `pg-tester-oracle` via shared vault (tag `#tester #handoff`). Also
relevant to `code_reviewer` and `requirement-writer` when the redesign lands —
the design choice (which of the three options above to pick) is a
`requirement-writer` call, not a technical-writer one.
