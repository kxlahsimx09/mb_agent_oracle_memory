---
title: W1 eleventh baseline (8b94f05) — slip-fraud cluster (PRs #360–#367) NEUTRAL for 
tags: [tester, repo:mobiz-payment-gateway, current, w1-eleventh-baseline, slip-fraud, deposit, coverage-gap, neutral-pass]
created: 2026-05-01
source: controllers/DepositController.go:814-950@8b94f05 + services/transactionMatcher.go:730-800@8b94f05 + services/slipMatchHash.go@8b94f05 + services/slipFraudCheck.go@8b94f05 + services/bankStatementParser.go@8b94f05 + git log ffc33cb..8b94f05 (9 commits)
project: github.com/kokarat/mobiz-payment-gateway
---

# W1 eleventh baseline (8b94f05) — slip-fraud cluster (PRs #360–#367) NEUTRAL for 

W1 eleventh baseline (8b94f05) — slip-fraud cluster (PRs #360–#367) NEUTRAL for all 46 tests; ALL untested.

Range ffc33cb..8b94f05 ships 9 production-surface commits, 6 of which form an interrelated slip-fraud defense cluster inside controllers/DepositController.go::UpdateDepositStatus + services/transactionMatcher.go::finalizeDeposit. Production scan justifying the cluster: 905 cases / 1.07M THB across 90d on cross-receiver slip uploads.

Three new gates fire only when `input.Status == "paid"`:
(a) PR #361 a463f51 — slip-bearing-deposit human-approval gate. If deposit.slip_uploaded_at is non-zero, caller must be adminUserType ∈ {admin,user} AND non-empty adminUsername (not "system"). Bot endpoints (BotAuthMiddleware doesn't populate user_type) and scheduler paths return 403.
(b) PR #360 ef71420 (refined by #364 eac6c55 mask-aware NATID position compare) — V2 slip-receiver mismatch. Last4 of slip.rawSlip.receiver.proxy.account vs deposit.promptpay_id; mismatch → 400 with structured {slip_receiver_last4, deposit_promptpay_last4} payload.
(c) PR #362 44f8634 (refined by #366 78a2dc3 pick-best-candidate) — V1 slip-reuse fraud. SlipMatchHashService.MatchSlipAgainstStatements queries bank_statements.match_hash; if statement already linked to different deposit's request_id, reject 400.

Override path: PR #367 8b94f05 extends [force-approve] notes-marker from super_admin-only → admin OR super_admin via new isAdminWithForceApprove helper. Audit log lines "[Deposit] FRAUD OVERRIDE" / "FRAUD OVERRIDE V1" record actor + notes.

Auto-match path preserved: services/transactionMatcher.go::finalizeDeposit gains goroutine checkRetroactiveSlipFraud that scans for paid-by-slip deposits with same dest+amount+BKK-day; on collision, marks bank_statement match_status="review" + appends audit_logs[fraud_retroactive_flag] on older slip-paid deposit. Tests don't seed those collisions so goroutine returns 0 rows.

Non-fraud commits in same range (3): PR #357 08ab0b8 Restart Bot SSH systemctl (replaces DO API reboot, 202→200 status flip, no test exists); PR #351 c5ee388 Pullout DestCap settled-unsynced 15m→60m operator-tunable (no pullout test exists); PR #365 063983c BankStatement parser fallback for SCB "รับเงินจาก" verb form + pre-compute match_hash on every inbound row (tests provide source_bank_code explicitly so fallback never fires).

Test coverage impact: ZERO. grep -lE "/deposits/.+/status|slip_verify_result|match_hash|MatchHash|UploadSlipAdmin|\[force-approve\]" integration-tests/test-*.sh returns zero hits. No test calls the admin status-update endpoint with slip data, no test seeds slip_verify_result, no test asserts on match_hash field. test-deposit-upload-slip.sh stops at status="checking" (the upload itself), well before any of the new gates fire.

Status counts unchanged from W1 tenth baseline:
- VALID: 39 (last-verified bumps to 8b94f05)
- STALE: 1 (test-settlement-cancel.sh — carry from prior)
- WRONG-SETUP: 0
- FLAKY: 0
- SUPERSEDED: 2 (test-payout-cancel.sh, test-raw-resp.sh)
- ON_HOLD: 2 (test-payout-{auto-reconcile,confirm-completed}.sh)
- UNKNOWN: 2 (test-payout-override.sh, test-payout-ktb-post-otp-waiting-to-review.sh)
- Total: 46

Coverage gaps logged to docs/test-coverage-gaps.md: 8 new rows — one 🔴 Critical umbrella (slip-fraud V1/V2 cluster) + 5 sub-detail rows (🟡 Important to 🟢 Nice-to-have) + one 🟢 self-healing parser fallback + one 🟢 pullout-window-extension under existing pullout umbrella.

The slip-fraud surface is the largest single-baseline coverage gap W1 has ever booked; combined documented historical impact (1.07M THB) and dual-blocker design (V2 cross-destination + V1 same-destination duplicate) make this the highest-priority gap currently open.

---
*Added via Oracle Learn*
