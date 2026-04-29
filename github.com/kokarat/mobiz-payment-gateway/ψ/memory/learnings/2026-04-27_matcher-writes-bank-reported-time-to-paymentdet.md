---
title: **Matcher writes bank-reported time to payment_details.transaction_date (mobiz-p
tags: [matcher, deposit, timestamp, transaction_date, bank-statement, TimeFromDateTimeBKKInt]
created: 2026-04-27
source: W2 backlog repair 2026-04-27, commit b31866f #317
project: github.com/kokarat/mobiz-payment-gateway
---

# **Matcher writes bank-reported time to payment_details.transaction_date (mobiz-p

**Matcher writes bank-reported time to payment_details.transaction_date (mobiz-payment-gateway, 2026-04-27)**

Commit `b31866f` #317. `finalizeDeposit` in `services/transactionMatcher.go:586-609` now sets `payment_details.transaction_date` from `stmt.TransactionDateBKK` (the bank's own HH:MM from the statement row), parsed via the new helper `helpers.TimeFromDateTimeBKKInt` (`helpers/utilty.go:115-145`).

Fallback: if `stmt.TransactionDateBKK == 0`, uses `ScrapedAt` (the scraping timestamp) as before.

`TimeFromDateTimeBKKInt(v int64)` converts a `YYYYMMDDHHMM` (12-digit, minute-resolution) or `YYYYMMDDHHMMSS` (14-digit) integer to `time.Time` in Asia/Bangkok. Returns zero-value `time.Time` on unparseable input (display-path semantics — "no time" is the right fallback).

**Before this fix:** `payment_details.transaction_date` was always `ScrapedAt`, which lagged the actual transfer by polling interval (up to ~30 s). Merchants saw the wrong timestamp on matched deposits.

**Cross-repo:** `bank-bot/docs/flows/deposit-auto-match-from-statement.md §Postconditions` references `transactionMatcher.go` — bot-writer notified via arra_handoff to update the postcondition docs.

// verified: services/transactionMatcher.go:586-609@b31866f, helpers/utilty.go:115-145@b31866f

---
*Added via Oracle Learn*
