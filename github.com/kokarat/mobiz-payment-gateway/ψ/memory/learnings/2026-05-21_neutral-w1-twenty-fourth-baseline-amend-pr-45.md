---
title: NEUTRAL — W1 twenty-fourth baseline amend — PR #455 announcements API (2f35356) 
tags: [tester, repo:mobiz-payment-gateway, current, w1-twenty-fourth-baseline, neutral, announcements, track-commit, amend]
created: 2026-05-21
source: controllers/AnnouncementController.go + models/announcement.go + routes/announcement.go + main.go:408 @ 2f35356 (PR #455, 2026-05-22)
project: github.com/kokarat/mobiz-payment-gateway
---

# NEUTRAL — W1 twenty-fourth baseline amend — PR #455 announcements API (2f35356) 

NEUTRAL — W1 twenty-fourth baseline amend — PR #455 announcements API (2f35356) is NEUTRAL for all 49 integration tests

What's wrong: Nothing — this is a NEUTRAL classification, the W1 amend records that PR #455 ("Add announcements API for client news banner", squash-merge 2f35356, 2026-05-22) adds 460 lines of brand-new, green-field surface (new `models/announcement.go`, new `controllers/AnnouncementController.go` with 6 CRUD handlers, new `routes/announcement.go::SetupAnnouncementRoutes` wired into `main.go`, new `announcements` MongoDB collection, new `announcements` SSE channel) and zero of the 49 existing integration tests reference any of it. The PR amends PR #456 from baseline 7e239a5 → 2f35356 (twenty-third → twenty-fourth pass).

Why no test catches this: `grep -lE "announcement|announcements" integration-tests/test-*.sh integration-tests/helpers/*.sh integration-tests/mock-bank/server.js` returns 0 hits. The four surfaces PR #455 touches that are shared with existing code paths — (i) admin gating via `c.Locals("user_type") == "admin"` (new helper `isAnnouncementAdmin`, separate from the existing `isAdminWithForceApprove` in DepositController; the only test mentioning `user_type=admin` — `test-deposit-slip-fraud.sh` — asserts the existing deposit-controller force-approve override path, unchanged here), (ii) SSE channel registry (channel name `announcements` is new; existing SSE tests subscribe to `deposits`/`payouts`/`withdrawal-queue` etc., unaffected by the channel registry growing), (iii) `db.GetReadCollection("announcements")` (read-replica routing from PR #410; the router behavior is unchanged), and (iv) bson tag style (snake_case, consistent with most models, not the `ts_payouts` camelCase outlier flagged in `feedback_payout_state_invariant.md`) — none of these are exercised by the existing 49-test suite. Cross-check confirmed.

Minimal fix (proposed, not applied): No test fix needed — pre-existing 49-test taxonomy carries forward verbatim (44 VALID / 1 STALE / 0 WRONG-SETUP / 0 FLAKY / 2 SUPERSEDED / 2 ON_HOLD). One 🟢 coverage-gap row appended to `docs/test-coverage-gaps.md` (6-phase test architecture: active-window happy path, admin-gate 403, status/expiry/future-publish gate exclusion, priority ordering, SSE event, LIMIT-20 cap). Priority stays 🟢 because announcements are a UI banner with no financial impact and no callback contract — a regression is visible to humans within seconds without payment-flow blast radius.

Impact if unfixed: None. NEUTRAL classification means PR #455 cannot have invalidated any existing test claim. The PR is a pure additive MVP — no schema migration, no existing route reordered, no existing handler modified. The W1 24th amend exists purely to preserve cadence per the wake-prompt directive (validate every baseline range; even no-regression passes get a PR + Telegram + retro to keep the regression-watcher's "Newly-broken since prior baseline:" gate honest at 0).

Related: Twenty-third pass PR #454 (7e239a5, AWS EC2 host locator + deposit-amount floor) and twenty-second pass PR #442/#443/#444 (maintenance windows + rate-limit scope/cap) were also all-NEUTRAL — this is the third consecutive NEUTRAL baseline. Sustained NEUTRAL streaks suggest the production-surface commits in this period are admin-facing / infra-facing / pure-additive rather than touching the deposit-payout-settlement-bot core that the integration suite exercises.

---
*Added via Oracle Learn*
