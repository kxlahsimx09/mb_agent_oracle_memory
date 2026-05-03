---
title: NEUTRAL — 59bc640 (PR #334) Dashboard hourly-compare endpoint — no test impact +
tags: [tester, repo:mobiz-payment-gateway, current, coverage-gap, dashboard]
created: 2026-04-30
source: controllers/DashboardController.go@59bc640 + routes/dashboard.go@59bc640 + integration-tests/test-*.sh (zero references)
project: github.com/kokarat/mobiz-payment-gateway
---

# NEUTRAL — 59bc640 (PR #334) Dashboard hourly-compare endpoint — no test impact +

NEUTRAL — 59bc640 (PR #334) Dashboard hourly-compare endpoint — no test impact + 🟢 coverage gap

What landed: GET /api/v1/dashboard/hourly-compare in controllers/DashboardController.go:+193 + routes/dashboard.go:+4. Returns 24 hourly buckets of deposit + payout activity for today vs. yesterday in business-day order (index 0 = 02:00 BKK, index 23 = 01:00 next morning). Tenant scoping inherited from the existing dashboard:view permission gate.

Why NEUTRAL: pure additive surface — no existing route, struct, or scheduler branch is mutated. Zero integration-tests/test-*.sh files reference any /dashboard/* endpoint. The two grep hits in test-payout-auto-reconcile.sh (lines 57, 324) are header-comment narrative ("admin dashboards", "admin-dashboard realism"), not curl/api calls.

Coverage gap (filed 🟢 Nice-to-have): no test exercises the 24-bucket business-day window math, the bucket ordering convention (index 0 = 02:00), or the today-cumulative vs yesterday-full-window contract. Risk surfaces in the dashboard chart itself, not in any wire contract a test could currently observe. Deferred to the future "dashboard endpoint coverage" sweep.

Impact if unfixed: zero on the existing 44 tests; informational coverage debt only.

---
*Added via Oracle Learn*
