---
title: FACT — PR #332 (a8fb64e) Telegram hourly report template redesign + thousand sep
tags: [tester, repo:mobiz-payment-gateway, current, coverage-gap, telegram-report, neutral-impact, w1-eighth-baseline]
created: 2026-04-28
source: scheduler/report_scheduler.go + services/telegramNotify.go @ a8fb64e (PR #332, 2026-04-29) — no integration-tests/test-*.sh reference
project: github.com/kokarat/mobiz-payment-gateway
---

# FACT — PR #332 (a8fb64e) Telegram hourly report template redesign + thousand sep

FACT — PR #332 (a8fb64e) Telegram hourly report template redesign + thousand separators — NEUTRAL for all 43 integration tests (W1 eighth baseline).

What changed: `scheduler/report_scheduler.go` rebuilds the hourly Telegram summary template — a single column-aligned code-fence block per section with comma-thousands counts ("865 Txns | ฿971,611.00"). `services/telegramNotify.go` adds a new `FormatCount(int64)` helper consumed only by the new template. No HTTP route, no scheduler branch other than the report scheduler's own loop, and no struct/wire contract observable to integration tests is touched.

Why this is NEUTRAL for tests: zero `integration-tests/test-*.sh` files reference `report_scheduler`, `telegramNotify`, `hourly`/`HourlyReport`, or any operator-narrative endpoint (verified via `grep -l ... integration-tests/test-*.sh`). The only legacy exports any test path could reach via the auth/login flows (`FormatMoney`, `maskAccountNumber`) are untouched. The change is operator-narrative only.

Coverage gap filed: `telegram-report` 🟢 in `docs/test-coverage-gaps.md` — no test asserts the rendered template (column layout, comma placement, section ordering, totals). Marked 🟢 (informational, not load-bearing) because formatting bugs are operator-visible and self-correcting on the next glance at Telegram.

Impact if unfixed: none for production behavior or integration coverage. The gap is documented for symmetry with the W1 seventh baseline's `stats-consistency` gap (PR #327) so future template overhauls trigger an explicit "still no test" reminder rather than silently expanding the un-asserted surface.

Range covered: cumulative `909d5a3..a8fb64e` (W1 fifth..eighth) via Step 7.A amend extending PR #329. Status counts unchanged: V=36 S=2 W=0 F=0 SUP=1 ON_HOLD=2 UNK=2.

---
*Added via Oracle Learn*
