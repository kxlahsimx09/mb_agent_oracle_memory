---
title: STALE — test-payout-cancel.sh — client-facing /payout/:txnId/cancel was removed
type: learning
tags:
  - tester
  - repo:mobiz-payment-gateway
  - current
  - stale-test
  - payout
  - drift
related:
  - 2026-04-16_decision-2026-04-16-gmt7-introduced-the-tes
source: >
  integration-tests/test-payout-cancel.sh:230  +
  routes/payoutRequest.go:23-26 @ commit ba115d7 (2026-04-12)
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

## What's wrong

`test-payout-cancel.sh:230` issues `curl -X POST
${BACKEND_URL}/api/v1/payout/${PAY_TXN}/cancel` with the client's API-Key
+ API-Secret and asserts `CANCEL_STATUS == "success"` at line 239, then
re-asserts `GET /api/v1/payout/status/${PAY_TXN}` returns
`status=cancelled` at line 248. Both assertions will always fail on
current HEAD (`3b7e0f1`) because the cancel route is not registered in
the backend.

## Why this is wrong

Commit `ba115d7` (2026-04-12, "Remove client-facing payout cancel API
route") removed the client-facing cancel route deliberately. The
removal is documented inline in `routes/payoutRequest.go:23-26`:

```
// Cancel route removed — system handles cancellation automatically
// (maintenance window, processing timeout, etc). Clients should not
// cancel payouts manually once submitted.
// payout.Post("/:txnId/cancel", middleware.APIKeyCheck(), ctrl.CancelPayout)
```

The test was authored 2026-04-09 (`9 Apr 19:20`), three days before the
removal. It became STALE on 2026-04-12.

## Minimal fix (proposed, not applied)

Two plausible paths — both require owner sign-off because they change
what the test is asserting:

1. **Delete the test** and mark it SUPERSEDED in `docs/test-index.md`
   with a pointer at the natural replacement (expiry-based cancel via
   `scheduler/payout_expiry.go` + 15-min timeout). The test file stays
   in tree per P-001 but gains a superseded header.

2. **Retarget at the admin-side cancel path.** If the product intent
   is "admins can still cancel on behalf of clients," rewrite to call
   `PUT /api/v1/payouts/:id/status` with status=3 (cancelled) using a
   super_admin JWT, and assert wallet refund. This is a different
   flow from the original "client cancels own payout" story — the
   coverage gap it closes is different.

Either way, `docs/test-coverage-gaps.md` should gain an entry for
"client-initiated payout cancel" marked **intentionally unsupported**
so future agents don't re-propose the same test.

## Impact if unfixed

Test exits 1 every run. CI treats as a regression signal. Human
reading CI sees "payout cancel broken" and may chase a non-bug.
Noise → trust erosion in the test suite.
