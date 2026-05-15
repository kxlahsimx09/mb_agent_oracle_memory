---
title: Callback retry mechanism rewrite (services/callbackService.go, 534da18 #436 + f1
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, flow-drift, unimplemented, callback, scheduler, flow:multi, flow:deposit-auto-expire-pending, flow:deposit-auto-match-from-statement, flow:payout-admin-cancel, flow:payout-auto-cancel-pending-timeout, flow:payout-confirm-completed, flow:payout-request, w4-queued]
created: 2026-05-14
source: docs/flows/deposit-auto-expire-pending.md + docs/flows/deposit-auto-match-from-statement.md + docs/flows/payout-admin-cancel.md + docs/flows/payout-auto-cancel-pending-timeout.md + docs/flows/payout-confirm-completed.md + docs/flows/payout-request.md @ f16d602; services/callbackService.go:184-202,225-326,329-421,567-694@f16d602
project: github.com/kokarat/mobiz-payment-gateway
---

# Callback retry mechanism rewrite (services/callbackService.go, 534da18 #436 + f1

Callback retry mechanism rewrite (services/callbackService.go, 534da18 #436 + f16d602 #437, 2026-05-14) caused cross-flow ripple touching 6 flow docs' Implementation pointers. The inline `time.Duration(attempt*2) * time.Second` 3-attempt retry loop inside sendDepositCallback / sendPayoutCallback was deleted; the send path is now single-attempt; persistent retry is owned by CallbackRetryScheduler with per-attempt cooldowns 1/3/5/7/9/15 min (maxCallbackAttempts=7). W9 markers placed: [DRIFT] on deposit-auto-expire-pending step 6, deposit-auto-match-from-statement step 8 (Class B refresh — no drift, contract preserved), payout-admin-cancel step 12, payout-auto-cancel-pending-timeout step 6h, payout-auto-cancel-pending-timeout retry/idempotency bullet, payout-confirm-completed step 9 (Class B refresh), payout-request step 10 (Class B refresh). [UNIMPLEMENTED] on deposit-auto-expire-pending step 7 — the inline retry loop symbol no longer exists at HEAD. Idempotency half of thread #19's regression-candidate is still open (no idempotency-key on retries); thread stays pending. Companion drift filed for the user-facing "3 times automatically" copy in controllers (W4 queue).

---
*Added via Oracle Learn*
