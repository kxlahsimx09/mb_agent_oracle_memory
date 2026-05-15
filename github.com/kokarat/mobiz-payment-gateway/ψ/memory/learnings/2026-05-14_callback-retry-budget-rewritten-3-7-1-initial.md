---
title: Callback retry budget rewritten 3 → 7 (1 initial + 6 scheduler-driven) with per-
tags: [technical-writer, repo:mobiz-payment-gateway, current, callback, scheduler, retry-budget, regression-candidate]
created: 2026-05-14
source: services/callbackService.go:180-213,544-565,567-694@f16d602
project: github.com/kokarat/mobiz-payment-gateway
---

# Callback retry budget rewritten 3 → 7 (1 initial + 6 scheduler-driven) with per-

Callback retry budget rewritten 3 → 7 (1 initial + 6 scheduler-driven) with per-attempt cooldowns 1/3/5/7/9/15 min (`534da18` #436, 2026-05-14). Total send window from attempt 1 to attempt 7 is 40 minutes. The send path itself no longer loops — `SendDepositCallback{Force,By}` and `SendPayoutCallback{Force,By}` do exactly one HTTP attempt + log + status update + return. Persistent retry is owned entirely by `CallbackRetryScheduler` via `ProcessPendingCallbacks`. Spacing rationale (from the file comment): transient client-side blips recover within ~1 min, but the last bucket is stretched to 15 min so a genuinely overloaded merchant gets time to drain. Caller-blocking time on a timing-out endpoint dropped from ~90 s (three 30 s inline retries) to ~30 s (one attempt). New filter helper `buildAttemptCooldownClauses` picks `attempts=N AND last_callback_at <= now - retryCooldownByAttempts[N]` per retry bucket and adds a safety-net branch for rows where `callback_attempts` is missing or 0 (initial-trigger goroutine never ran — pod crash before send).

---
*Added via Oracle Learn*
