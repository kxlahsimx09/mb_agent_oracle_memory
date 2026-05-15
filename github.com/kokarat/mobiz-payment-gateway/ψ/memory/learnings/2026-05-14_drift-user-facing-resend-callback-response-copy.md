---
title: drift — user-facing resend-callback response copy now stale against actual retry
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, user-facing-copy, callback, w4-queued, regression-candidate]
created: 2026-05-14
source: controllers/DepositController.go:2495@f736f63, controllers/PayoutController.go:1617@f736f63, services/callbackService.go:184@534da18
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — user-facing resend-callback response copy now stale against actual retry

drift — user-facing resend-callback response copy now stale against actual retry budget. `controllers/DepositController.go:2495` and `controllers/PayoutController.go:1617` still return the literal Thai/English message "system will retry up to 3 times automatically" after a successful `POST /:id/resend-callback`. The retry math underneath was bumped to 7 attempts (1 initial + 6 scheduler-driven, per-attempt cooldowns 1/3/5/7/9/15 min) in `services/callbackService.go` via `534da18` #436 (2026-05-14). The doc references the literal-quote in §3.2 deposit/payout but flags the divergence inline. Fix needed: update both message strings to "7 times automatically" (or refactor to read `services.NewCallbackService().maxRetries` so the message tracks the constant). Out-of-territory for W2 (controllers not in the f736f63..f16d602 range); queued for W4.

---
*Added via Oracle Learn*
