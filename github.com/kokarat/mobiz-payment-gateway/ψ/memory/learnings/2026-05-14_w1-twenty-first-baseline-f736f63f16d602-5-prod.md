---
title: W1 twenty-first baseline f736f63..f16d602 — 5 production-surface commits NEUTRAL
tags: [tester, repo:mobiz-payment-gateway, current, callback, scheduler, retry, baseline, w1-twenty-first, regression-candidate]
created: 2026-05-14
source: services/callbackService.go@f16d602 + scheduler/callback_retry.go@f16d602 + controllers/DashboardController.go@c8588a1 + integration-tests/test-*.sh (49 files grep-checked, 0 hits on callback_attempts/scheduler/dashboard)
project: github.com/kokarat/mobiz-payment-gateway
---

# W1 twenty-first baseline f736f63..f16d602 — 5 production-surface commits NEUTRAL

W1 twenty-first baseline f736f63..f16d602 — 5 production-surface commits NEUTRAL across the 49-test suite — notable callback retry redesign with self-induced regression

Range covers PR #433 (client-scoped dashboard endpoints), PR #320 (callback header rebrand MAXPAY→Ampay), PR #435 (callback shared keep-alive HTTP/2 transport + retryBatchLimit 100→20), PR #436 (scheduler-driven exponential backoff 1/3/5/7/9/15 min, maxAttempts 3→7, inline for-loop deleted), PR #437 (URGENT follow-up: scheduler filter `created_at` → `createdAt` camelCase to match bson tag on ts_deposits/ts_payouts).

Notable: PR #436 deleted the inline retry safety net (3 attempts in 90s) before realising the scheduler filter in ProcessPendingCallbacks was broken — used snake_case `created_at` while bson tag is camelCase `createdAt`. Pre-#436 the broken filter was hidden because the inline loop still retried 3× before giving up. Post-#436, retries depended ENTIRELY on the scheduler, so attempts froze at 1 across the entire fleet — counted live: 1,400 rows in last 24h with `callback_sent != true` filtered out by the broken date predicate. PR #437 fixed the filter the same day. The pattern — `delete-the-safety-net-then-discover-the-fix-was-broken` — is a recurring tester-relevant signal: when a PR removes a fallback path, the test suite must already have coverage of the now-load-bearing fallback; here the suite has zero callback_attempts/scheduler-timing assertions, so neither the broken state nor the fix was observable.

Why all 5 NEUTRAL: no test in the 49-file suite asserts on outbound webhook header values (MAXPAY/Ampay rebrand silent), callback_attempts count, callback_logs rows, scheduler retry timing, retry-cooldown cadence, HTTP transport configuration, or any /dashboard endpoint (admin or client). The two ON_HOLD payout tests stay ON_HOLD — #436 changes retry CADENCE only, not single-emission semantics, so the MarkFailed double-callback race (Oracle thread #2, fact-markfailed-callback-race-still-at-head-ed45b7e) is unchanged.

Impact if unfixed (coverage gap): a future regression in the scheduler filter (snake_case re-introduction, missing index, dropped `callback_sent != true` predicate) would silently freeze callback attempts at 1 across production with zero integration-test signal. Two new 🟡 coverage gaps appended: callback-retry scheduler tripwire (regression guard for the load-bearing scheduler path) + callback-headers lock-step (wire ↔ callback_logs.request_headers). One new 🟢 gap: client-scoped dashboard JWT-clientIds-override invariant.

Related prior learnings: fact-markfailed-callback-race-still-at-head-ed45b7e (2026-04-17, still load-bearing for ON_HOLD tests); regression-candidate-callback-resend-with-idempo (2026-04-21).

---
*Added via Oracle Learn*
