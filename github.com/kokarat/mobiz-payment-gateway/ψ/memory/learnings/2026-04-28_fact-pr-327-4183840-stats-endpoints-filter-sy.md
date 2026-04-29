---
title: FACT — PR #327 (4183840) Stats endpoints filter sync — NEUTRAL for all 43 integr
tags: [tester, repo:mobiz-payment-gateway, current, coverage-gap, stats-consistency, neutral-impact, w1-seventh-baseline]
created: 2026-04-28
source: controllers/BankStatementController.go + controllers/WithdrawalQueueController.go @ 4183840 (PR #327, 2026-04-29) + integration-tests/test-payout-flow.sh:324, test-payout-ktb.sh:356, test-burst-payout.sh:319
project: github.com/kokarat/mobiz-payment-gateway
---

# FACT — PR #327 (4183840) Stats endpoints filter sync — NEUTRAL for all 43 integr

FACT — PR #327 (4183840) Stats endpoints filter sync — NEUTRAL for all 43 integration tests

What's wrong: Nothing wrong, recording the impact assessment for future W1 sessions. PR #327 refactors GET /api/v1/bank-statements/stats and GET /api/v1/withdrawal-queue/stats to honor every filter the corresponding list endpoint supports (search, direction, match_status, transaction_code, system_bank_id, amount{,_min,_max} on bank-statements; system_bank_id, search on withdrawal-queue). Default behavior (no query params) is unchanged: summary.{pending,processing,success,...} shape preserved, global counts when no filter applied.

Why this is wrong (no impact): Three integration tests call /api/v1/withdrawal-queue/stats (test-payout-flow.sh:324, test-payout-ktb.sh:356, test-burst-payout.sh:319). All three call the endpoint without query params and parse summary.{pending,processing,success} for log-info display only — no assertions. No test calls /api/v1/bank-statements/stats. PR #327 is purely additive on the wire contract.

Minimal fix (proposed, not applied): Not a fix — a coverage gap. The very disagreement PR #327 fixed (filtered stats counts != filtered list counts) is the kind of regression a tripwire test would catch on a future column addition. Filed as docs/test-coverage-gaps.md row "stats-consistency | Stats endpoints filter consistency with list endpoints (4183840)".

Impact if unfixed: Without the tripwire, a future PR that adds a new filter to the list builder but forgets to mirror it in the stats builder will reintroduce the same bug silently. PR #327 specifically called this out by extracting buildBankStatementFilter() to share between list and stats — a tripwire would back that extraction up.

Related: 2026-04-25 W1 fifth baseline already filed similar PR #308 settlements tripwire gap (not deleted, restored in this baseline after W1 sixth's rewrite dropped it).

---
*Added via Oracle Learn*
