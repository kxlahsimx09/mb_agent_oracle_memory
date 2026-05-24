---
title: Defer Thunder slip verification until admin review (`9aebabb` #460, 2026-05-22).
tags: [technical-writer, repo:mobiz-payment-gateway, current, deposit, slip, thunder, scheduler, defer-verification]
created: 2026-05-22
source: controllers/DepositController.go:2084-2340@9aebabb, scheduler/deposit_expiry.go:73-267@9aebabb, services/slipVerifyService.go:1-150@9aebabb, models/deposit.go:85-93@9aebabb
project: github.com/kokarat/mobiz-payment-gateway
---

# Defer Thunder slip verification until admin review (`9aebabb` #460, 2026-05-22).

Defer Thunder slip verification until admin review (`9aebabb` #460, 2026-05-22). `UploadSlipAdmin` (POST /api/v1/deposits/:id/upload-slip) no longer calls Thunder synchronously at upload — it uploads the slip to the CDN and lets the deposit keep waiting for the bank-statement matcher to auto-confirm it (the happy path). Thunder runs lazily only on escalation. The DepositExpiryScheduler now runs three passes per 1-minute tick: processExpiredDeposits (now SKIPS pending deposits that carry a slip, so they escalate instead of expiring), processSlipEscalation (pending+slip deposits whose slip_uploaded_at is older than slip_review_timeout_minutes — app-setting, default 15 — move to checking + slip_verify_status=queued + deposits/slip_review SSE; lock:slip_escalation), and processSlipVerify (spawns services.ProcessSlipVerification for checking deposits with slip_verify_status=queued or a stale verifying claim; lock:slip_verify).

New service services/slipVerifyService.go::ProcessSlipVerification atomically claims a deposit via compare-and-set on slip_verify_status (claimable when queued, or verifying whose slip_verify_started_at is older than exported SlipVerifyStaleAfter=2m), $inc slip_verify_attempts, then calls Thunder; on failure retries until unexported slipVerifyMaxAttempts=3 then parks at failed (else back to queued); on success caches slip_verify_result + slip_verified_at + status=done, and on a duplicate transRef (pre-write FindOne OR a racing E11000 on the unique-sparse slip_trans_ref index) records slip_duplicate_of instead of writing slip_trans_ref. Safe to call concurrently from the scheduler and the admin on-demand paths because the atomic claim guarantees at most one Thunder call per claim. Upload is now status-aware (pending stays pending; checking/expired/failed move to checking + queued and $unset stale slip fields, then run verify immediately). New admin endpoint POST /deposits/:id/reverify-slip (deposit:update) re-queues Thunder for a checking deposit with slip_verify_status in {failed,done}. Upload-block guard widened from {paid} to {paid,refunded,refund_pending_review} at both lookup and UpdateOne race-guard. New deposit fields: slip_verify_status (""|queued|verifying|done|failed), slip_verify_attempts, slip_verify_started_at, slip_duplicate_of. Documented in current-system.md §3.2 (deferred-verification paragraph) + §5 (DepositExpiryScheduler 3-pass row + flow callout) + §6.7 (new slipVerifyService.go bullet, thunderSlipVerify now deferred) + §8.5 (Thunder). Mirrors kokarat/youpay-backend PR #3 (sister deployment).

---
*Added via Oracle Learn*
