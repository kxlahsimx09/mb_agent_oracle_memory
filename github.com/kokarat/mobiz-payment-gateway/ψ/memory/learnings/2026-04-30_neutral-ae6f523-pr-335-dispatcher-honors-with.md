---
title: NEUTRAL — ae6f523 (PR #335) Dispatcher honors withdrawal_min_amount + withdrawal
tags: [tester, repo:mobiz-payment-gateway, current, coverage-gap, dispatcher, withdrawal-queue]
created: 2026-04-30
source: scheduler/withdrawal_dispatcher.go@ae6f523 + services/bankRotation.go@ae6f523 + integration-tests/test-*.sh (zero withdrawal_min/max references)
project: github.com/kokarat/mobiz-payment-gateway
---

# NEUTRAL — ae6f523 (PR #335) Dispatcher honors withdrawal_min_amount + withdrawal

NEUTRAL — ae6f523 (PR #335) Dispatcher honors withdrawal_min_amount + withdrawal_max_amount — no test impact + 🟡 coverage gap

What landed: scheduler/withdrawal_dispatcher.go::findBestBankForItem gains two new amount-range filters (after the balance check). Convention: both fields = 0 means "no limit" (matches MaximumOutstandingWithdrawal). Applies to every source_type the dispatcher routes — payout, settlement, direct_transfer, pullout. Skip lines log per-bank so operators can trace why an item is stuck pending. Legacy code path that already filtered on these fields (services/bankRotation.go::SelectBankForPayout) is now marked // Deprecated; helper kept compilable so the existing test suite still builds.

Why NEUTRAL: grep -l "withdrawal_min_amount\|withdrawal_max_amount" integration-tests/test-*.sh → zero hits. No test sets these fields on a system_bank, so every test runs against the default (0, 0) = "no limit," and the new filter is a no-op for them. The three tests that call /withdrawal-queue/stats (test-payout-flow.sh:324, test-payout-ktb.sh:356, test-burst-payout.sh:319) parse only summary.{pending,processing,success} for log-info display — no assertions on dispatcher behavior. test-dispatcher-stale-bot-skip.sh exercises findBestBankForItem's stale-bot skip but does not set min/max, so the new branch is no-op there too.

Coverage gap (filed 🟡 Important): no test asserts (a) that an item below every active bank's configured min sits in pending forever — the operational risk the PR call-out flagged — or (b) that a bank's min excludes only that bank without affecting selection at sibling banks. Ties into earlier 🟡 dispatcher gaps (stale-timeout + post-fail reconcile, idle-only behavior).

Impact if unfixed: zero on the existing 44 tests; future regression in min/max semantics could ship undetected (the gap is more load-bearing than the dashboard one because the operational risk is real — operator desk needs to be told before deploy per the PR body).

---
*Added via Oracle Learn*
