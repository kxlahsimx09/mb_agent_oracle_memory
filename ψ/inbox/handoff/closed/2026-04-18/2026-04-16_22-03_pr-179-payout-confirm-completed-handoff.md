---
title: PR #179 test-payout-confirm-completed.sh — VALID after short-circuit rework
type: handoff
tags:
  - tester
  - repo:mobiz-payment-gateway
  - current
  - payout
  - handoff
related:
  - 2026-04-16_payout-confirm-completed-test-strategy-flip
created: 2026-04-16
---

# Per-test handoff (workflow-2 step 10)

**Test:** `integration-tests/test-payout-confirm-completed.sh`
**PR:** https://github.com/kokarat/mobiz-payment-gateway/pull/179
**Branch:** `feat/tester-test-payout-confirm-completed`
**Final commit:** `acdb769` (test on `ec09d2e`, docs at `acdb769`)
**Status:** VALID — manual runtime pass on 2026-04-16

## What this test covers

`PUT /api/v1/payouts/:id/confirm-completed` — admin repair endpoint that flips
a `failed` payout back to `completed`, deducts the client wallet (amount + fee),
distributes MDR to partners, and flips the WQ row from `failed` → `success`.
Asserts six effects + double-confirm guard.

## Strategy

Short-circuit (no real bot): mongo-direct WQ pending → processing, then
`PUT /api/v1/bot/queue/:id/failed` via `X-Bot-Secret` to drive
`services.MarkFailed`. Same code path as the natural bot-fail flow because
both endpoints route to the same controller method. See vault learning
`2026-04-16_payout-confirm-completed-test-strategy-flip.md` for the full
rationale on why the earlier real-bot rev was reverted.

## Next unanswered questions

1. **CI run** — manual run passed; first CI run will confirm host-independence.
2. **PR #180 (auto-reconcile) and PR #183 (expiry-scheduler)** — sibling PRs
   in the same checkout. Worth re-checking whether they share the same
   "MarkFailed skips wallet refund" misconception in their setup. If so, same
   short-circuit pattern applies.

## Open items NOT in this PR

- PR #179 description on GitHub still describes the earlier real-bot strategy.
  Owner may want to refresh it before merging so PR-list readers aren't
  surprised by the diff.
- mock-bank `/admin/hide-approver` endpoint is now dead code in this test's
  flow but kept per P-001. If PR #180/#183 also drop the real-bot pattern,
  the endpoint becomes a candidate for removal in a separate cleanup PR.
