---
title: **Same-amount FIFO matching gap in `transactionMatcher.go` — confirmed reproduce
tags: [matcher, transactionMatcher, fifo, same-amount, deposit, zero-unit-test, current, tester, drift]
created: 2026-05-23
source: orchestrator (thread #217 aggregation) — reported by pg-tester
project: github.com/kokarat/mobiz-payment-gateway
---

# **Same-amount FIFO matching gap in `transactionMatcher.go` — confirmed reproduce

**Same-amount FIFO matching gap in `transactionMatcher.go` — confirmed reproduced (thread #217, 2026-05-23).**

When 3+ deposits share an **identical amount**, the matcher fails to FIFO-disambiguate them: only 0–1 of 3 match, the rest stay PENDING ("collision"). Surfaced by integration tests `test-deposit-fifo-single.sh` / `-fifo-dual.sh` while verifying the idempotency-key test fix (PR #473).

**Why it's real, not test contamination:**
- Reproduces in **clean isolation** (0/3 matched), independent of the idempotency change and independent of suite-ordering contamination.
- The control case `test-deposit-flow.sh` with **distinct** amounts matched 3/3 — so the bot + matcher work; only **same-amount disambiguation** is the broken path.
- Consistent with the known **zero-unit-test blind spot** on `services/transactionMatcher.go`.

**Scope / classification:** pre-existing `#current` production-code fragility in `services/transactionMatcher.go`. NOT caused by Idempotency-v2 (commit `15a54a4`, #392) and NOT a create-gate issue. Distinct from the 2026-05-20 `matchDepositKTB` cross-client wrong-credit defect (`matchByClientScope`/`matchByFIFO`), though both implicate the FIFO/matcher layer.

**Ownership:** the *fix* is a Go production-code change, outside pg-tester's static-analysis/integration-tests auditor remit. There is no `#current` dev role in the active roster — so this surfaces to the human for prioritization. Recommend a focused FIFO same-amount unit test as the regression guard before any matcher change.

Tags: #repo:mobiz-payment-gateway #current #matcher #transactionMatcher #fifo #same-amount #zero-unit-test #gotcha #tester

---
*Added via Oracle Learn*
