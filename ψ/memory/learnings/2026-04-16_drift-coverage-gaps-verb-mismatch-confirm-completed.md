---
title: Drift — docs/test-coverage-gaps.md says POST /payouts/:id/confirm-completed but route is PUT
type: learning
tags:
  - tester
  - repo:mobiz-payment-gateway
  - current
  - payout
  - drift
  - coverage-gap
related:
  - 2026-04-16_decision-2026-04-16-gmt7-introduced-the-tes
source: >
  docs/test-coverage-gaps.md:9 (claims POST) vs routes/payout.go:31 (registers PUT).
  Discovered while writing integration-tests/test-payout-confirm-completed.sh under
  workflow-2. Handler: controllers/PayoutController.go ConfirmPayoutCompleted.
created: 2026-04-16
project: github.com/kokarat/mobiz-payment-gateway
---

# Drift — docs/test-coverage-gaps.md says POST /payouts/:id/confirm-completed but route is PUT

## What is wrong

`docs/test-coverage-gaps.md` row for the confirm-completed gap reads:

> `POST /api/v1/payouts/:id/confirm-completed` — admin marks a failed payout as actually completed when bank statement proves transfer (`4720f20` #160)

But `routes/payout.go:31` registers the route as `PUT`, and the handler body
parses accordingly. The test (`test-payout-confirm-completed.sh`) calls `PUT`
because that is what the server actually exposes.

## Why it matters

- A contributor reading the gaps doc and copying the verb into a new test
  would get 405 Method Not Allowed and chase a phantom bug.
- The gaps doc is owned by the tester role; the route is stable. The doc
  is the side that is wrong.
- The same drift could hide other subtle payout ops (admin override,
  resend-callback, expiry) — the payout-admin surface is large and the
  coverage-gaps doc has several rows about it in the same block.

## Resolution applied

Not corrected in this learning. P-001 forbids silently rewriting the
"Surface" column to erase the bad verb. Resolution path:

1. Keep the row body text untouched (it is a historic claim from when the
   row was written).
2. Mark the row `filled` with `test-payout-confirm-completed.sh` — done
   2026-04-16 under workflow-2.
3. Leave this learning as the canonical pointer so the next tester or
   technical_writer reviewing payout coverage knows the verb in that row
   is wrong and can audit sibling rows for the same class of mistake.

## Audit items for next tester pass

Re-check verbs on the payout-admin rows in `docs/test-coverage-gaps.md`:

- `POST /api/v1/payouts/:id/resend-callback` — actually `POST` per route file. ✅
- `PUT /api/v1/payouts/:id/override` — actually `PUT` per route file. ✅
- `POST /api/v1/payouts/:id/confirm-completed` — **wrong**, actually `PUT`.

Only confirm-completed is miswritten. The bad verb entered the gaps doc at
the time the gap was logged (commit `3b7e0f1` baseline); no subsequent
edit introduced it.

## Handoff

Tag `#drift` so `technical_writer` can pick this up if they do a cross-doc
audit of payout routes. Not urgent — the gap is closed and no production
code is affected.
