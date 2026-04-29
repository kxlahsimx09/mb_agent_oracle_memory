---
title: Cross-repo sync 2026-04-27: `services/transactionMatcher.go` (mobiz commit `b318
tags: [technical-writer, repo:mobiz-payment-gateway, current, matcher, deposit, cross-repo-sync, transaction-date, bank-statement]
created: 2026-04-27
source: services/transactionMatcher.go:586-609@b31866f + helpers/utilty.go@b31866f
project: github.com/kokarat/mobiz-payment-gateway
---

# Cross-repo sync 2026-04-27: `services/transactionMatcher.go` (mobiz commit `b318

Cross-repo sync 2026-04-27: `services/transactionMatcher.go` (mobiz commit `b31866f`) changed `payment_details.transaction_date` semantics — now uses bank-reported time (`stmt.TransactionDateBKK` parsed via `helpers.TimeFromDateTimeBKKInt`) instead of `stmt.ScrapedAt`. This field is the "โอน" timestamp shown in the deposit admin badge vs "Match" timestamp. Before this commit both timestamps were near-identical (0s gap); after, the gap shows real transfer-to-match latency (typically 30-90s for healthy matcher). Fallback to ScrapedAt only when `TransactionDateBKK = 0`. Sibling flow doc `kokarat/bank-bot/docs/flows/deposit-auto-match-from-statement.md` cites `services/transactionMatcher.go:1126` in §Postconditions — that specific citation line (MatchNewStatements trigger) is unaffected, but the finalizeDeposit semantic change should be noted in that doc's §Implementation pointers or §Postconditions. Filed arra_handoff to bot-writer. W2 trace: a4f2d137.

---
*Added via Oracle Learn*
