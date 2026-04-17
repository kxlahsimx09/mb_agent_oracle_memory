---
title: Payout matcher at ed45b7e — request_id is the only auto-reconcile gate
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - payout
  - matcher
  - auto-reconcile
  - withdrawal-queue
related:
  - 2026-04-16_name-payout-auto-reconcile-three-convergent
  - 2026-04-17_fact-markfailed-callback-race-still-at-head-ed45b7e
source: services/transactionMatcher.go@ed45b7e, services/withdrawalQueue.go@ed45b7e
created: 2026-04-17
project: github.com/kokarat/mobiz-payment-gateway
---

# Payout matcher at ed45b7e — request_id is the only auto-reconcile gate

## Pattern at HEAD

`services/transactionMatcher.go` payout-match priority (lines 854–933):

1. **P1 — request_id** via regex on description `(PAY|PLO|PO|STL|DTR)\w{10,}|…\d{14,}` (line 855). If the extracted ID maps to a queue item, calls `finalizePayout(…, byReqID=true)`.
2. **P2 — full destination account** match. Multi-candidate: **skip** (line 900), do not FIFO-pick.
3. **P3 — last4 of destination** via bank-code-qualified regex `stmt.DestAccountLast4 + "$"` (line 919). Multi-candidate: **skip** (line 930). The `#195` fix replaced `$expr`/`$substr` with `regex` on this path.

Auto-reconcile gate in `finalizePayout` (lines 996–1027): when `item.Status == "failed"` AND `item.SourceType == "payout"`, reconcile fires **only** if `byReqID == true`. P2/P3 matches on a failed payout leave the payout `failed` and surface for admin review.

Post-MarkFailed path (`services/withdrawalQueue.go:1000–1047`) uses the same guard shape: requires (a) matched statement with `matched_queue_id`, `match_status=matched`, AND `matched_request_id=item.RequestID`; (b) description contains the literal RequestID string. Both must pass.

## Why

Dev incident `PAY1776286617S2B53L` (2026-04-16) demonstrated that an amount-and-account-only match can link a statement to the wrong queue item when two payouts of the same amount to the same destination sit in the queue. Request_id in the bank description is the only disambiguator that guarantees the matched statement is "for this payout". `#200` removed FIFO disambiguation (oldest-wins) because it was making non-deterministic picks under concurrent arrivals.

## How to apply

- When reading payout-auto-reconcile incidents, check whether the match was P1 (request_id, auto-reconcile armed) or P2/P3 (skipped auto-reconcile).
- When documenting matcher behaviour, do **not** describe FIFO linking as the tiebreaker — it's removed at HEAD.
- The three auto-reconcile paths (matcher finalize, post-MarkFailed goroutine, admin `confirm-completed`) still converge on `services.ReconcileFailedPayoutToCompleted` with idempotency via `ErrPayoutAlreadyReconciled`. That invariant is unchanged by this delta.

## Related open issue

Double-callback race between `processPostCompletion("failed")` and `tryReconcileAfterMarkFailed`: see `2026-04-17_fact-markfailed-callback-race-still-at-head-ed45b7e.md` + §9 DRIFT-11 in `docs/current-system.md`.
