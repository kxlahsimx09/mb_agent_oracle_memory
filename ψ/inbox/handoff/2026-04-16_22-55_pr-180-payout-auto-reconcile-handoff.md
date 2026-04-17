---
title: PR #180 test-payout-auto-reconcile.sh — VALID after short-circuit + 2 follow-up fixes
type: handoff
tags:
  - tester
  - repo:mobiz-payment-gateway
  - current
  - payout
  - withdrawal-queue
  - handoff
related:
  - 2026-04-16_payout-confirm-completed-test-strategy-flip
created: 2026-04-16
---

# Per-test handoff (workflow-2 step 10)

**Test:** `integration-tests/test-payout-auto-reconcile.sh`
**PR:** https://github.com/kokarat/mobiz-payment-gateway/pull/180
**Branch:** `feat/tester-test-payout-auto-reconcile`
**Final commit:** `83c1ef2` (test on `b792a03`, docs at `83c1ef2`)
**Status:** VALID — manual runtime pass on 2026-04-16

## What this test covers

`services.tryReconcileAfterMarkFailed` (post-MarkFailed goroutine in
`services/withdrawalQueue.go:987`) — when a `bank_statement` is already
matched to the WQ item before MarkFailed fires, the goroutine auto-flips
the payout from failed back to completed via
`ReconcileFailedPayoutToCompleted`. Asserts both side-effect goroutines
(`processPostCompletion` refund + `tryReconcileAfterMarkFailed` auto-flip)
fired and converged to the same final state.

## Strategy

Short-circuit (no real bot): plant matched `bank_statement` →
mongo-direct WQ pending → processing → `PUT /api/v1/bot/queue/:id/failed`
via `X-Bot-Secret`. Same code path as natural bot-fail. See vault learning
`2026-04-16_payout-confirm-completed-test-strategy-flip.md` for the
generalisable rationale.

## Two non-obvious fixes the first runtime surfaced

1. **Refund goroutine race** (`18ba567`): `processPostCompletion` calls
   `SendPayoutCallback` (HTTP POST) BEFORE the wallet write. Against
   the test's `https://example.com/callback` the call is slow → wallet
   refund + audit row land seconds after the auto-flip. The original
   composite signal only watched the auto-flip → Step 10 raced ahead
   and saw a one-deduction wallet. Fix: wait for `payout_refund` row
   (the LAST write the refund goroutine performs).

2. **Bash quote-handling breaks `NumberLong("$(date)")`** (`b792a03`):
   the entire `--eval` body is inside bash double-quotes, so any inner
   `"` terminates the bash string. `$(date)` then expanded UNQUOTED
   and mongosh received `NumberLong(<bare_int>)` (deprecated number
   form) which emits a warning on STDOUT (not stderr). After
   `tr -d '[:space:]'` the warning text concatenated with the ObjectId
   print and broke the `bank_transaction_id` assertion. Fix: pre-compute
   date in bash variables, use JS single-quotes (`NumberLong('${VAR}')`),
   plus defensive `${VAR: -24}` ObjectId extraction as a backstop.

## Generalisable rules from this fix pair

- For any goroutine spawned from MarkFailed (or similar fan-out), the
  test's "wait" signal must include the LAST write each goroutine
  performs, not just the first observable side-effect. Otherwise the
  fastest goroutine's signal lets assertions race the slower ones.
- For mongosh `--eval` JS strings inside bash `"…"`, JS strings must
  use single-quotes (`'…'`), not double-quotes (`"…"`). Double-quotes
  break the bash string and pass bare/unquoted shell values into JS.
- Whenever capturing a single ObjectId from mongosh stdout, always
  apply `${VAR: -24}` as a belt-and-suspenders extractor against any
  future stdout noise (warnings, prefixes, etc.).

## Next unanswered questions

1. **CI run** — manual pass; first CI run will confirm host-independence.
2. **PR #183 (expiry-scheduler)** — last sibling PR. Worth checking
   whether it shares the same `MarkFailed skips wallet refund`
   misconception. If so, same short-circuit pattern applies. Also check
   whether it has the same goroutine-race or NumberLong-quoting traps.

## Open items NOT in this PR

- mock-bank `/admin/hide-approver` is now dead code in PR #179 + PR #180
  but kept per P-001. If PR #183 also moves to short-circuit, the endpoint
  becomes a candidate for cleanup in a separate PR.
- Both PR #179 and PR #180 touch `docs/test-coverage-gaps.md` and
  `docs/test-index.md` summary lines. Second-to-merge will rebase.
