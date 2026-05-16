---
title: FACT — W1 twenty-second baseline (amended to c7b2232) — PRs #442/#443/#444 all N
tags: [tester, repo:mobiz-payment-gateway, current, neutral-impact, coverage-gap, w1-twenty-second-baseline, rate-limit, maintenance-window]
created: 2026-05-16
source: docs/test-index.md@c7b2232 + helpers/maintenance.go@cf3e02f + helpers/ratelimit.go@33664cd + controllers/DepositRequestController.go,PayoutRequestController.go@c7b2232
project: github.com/kokarat/mobiz-payment-gateway
---

# FACT — W1 twenty-second baseline (amended to c7b2232) — PRs #442/#443/#444 all N

FACT — W1 twenty-second baseline (amended to c7b2232) — PRs #442/#443/#444 all NEUTRAL for all 49 integration tests

What this records: the W1 validate pass for range `f16d602..c7b2232` (3 production-surface commits) found zero status flips. PR #445 was extended via the 7.A amend path from its original baseline `33664cd` (#442+#443) to `c7b2232` after PR #444 merged.

Per-commit static-analysis result:
- #442 `cf3e02f` — `helpers/maintenance.go` splits the global maintenance window into independent `deposit_window`/`payout_window` keys; `GET /api/v1/maintenance/status` gains 8 additive fields. The whole maintenance surface is unexercised by the suite — `grep -ln maintenance integration-tests/test-*.sh` matches only header-comment prose in `test-dispatcher-stale-bot-skip.sh`. NEUTRAL.
- #443 `33664cd` — `helpers/ratelimit.go` adds a `scope` arg so the Redis daily-counter key is namespaced `ratelimit:{clientID}:{scope}:day:{date}` (was shared, causing cross-endpoint starvation). NEUTRAL.
- #444 `c7b2232` — raises the caps on top of #443 (payout per-minute 60→1000, deposit daily 300k→600k) — two one-line constant edits in `DepositRequestController`/`PayoutRequestController`. NEUTRAL.

Why NEUTRAL: the rate-limit helpers are reached only from the client-facing API-key endpoints `/api/v1/deposit-request` + `/api/v1/payout-request`; `grep -lnE "deposit-request|payout-request" integration-tests/test-*.sh` returns 0 hits — no test in the 49-test suite exercises that endpoint family. The `429` matches in `test-deposit-refund.sh` are TOTP step-up lockout (`2FA_LOCKED`), an unrelated auth surface.

Coverage gaps filed (open): 🟡 per-service maintenance windows (#442) — cross-wired window would block the wrong service silently; 🟢 rate-limit counter scope + cap raise (#443+#444) — a revert to the shared key re-introduces the starvation bug. Both regression-tripwire-shaped, no test exists.

Matrix carried forward verbatim: 44 VALID / 1 STALE / 2 SUPERSEDED / 2 ON_HOLD. The 2 ON_HOLD payout tests remain blocked on the MarkFailed double-callback redesign (Oracle thread #2) — unaffected by this range.

---
*Added via Oracle Learn*
