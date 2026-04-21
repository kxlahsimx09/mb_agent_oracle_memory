---
description: รัน Integration Tests (Run Integration Tests)
---

# Run Integration Tests Workflow

This workflow is used to run integration tests for the standard payment gateway flows. 
The user can specify which test to run. If the user does not specify a test, **choose one by default** (e.g., `test-deposit-flow.sh`).

**Available Test Scripts:**
- `test-deposit-flow.sh`
- `test-deposit-ktb.sh`
- `test-deposit-expiry.sh` — ทดสอบ deposit หมดอายุ (สร้างแต่ไม่โอนเงิน → scheduler expire)
- `test-topup-flow.sh` — ทดสอบ topup (Admin เติมเงิน → approve → wallet เพิ่ม)
- `test-settlement-flow.sh` — ทดสอบ settlement (ร้านค้าถอนเงิน → approve/reject)
- `test-mixed-flow.sh`
- `test-payout-flow.sh`
- `test-payout-ktb.sh`
- `test-mdr-fee-distribution.sh` — ทดสอบการแบ่งค่า Fee MDR Profile (deposit/payout/topup/settlement → verified partner wallet distributions)
- `test-deposit-cancel.sh` — ยกเลิก deposit ที่ pending → status=cancelled, wallet ไม่เปลี่ยน, bank transfer หลัง cancel ไม่ถูก match
- `test-payout-cancel.sh` — ยกเลิก payout ที่ pending → status=cancelled, wallet refund (คืนครบ)
- `test-settlement-cancel.sh` — ยกเลิก settlement ที่ pending (status=0) → status=3 (cancelled), wallet refund (amount+fee)
- `test-deposit-min-max-limit.sh` — ทดสอบขีดจำกัด min/max deposit ต่อ client → ต่ำกว่า min / สูงกว่า max = rejected
- `test-payout-insufficient.sh` — payout เมื่อ wallet ไม่พอ → rejected พร้อม error message ชัดเจน
- `test-deposit-upload-slip.sh` — upload slip หลักฐานโอนเงิน → status=checking (ต้องการ CDN ถ้าจะทดสอบ full path)
- `test-deposit-idempotency.sh` — X-Idempotency-Key ป้องกัน duplicate request → txnId เดิม ไม่สร้าง record ใหม่
- `test-settlement-insufficient.sh` — settlement ที่ wallet ไม่พอ → rejected ทันที (amount + fee > wallet)
- `test-deposit-promptpay-qr.sh` — ทดสอบ deposit PromptPay QR (system bank มี promptpay → channel=QR + qrcode EMV payload → แกะ QR → โอนเงิน → bot match)
- `test-payout-confirm-completed.sh` — admin ยืนยัน payout ที่ bot mark failed ว่าโอนสำเร็จจริง (PUT /payouts/:id/confirm-completed) → status failed→completed, wallet หัก amount+fee, distribute MDR, WQ success, double-confirm guard rejects
- `test-payout-auto-reconcile.sh` — auto-reconcile: ระบบ flip payout failed→completed เองเมื่อ bank_statement matched กับ WQ ก่อน MarkFailed (goroutine tryReconcileAfterMarkFailed, PR #161+#172) → ผลเหมือน manual confirm แต่ confirmed_by=system:auto-reconcile, cross-boundary guard reject admin manual call ที่มาทีหลัง
- `test-payout-expiry.sh` — 15-min pending-payout auto-cancel scheduler (scheduler/payout_expiry.go, commit 5b83546) → back-date payout.createdAt 20 นาที, รอ ≤120s ให้ scheduler tick มาเจอ + cancel + refund wallet (amount+fee), assert WQ.cancelled, change_log payout_refund/changed_by=payout_expiry_scheduler
- `test-payout-ktb-post-otp-waiting-to-review.sh` — KTB post-OTP ambiguity → waiting_to_review (Oracle thread #16 forward-looking). Uses mock-bank POST /admin/ktb/break-otp-confirm (PR #232) → window.close() in confirmTransferOTP → bot throws KTB_POST_OTP → assert WQ.status=waiting_to_review + wallet NOT refunded. **Expected RED at HEAD** until bank-bot dispatcher fix lands (adds `else if (r.status === 'waiting_to_review')` branch at app.js:1601-1631 / :1832-1838).
- `test-payout-scb-post-otp-waiting-to-review.sh` — SCB analogue of the KTB drift test. Uses mock-bank POST /admin/scb/break-otp-confirm (PR #250, Oracle thread #28 fixture) → capture-phase listener wipes `index.html` document on Confirm-OTP click → Playwright `.click()` scheduled-navigation timeout → `banks/scb/approver.js:582-590` returns `{status:'waiting_to_review'}` → dispatcher routes via `safeMarkWaitingToReview`. **Expected GREEN** (regression tripwire) — dispatcher branch at `app.js:1645/:1714` already merged. Red here = dispatcher OR approver return regressed.

## Mandatory Steps

All commands must be executed with the `Cwd` set to:
`/Users/dev01/Documents/self/mobiz/mobiz-payment-gateway/integration-tests`

1. **Determine the target test script**
   Review the user's request. If no specific script was stated, select `test-deposit-flow.sh` as the default.

2. **Clean up the environment**
   Run the following command and wait for it to finish completely. This cleans up previous test residual data.
   ```bash
   ./run-integration-test.sh --clean
   ```

3. **Start the test environment**
   Run the test environment via the following command. The command will run in the background / block the terminal, so you **must start this in the background** (for example, by setting `WaitMsBeforeAsync` in the `run_command` tool) or in a separate persistent terminal to allow it to run and create the `env test`.
   ```bash
   ./run-integration-test.sh
   ```
   **Important**: Wait a reasonable amount of time (e.g., 5-10 seconds) for the environment and servers to be fully booted up.

4. **Run the selected test script**
   In a **new command execution**, run the actual test script selected in Step 1.
   ```bash
   ./<selected-test-script.sh>
   ```

5. **Monitor and Report**
   Wait for the selected test script to complete and provide a clear summary of the integration test results to the user based on the terminal output.
