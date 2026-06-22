---
title: STALE (latent / env-masked) — test-deposit-upload-slip.sh — #522 d921419 made a 
tags: [tester, repo:mobiz-payment-gateway, current, stale-test, drift, deposit, slip-upload, w1]
created: 2026-06-16
source: integration-tests/test-deposit-upload-slip.sh:L140-L158 + controllers/DepositRequestController.go::UploadSlip@d921419 (#522)
project: github.com/kokarat/mobiz-payment-gateway
---

# STALE (latent / env-masked) — test-deposit-upload-slip.sh — #522 d921419 made a 

STALE (latent / env-masked) — test-deposit-upload-slip.sh — #522 d921419 made a pending deposit stay pending after slip upload

What's wrong: W1 pass ae09c34..03d6383. PR #522 `d921419` ("Defer Thunder slip verification on the client upload-slip API") changed DepositRequestController.UploadSlip so that a PENDING deposit now STAYS pending after slip upload (newStatus := deposit.Status; only deposit.Status != "pending" flips to "checking"). Before #522 every slip upload flipped the deposit inline to "checking". test-deposit-upload-slip.sh creates a pending deposit then uploads a slip and, in its success branch (UPLOAD_STATUS=="success"), hard-asserts at L143-148 that GET /deposit/status/<txn> == "checking" (else log_fail + TEST_RESULT=1). Under #522 a pending deposit reports "pending", so that assertion is now contractually wrong.

Why this is wrong: test↔code contract drift (P-004). #522 is an intentional design change (mirror the PR #460 deferred-verification flow onto the client path so the bank-statement matcher keeps the full slip_review_timeout_minutes window) — #stale-test, not #regression-candidate.

Latent / masking nuance (important for the regression gate): in the standard integration test env DigitalOcean Spaces/CDN is NOT configured, so UploadSlip returns 503 ("storage not available"); the test's L150 elif branch then SKIPS the status check and exits 0. So the drift does NOT fail a regression run today — it only surfaces if a CDN is configured (UPLOAD_STATUS=="success"). The test passes-for-the-wrong-reason (storage dependency), masking the drifted assertion. Counted as a status flip (VALID→STALE) but flagged as latent in the matrix.

Minimal fix (proposed, not applied — user sign-off): in the success branch assert the deposit stays "pending" after slip upload on a pending deposit (the #522 contract), and add a separate case that uploads a slip on a non-pending (checking/expired/failed) deposit to assert it moves to "checking" + slip_verify_status=queued. Note the response no longer returns transRef/verifyResult.

Impact if unfixed: the test's documented core claim ("slip upload → status=checking") is false for the dominant pending-deposit case; a future CDN-enabled test run would fail; the deferred-verification contract goes unverified.

Related: matrix row for test-deposit-upload-slip.sh already noted it asserts status=checking and never transitions to paid. Paired this pass with the #529 slip-fraud STALE flip. Prior baseline ae09c34 (merged PR #517).

---
*Added via Oracle Learn*
