---
title: W1 twenty-second baseline (f16d602..33664cd) — 2 production-surface commits, BOT
tags: [tester, repo:mobiz-payment-gateway, current, w1, no-op, tester-territory, maintenance, rate-limit, coverage-gap]
created: 2026-05-16
source: git log f16d602..33664cd --stat @ 2026-05-16 GMT+7; helpers/maintenance.go@cf3e02f + helpers/ratelimit.go@33664cd
project: github.com/kokarat/mobiz-payment-gateway
---

# W1 twenty-second baseline (f16d602..33664cd) — 2 production-surface commits, BOT

W1 twenty-second baseline (f16d602..33664cd) — 2 production-surface commits, BOTH NEUTRAL across the 49-test suite, zero status flips.

Range covered: f16d602..33664cd (2 production-surface commits; merge commits 28fc53d/bedfc2f/d9e816c are vault/docs-only).

(A) cf3e02f PR #442 — per-service maintenance windows for deposit/payout. helpers/maintenance.go refactored (96 ins/110 del, single file): the single global maintenance window splits into independent deposit_window / payout_window config keys. GET /api/v1/maintenance/status keeps all legacy fields with unchanged semantics and adds 8 fields (deposit_window, payout_window, in_deposit_window, in_payout_window, deposit_blocked, payout_blocked, deposit_message, payout_message). No schema migration; commit body states "existing deployments behave exactly as before this change." NEUTRAL: no test calls /api/v1/maintenance/status or seeds a window — grep -ln maintenance integration-tests/test-*.sh matches only header-comment prose in test-dispatcher-stale-bot-skip.sh (lines 93, 204, both enumerating what the test does NOT cover).

(B) 33664cd PR #443 — rate-limit counter scope fix. helpers/ratelimit.go gains a scope arg so the Redis key becomes ratelimit:{clientID}:{scope}:day:{date} instead of the shared ratelimit:{clientID}:day:{date}. Before the fix deposit+payout shared one counter checked against different caps (deposit 100k/day, payout 10k/day) — a high-volume deposit client starved its own payout rate budget. DepositRequestController/PayoutRequestController pass "deposit"/"payout"; cap raised to 300k for both. NEUTRAL: the helpers are called only from the client-facing API-key endpoints /api/v1/deposit-request + /api/v1/payout-request, and grep -lnE "deposit-request|payout-request" across all 49 tests returns 0 hits. The 429s in test-deposit-refund.sh are TOTP step-up lockout (2FA_LOCKED), an unrelated surface.

Matrix carried forward verbatim: 44 VALID / 1 STALE (test-settlement-cancel.sh) / 0 WRONG-SETUP / 0 FLAKY / 2 SUPERSEDED (test-payout-cancel.sh, test-raw-resp.sh) / 2 ON_HOLD (test-payout-confirm-completed.sh, test-payout-auto-reconcile.sh) / 0 UNKNOWN. VALID rows' last-verified bumped f16d602 -> 33664cd.

Two new coverage-gap rows appended: 🟡 maintenance (per-service window cross-wire is the load-bearing assertion — the whole maintenance endpoint+gate surface has zero coverage); 🟢 rate-limit (scope-namespacing is a non-obvious invariant a revert could collapse, re-introducing the cross-endpoint starvation #443 fixed).

---
*Added via Oracle Learn*
