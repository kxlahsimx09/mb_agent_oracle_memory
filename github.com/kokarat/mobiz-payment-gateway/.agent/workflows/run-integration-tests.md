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
- `test-payout-cancel.sh` — **SUPERSEDED** by `test-payout-admin-cancel.sh` (kept per P-001). Exercises the OLD client-facing `POST /api/v1/payout/:id/cancel` endpoint that PR #228 (`153a4f6`) removed from the generic `/status` validator's accept list. Do not modify — write new assertions in the replacement test.
- `test-payout-admin-cancel.sh` — admin cancel via `PUT /api/v1/payouts/:id/cancel` (PR #228 `153a4f6`, `controllers/PayoutController.go:999-1159`). 4-step cascade: queue-first guard → payout flip → wallet refund (amount + fee) → callback. 4 phases — happy path (asserts payout.status=cancelled + WQ.status=cancelled + wallet refunded + 1 wallets_change_logs entry tagged reference_type=payout); re-cancel guard (already-cancelled → 400 "Only pending", no double refund); bot-processing guard (WQ flipped to processing → 400 "bot is currently processing", payout stays pending, wallet unchanged); non-existent OID → 404. No real bot — bot never starts. **Expected GREEN**.
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
- `test-scb-statement-skip-future-row.sh` — SCB statement future-date 5-minute guard (bank-bot PR #64 / commit 3faa83a). Inject 1 LEGIT (now-10min) + 1 FUTURE (now+12h) statement row via mock-bank POST /admin/add-statement → start SCB bot (viewer loop scrapes intraday tab every 30s) → assert LEGIT lands in `bank_statements`, FUTURE absent, bot log shows `[Statement] Skipping future transaction:`, and `MAX(transaction_date_bkk)` cursor is anchored at LEGIT's timestamp (not poisoned). **Expected GREEN** (regression tripwire) — guard at `bank-bot/banks/scb/statement.js:286-292` already merged. Red here = guard removed/weakened, leading to silent cursor poisoning that blocks all subsequent scrapes.
- `test-settlement-confirm-review.sh` — admin ยืนยันผลของ settlement ที่ bot ทิ้งใน waiting_to_review (PUT /settlements/:id/confirm-review, PR #225 `596ddc0`). Short-circuit ผ่าน /bot/queue/:id/waiting-to-review (ไม่รัน bot จริง) เพื่อผลัก settlement ไป status=3, ทดสอบ 2 สาขาใน test เดียว + 2 settlement docs: **success branch** → settlement.status=1, WQ=success, wallet ไม่เปลี่ยน, **no MDR distribution** (locks in `docs/current-system.md §3.2.2 [UNVERIFIED]`); **failed branch** → status=2, WQ=failed, wallet refund amount+fee + `wallets_change_logs(settlement_refund)`; guard: second confirm-review on status=1 → HTTP 400. **Expected GREEN**.
- `test-dispatcher-stale-bot-skip.sh` — dispatcher skips banks with `bot_last_checked` > 5 min old (PR #206 `f7f43bc`, `scheduler/withdrawal_dispatcher.go:372-381`). Setup 2 SCB banks in same pool, both online/ready/funded. Pre-test sanity: both fresh, enqueue 4 payouts, assert load-balancer distributes (not 4/0). Phase 1 (B stale -6min): enqueue 5, assert all 5 on A + backend log has ≥1× stale-skip for B's account. Phase 2 (A stale, B fresh, positive control): invert, assert all 5 on B + log has ≥1× stale-skip for A. Uses `drain_bank_queue` + `unlock_both_banks` helpers to free dispatcher's per-bank cap (tier-randomized 1-5 via `findBestBankForItem`'s `inflight` gate) so iterations don't block themselves. **Expected GREEN**.
- `test-dispatcher-min-max-amount.sh` — dispatcher honors `withdrawal_min_amount` / `withdrawal_max_amount` per bank (PR #335 `ae6f523`, `scheduler/withdrawal_dispatcher.go:512-521`). Setup 2 SCB banks in same pool. 4 phases, 1 item each (no pre-test sanity gate — only 1 eligible bank per phase, picker has no tie to break). Phase 1: A min=1000 max=10000, B no-limit, enqueue 500 → lands on B + log has `< withdrawal_min_amount` for A. Phase 2: same A config, enqueue 15000 → lands on B + log has `> withdrawal_max_amount`. Phase 3 (operational risk): both banks min=2000, enqueue 500 → WQ stays pending (no bank eligible) + both banks log skip. Phase 4 (convention): A no-limit, B min=999999, enqueue 100 → lands on A + B log skip (proves 0 = "no limit"). **Expected GREEN**.

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
