---
title: W1 thirteenth-baseline AMEND — f89e235..20b6fa3 cumulative — 0 status flips, 0 r
tags: [tester, repo:mobiz-payment-gateway, current, w1-thirteenth-baseline, amend, no-flip-cadence, matcher, link-checking-deposit, deposit-fraud-fail-closed, neutral-pass]
created: 2026-05-02
source: docs/test-index.md@20b6fa3 + services/transactionMatcher.go:126-138 + linkCheckingDeposit:340-475 + controllers/DepositController.go (account_number filter) + controllers/WalletChangeLogController.go (entity_id filter)
project: github.com/kokarat/mobiz-payment-gateway
---

# W1 thirteenth-baseline AMEND — f89e235..20b6fa3 cumulative — 0 status flips, 0 r

W1 thirteenth-baseline AMEND — f89e235..20b6fa3 cumulative — 0 status flips, 0 regressions

What this pass added on top of PR #379 (cbb4957, baseline a7279ed): four new commits absorbed via merge --no-edit origin/main into feat/tester-validate-2026-05-03 — `c3fd5c7` (#378 WalletChangeLog entity_id filter), `5cdd0b9` (#382 Deposits account_number filter), `88c7810` (#383 custom_bank_account_number index script), `20b6fa3` (#384 Matcher linkCheckingDeposit step). Static check across all 47 tests: zero status flips, zero regressions, zero existing rows demoted.

Why each is NEUTRAL:

- `20b6fa3` (#384 Matcher) — inserts `linkCheckingDeposit` between `matchDepositKTB/SCB` (Step 1) and `linkPaidDeposit` fallback (Step 2b). New step scopes by `system_bank_account_number + amount + status="checking" + is_matched != true`, requires full-account regex `(\d{3})-(\d{7,15})` OR last4 match against statement's `dest_account_last4`/`source_account_no`/`description [xX]\d{4}`, picks closest-time candidate by `created_date_bkk/100` (truncated to YYYYMMDDHHMM). Refuses to guess on missing source identity. Wallet/callback/deposit.status untouched. **Auto-match path tests** (`test-deposit-flow.sh`, `test-deposit-collision*.sh`, `test-deposit-fifo*.sh`, `test-deposit-burst-*.sh`, `test-mixed-flow.sh`, `test-deposit-ktb.sh`, `test-multi-bank-stress*.sh`) — at statement arrival deposit is `status=pending`, so `matchDepositKTB/SCB` matches first; new step never reached. **`test-deposit-upload-slip.sh`** — uploads slip, asserts `status=checking`, but does NOT post a bank_statement → matcher never invoked against checking deposit. **`test-deposit-slip-fraud.sh`** — directly seeds bank_statements via mongosh `insertOne` with `match_status="matched"` already populated, bypassing `MatchNewStatements` entirely.

- `5cdd0b9` (#382 Deposits filter) + `88c7810` (#383 index) — new `?account_number=` query param on `GET /api/v1/deposits` (≥ 3 digits, anchored prefix on `custom_bank_account_number`), backed by new sparse btree index. `grep -lE "account_number=|/api/v1/deposits\\?[^\"]*account_number" integration-tests/test-*.sh` returns zero hits. Unfiltered list contract unchanged.

- `c3fd5c7` (#378 WalletChangeLog filter) — new `?entity_id=` query param on `GET /api/v1/wallet-change-logs`. Malformed ObjectId rejected quietly. `grep -lE "entity_id=|wallet-change-logs" integration-tests/test-*.sh` returns zero hits. No test reads `/wallet-change-logs` at all.

Why this is NOT just a duplicate of PR #379's eleventh-baseline AMEND pattern: the matcher fix in `20b6fa3` is the first behaviour-shifting commit in the cumulative range that closes a documented production false-positive (DEP17777364940AC8L3 + DEP1777733674IBGAQO, 3 พ.ค. 2026). Other commits since `f89e235` were perf, audit-trail, or filter-additive; this one rewires `matchDeposit` flow control. Still NEUTRAL for tests because the auto-match path (status=pending) is preserved verbatim, the new step only fires when a candidate at `status=checking` exists (no current test data shape produces one), and the slip-fraud E2E test pre-seeds matched statements rather than driving the matcher.

New coverage gaps added (3 — see docs/test-coverage-gaps.md):
- 🟢 Matcher `linkCheckingDeposit` step (regression candidate for the false-positive race fixed by #384)
- 🟢 `GET /api/v1/deposits?account_number=` (sparse-index-backed prefix filter)
- WalletChangeLog `entity_id=` rolled into existing `wallet/wallet-change-logs` gaps (same surface)

Status breakdown unchanged from PR #379 base: VALID=42, STALE=1, WRONG-SETUP=0, FLAKY=0, SUPERSEDED=2, ON_HOLD=2, UNKNOWN=0.

Related: 2026-05-01_w1-eleventh-baseline-amend-ffc33cba463f51-cumu (precedent), 2026-05-01_w1-eleventh-baseline-2026-05-02-gmt7-ffc33cb (sibling pattern).

---
*Added via Oracle Learn*
