---
title: STALE — test-payout-cancel.sh root-cause amendment — admin endpoint #228 landed 
tags: [tester, repo:mobiz-payment-gateway, current, stale-test, payout, drift, admin-cancel, w1-second-baseline]
created: 2026-04-21
source: integration-tests/test-payout-cancel.sh:230,301,320 + routes/payoutRequest.go:23-26 (removed) + routes/payout.go:31 (admin cancel @ 153a4f6) + controllers/PayoutController.go:913-1079
project: github.com/kokarat/mobiz-payment-gateway
---

# STALE — test-payout-cancel.sh root-cause amendment — admin endpoint #228 landed 

STALE — test-payout-cancel.sh root-cause amendment — admin endpoint #228 landed but uses different auth.

What's wrong: `integration-tests/test-payout-cancel.sh` (lines 230, 301, 320) calls `POST /api/v1/payout/:txnId/cancel` (client-facing path) which was removed by `ba115d7` (2026-04-12). At the prior baseline `3b7e0f1` this was already STALE. At new baseline `22451ef` the picture has expanded: a NEW admin-only endpoint `PUT /api/v1/payouts/:id/cancel` landed in `153a4f6` (PR #228, 2026-04-19) with queue-first cascade + wallet refund + change-log + SSE/callback fan-out. The endpoint requires JWT + admin permission, NOT API-Key/Secret. The same PR also narrowed the generic `PUT /:id/status` validator to `oneof=pending processing completed failed waiting_to_review` — `"cancelled"` value REMOVED — closing the alternative retarget path.

Why this is wrong: The test was written as a client-facing assertion ("a client can cancel its own payout request"). The new admin endpoint cannot be a one-line URL/method swap — it needs different auth (JWT not API-Key) and rephrased semantics ("admin cancels a pending payout"). Test status remains STALE; the prior arra_learn `2026-04-16_stale-test-payout-cancel-removed-route` records the original removal; this learning extends it with the post-#228 design topology so future-tester knows both halves of the picture.

Minimal fix (proposed, not applied): Two options, owner sign-off required either way. (a) Remove the test, preserve via P-001 with a SUPERSEDED header citing `ba115d7`'s design intent (cancel happens via maintenance-window / processing-timeout pathway, not via explicit client API). (b) Re-architect to use admin auth path against `PUT /api/v1/payouts/:id/cancel` (`#228`) and rephrase assertions. Option (a) is cheaper; option (b) closes a real coverage gap on admin payout cancel.

Impact if unfixed: Test continues to fail at Step 5 (CANCEL_STATUS != "success"). False-signal risk is low since it's a hard fail not a silent pass. Coverage gap on the new admin endpoint is unfilled — no test exercises queue-first cascade + wallet refund through PR #228's path.

Related: 2026-04-16_stale-test-payout-cancel-removed-route (prior STALE finding); 2026-04-19_title-payout-admin-cancel-endpoint-put-pay (technical-writer's note on the new endpoint shape).

---
*Added via Oracle Learn*
