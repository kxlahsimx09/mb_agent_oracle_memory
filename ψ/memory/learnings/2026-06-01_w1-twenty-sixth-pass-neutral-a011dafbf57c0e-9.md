---
title: W1 twenty-sixth pass NEUTRAL — a011daf..bf57c0e (9 production-surface commits) z
tags: [tester, repo:mobiz-payment-gateway, current, w1, no-op, coverage-gap, finance, payout, withdrawal-queue, pullout, cache, on-hold]
created: 2026-06-01
source: docs/test-index.md (W1 twenty-sixth pass) + git log a011daf..bf57c0e @ bf57c0e
project: github.com/kokarat/mobiz-payment-gateway
---

# W1 twenty-sixth pass NEUTRAL — a011daf..bf57c0e (9 production-surface commits) z

W1 twenty-sixth pass NEUTRAL — a011daf..bf57c0e (9 production-surface commits) zero regression across all 49 integration tests

Validated the integration suite by static analysis at HEAD bf57c0e against prior baseline a011daf. 9 production-surface commits in range, ALL NEUTRAL — net zero status flips. Matrix carries forward verbatim: 44 VALID / 1 STALE (test-settlement-cancel.sh) / 0 WRONG-SETUP / 0 FLAKY / 2 SUPERSEDED / 2 ON_HOLD / 0 UNKNOWN. No test scripts or pattern library changed in range.

Per-commit NEUTRAL reasoning (the durable bit for the next pass):
- #483 db65a15 finance API (Phase 1+2): brand-new /api/v1/finance/** operator surface + finance_* collections + scheduler/finance_settlement_importer.go + additive models/users.go::FinanceAccess (omitempty, defaults false → existing user setup decodes unchanged). 0 test references. NEW UNTESTED SURFACE → filed 🟡 coverage-gap. The settlement auto-importer reads settlements (is_approved:1, status:1, completed_at) so a settlement-domain contract change could silently break income booking — worth a tripwire later.
- #501 5a9d3a2 + #500 3935e57 CachedCount: wraps paginated list total=count(filter) for payout/settlement/topup/deposit-request/deposit in 30s Redis cache (sha256 key, miss→direct CountDocuments). NEUTRAL because no test asserts a cached list total — the only pagination.total read (test-mdr-fee-distribution.sh:855) is on /api/v1/mdr-shared (NOT in the cached set), and the 4 GET /withdrawal-queue?status=pending tests count assigned items in data[] (total/order-independent).
- #499 baa35a9 payout refund-race guard (services/withdrawalQueue.go): status guard on the post-MarkFailed refund goroutine. The 2 ON_HOLD tests (test-payout-auto-reconcile.sh, test-payout-confirm-completed.sh) sit in this exact path but are held on the MarkFailed DOUBLE-CALLBACK root cause — #499 fixes only the refund-after-reconcile wallet-log ordering symptom, so ON_HOLD persists. Both ON_HOLD rows annotated with this.
- #498 444a061 wallet-log stable sort (+_id tie-breaker): only the GET /api/v1/wallet-change-logs list sort. Every test reads wallets_change_logs via direct mongosh findOne/countDocuments, never the HTTP list → unobservable to the suite.
- #494 50108cd admin search: WithdrawalQueueController.ListQueue sort created_at→created_date_bkk (equivalent instant, identical order; tests count not order) + BankStatement PAY/PLO/STL/DTR-prefix→exact matched_request_id seek. No test calls backend GET /api/v1/bank-statements search (statements planted via mock-bank /admin/add-statement + mongosh) → filed 🟢 coverage-gap.
- #502 37a7eab source-side pullout reservation: scheduler.executeTask now uses actual sum via NEW additive pulloutDemand.go::SumPendingPulloutAmountsFromSource instead of count×Max. test-pullout-flow.sh drives execute-now (PullOutTaskController), not the scheduled executeTask, and the 4 helpers it asserts (IsPayoutDest/EffectiveDestBalance/LoadRefillSettings/PickRandomDestCap) are untouched → filed 🟢 coverage-gap.
- #503 d821ec8 bot-restart DO tag-based locator (services/botHostLocator.go): admin Restart-Bot DO path; in-process suite never drives DO/SSH/restart.
- #495 5357f79 slip_review_timeout default 15→5: fallback constant in scheduler/deposit_expiry.go, only used when app_settings key missing; test-deposit-expiry.sh forces expiry via explicit past expires_at mongosh write, never reads the constant.

VALID rows' last-verified bumped a011daf→bf57c0e. New 🟢/🟡 coverage-gap rows appended for #483, #502, #494. PR: feat/tester-validate-2026-06-01 (W1 twenty-sixth pass).

---
*Added via Oracle Learn*
