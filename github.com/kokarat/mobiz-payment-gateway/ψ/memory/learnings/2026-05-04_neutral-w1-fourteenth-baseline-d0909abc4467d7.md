---
title: NEUTRAL — W1 fourteenth baseline (d0909ab..c4467d7) — PR #391 perf bundle is obs
tags: [tester, repo:mobiz-payment-gateway, current, w1-fourteenth-baseline, no-op, perf, neutral, withdrawal-queue, bank-statements, redis-cache]
created: 2026-05-04
source: controllers/BankStatementController.go + controllers/SystemBankController.go + controllers/WithdrawalQueueController.go + scheduler/withdrawal_dispatcher.go + scripts/create_withdrawal_queue_payout_match_indexes.go @ c4467d7
project: github.com/kokarat/mobiz-payment-gateway
---

# NEUTRAL — W1 fourteenth baseline (d0909ab..c4467d7) — PR #391 perf bundle is obs

NEUTRAL — W1 fourteenth baseline (d0909ab..c4467d7) — PR #391 perf bundle is observable only as latency, not as contract change.

What's wrong: nothing — this is a no-flip pass. The single production-surface commit in range (`c4467d7`, PR #391) bundles 7 sub-fixes addressing the 4 พ.ค. 2026 14:44 + 14:53 BKK slow logs: (A+E) two new compound indexes on `withdrawal_queue` for the payout-matcher hot path via `scripts/create_withdrawal_queue_payout_match_indexes.go`; (B) `WithdrawalQueueController.GetBanks` switched `$ne:NilObjectID` → `$gt:NilObjectID` (index-eligible AND excludes 708 production orphan rows; 30% faster, same row set); (C) dispatcher `backfillBankAccountNames` throttled from every-tick to 30-min via new `lastBackfillRun time.Time` field; (D/F/G) three dashboard endpoints cached in Redis (`/bank-statements/accounts` 5min, `/system-banks/daily-stats` 30s, `/bank-statements/stats` 60s with sha256 filter key).

Why this is wrong (i.e., why NEUTRAL is the correct verdict): static `grep -lE "/api/v1/(withdrawal-queue/banks|bank-statements/(stats|accounts)|system-banks/daily-stats)" integration-tests/test-*.sh` returns zero hits. None of the four cached/touched endpoints are exercised by any of the 48 tests. The two new payout-matcher indexes accelerate `services/transactionMatcher.go::matchPayout` for every payout test that posts a bank statement, but the matcher returns the same row set faster — no contract change a test can observe. The dispatcher throttle changes only the scan frequency, not which rows get backfilled. The `$gt:NilObjectID` rewrite is parity-verified at 102,762 rows on production.

Minimal fix (proposed, not applied): no test patch needed. Four new 🟢 Nice-to-have coverage gaps appended to docs/test-coverage-gaps.md as regression tripwires for future-proofing: (i) `withdrawal-queue/banks` NilObjectID exclusion, (ii) three dashboard cache TTL semantics, (iii) dispatcher 30-min backfill cadence, (iv) matcher-perf index existence.

Impact if unfixed: zero — there is nothing to fix. Logged for cadence + searchability so the next W1 pass can confirm the perf bundle remains observable only as latency.

Related: prior W1 thirteenth baseline (`f89e235..d0909ab`) had the same NEUTRAL shape across 11 production-surface commits — perf hardening + audit-trail enrichment + listing-filter expansion + matcher safety + bank-account ceiling. Pattern: large-volume "perf hardening + dashboard caching" PRs cluster in tester-territory as NEUTRAL-only because integration tests exercise transaction state-machines, not dashboard read paths.

---
*Added via Oracle Learn*
