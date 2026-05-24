---
title: NEUTRAL — #460 9aebabb defer-Thunder-slip-verification — W1 twenty-fifth baselin
tags: [tester, repo:mobiz-payment-gateway, current, coverage-gap, deposit, slip-fraud, scheduler, w1-twenty-fifth-baseline]
created: 2026-05-22
source: controllers/DepositController.go (UploadSlipAdmin/ReverifySlip) + scheduler/deposit_expiry.go:95-198 + services/slipVerifyService.go + controllers/DepositRequestController.go:806-975 @9aebabb
project: github.com/kokarat/mobiz-payment-gateway
---

# NEUTRAL — #460 9aebabb defer-Thunder-slip-verification — W1 twenty-fifth baselin

NEUTRAL — #460 9aebabb defer-Thunder-slip-verification — W1 twenty-fifth baseline, 0 status flips across 49 tests.

What changed: #460 (squash of kokarat/youpay-backend PR #3, 4 commits) reworks slip-verification timing across 5 files — admin `UploadSlipAdmin` made status-aware (pending stays pending; expired/failed/checking → checking + `slip_verify_status=queued`); NEW admin `ReverifySlip` endpoint (POST /api/v1/deposits/:id/reverify-slip, perm deposit:update); `scheduler/deposit_expiry.go` now skips pending deposits carrying a slip (`$or:[{slip_image:""},{slip_image:{$exists:false}}]` at :95-98) and adds `processSlipEscalation` (escalates a slip-bearing pending deposit to checking + queues Thunder after slip_review_timeout_minutes, default 15); NEW `services/slipVerifyService.go::ProcessSlipVerification` worker (atomic compare-and-set on slip_verify_status, slipVerifyMaxAttempts=3, SlipVerifyStaleAfter=2m, E11000 dup-slip_trans_ref handling); additive models/deposit.go fields; 1-line comment deletion in RefundDeposit.

Why NEUTRAL: the CLIENT endpoint that test-deposit-upload-slip.sh calls — POST /api/v1/deposit/:txnId/upload-slip (DepositRequestController.UploadSlip) — is NOT in #460's 5-file stat. It still flips pending→checking (DepositRequestController.go:939) and 503s when helpers.Storage==nil (line 882), so in the CDN-less test env the test takes its expected 503 skip-branch, unchanged. The commit message's "/deposits/:id/upload-slip" is the ADMIN plural route (UploadSlipAdmin), a different handler. grep across all 49 tests for reverify-slip|/deposits/*upload-slip|slip_verify_status|slip_review|processSlipEscalation|ProcessSlipVerification → 0 hits. test-deposit-expiry.sh uses SLIPLESS pending deposits (new skip-predicate inert; already tolerates pending|checking at :334/:429). test-deposit-slip-fraud.sh mongo-injects slip_verify_result and tests the untouched admin PUT .../status {"status":"paid"} V1/V2/V3 fraud gates. test-deposit-refund.sh sees only a comment deletion.

Coverage gap (🟡 Important): the admin slip-review-deferral surface (UploadSlipAdmin status-aware logic, ReverifySlip requeue, processSlipEscalation timeout escalation, slipVerifyService worker CAS+dedup) has zero integration coverage. Escalated above 🟢 because the deferred-verification window is fraud-adjacent — a slip-bearing pending deposit now lingers up to slip_review_timeout_minutes before Thunder is invoked, and these paths gate WHEN fraud detection runs. Connects to prior Oracle findings that slip-fraud flags are detected-but-not-enforced and the retroactive slip-fraud scan is inert.

Net: matrix carries forward verbatim — 44 VALID / 1 STALE (test-settlement-cancel.sh, pre-existing /cancel→/reject) / 2 SUPERSEDED / 2 ON_HOLD. No new STALE/WRONG-SETUP/FLAKY. PR #456 amended to cumulative c7b2232..9aebabb (W1 twenty-fifth baseline).

---
*Added via Oracle Learn*
