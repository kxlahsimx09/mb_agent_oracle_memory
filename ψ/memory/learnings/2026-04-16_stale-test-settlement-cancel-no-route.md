---
title: STALE — test-settlement-cancel.sh — /settlements/:id/cancel was replaced by /reject
type: learning
tags:
  - tester
  - repo:mobiz-payment-gateway
  - current
  - stale-test
  - settlement
  - drift
related:
  - 2026-04-16_decision-2026-04-16-gmt7-introduced-the-tes
source: >
  integration-tests/test-settlement-cancel.sh:216  +
  routes/settlement.go:22-32 @ commit 5b79abc (2026-03-16)
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

## What's wrong

`test-settlement-cancel.sh:216` issues `api PUT
/api/v1/settlements/${STL_ID}/cancel -d '{...}'` and asserts
`success=True`. It then checks MongoDB for `status==3` (cancelled) at
line 238. Both assertions will fail on current HEAD because the
`/cancel` route is not registered.

`routes/settlement.go:22–32` only exposes:

- `POST /`
- `GET /`, `/export`, `/stats`, `/:id`, `/client/:clientId`,
  `/partner/:partnerId`
- `PUT /:id/approve`
- `PUT /:id/reject`

Line 29 carries an explicit comment: `// UpdateSettlement removed — if
data is wrong, reject and create new one`. The earlier `e4344a4`
("settlement cleanup") completed the consolidation.

## Why this is wrong

Commit `5b79abc` (2026-03-16, "Settlement approve/reject workflow with
balance refund") replaced the older multi-status transition API with
explicit approve/reject endpoints. Both reject and the old cancel
produce the same wallet effect (full refund of amount + fee, per the
lifecycle comment in `test-settlement-flow.sh` lines 12-13), so the
functional coverage has moved, not disappeared. But the endpoint name
and status code (`status=3` vs `status=2`) have diverged.

The test was authored/updated 2026-04-09, six weeks after the API
was consolidated — the author was probably writing against older
CLAUDE.md or an earlier test as a template.

## Minimal fix (proposed, not applied)

```diff
- CANCEL_RES=$(api PUT "/api/v1/settlements/${STL_ID}/cancel" -d "{
+ CANCEL_RES=$(api PUT "/api/v1/settlements/${STL_ID}/reject" -d "{
    \"notes\":\"Cancelled by integration test\"
  }")
```

And update the DB-status assertion:

```diff
- # Status 3 = cancelled (0=pending, 1=approved, 2=rejected, 3=cancelled)
- if [ "$STL_DB_STATUS" = "3" ]; then
+ # Status 2 = rejected (0=pending, 1=approved, 2=rejected)
+ if [ "$STL_DB_STATUS" = "2" ]; then
```

Owner sign-off required: "cancel" and "reject" are semantically
distinct in audit language even when the wallet effect is identical.
If the business wants to retain a "client-initiated cancel" concept
(different audit trail, different who), the fix is larger than a
rename — it needs a new route. That decision sits above `tester`.

## Impact if unfixed

Test exits 1 every run. Same trust-erosion pattern as
test-payout-cancel.sh. Also obscures whether the real reject/refund
path still works — `test-settlement-flow.sh` exercises it briefly but
does not deeply assert the refund invariant.
