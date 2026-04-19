---
title: SCB statement parser drops future-dated rows with 5-minute clock-drift tolerance
tags: [technical-writer, repo:bank-bot, current, scb, statement, future-dated, parser]
created: 2026-04-18
source: banks/scb/statement.js:286-292@146ce63 (commit 3faa83a)
project: github.com/kokarat/bank-bot
---

# SCB statement parser drops future-dated rows with 5-minute clock-drift tolerance

SCB statement parser drops future-dated rows with 5-minute clock-drift tolerance (3faa83a / PR #64, 2026-04-18)

`banks/scb/statement.js:parseTransactions` (lines 286-292 @ 146ce63) computes `nowDateBKK = YYYYMMDDHHMM` from `Asia/Bangkok` wall clock, then skips any parsed row where `transaction_date_bkk > nowDateBKK + 5` with a warning (`[Statement] Skipping future transaction: ...`).

Why: SCB occasionally surfaces rows with timestamps in the future — observed value `23:53` while the current Bangkok time was `09:04`. Unfiltered, such a row pushed the IN/OUT cursor to the bogus future value and silently blocked every subsequent scrape for the rest of the day. The bad DB record was purged separately in the same incident; the in-bot filter is the durable fix so the bot tolerates future SCB bugs of the same shape without human intervention. The tolerance is 5 (meaning +5 of the last two `YYYYMMDDHHMM` digits = +5 minutes, a clock-drift allowance; not an "optional fudge", the `+5` protects against trivial NTP skew on the droplet).

How to apply: when documenting SCB statement scraping, the skip-future guard is post-parse and pre-cursor-filter — it runs inside `parseTransactions`, so it protects both the cursor logic downstream in `scrapeStatement` *and* any raw-page audits using the returned transaction list. Future KBANK/BBL adapters should implement the same guard if their portals exhibit the same failure mode.

---
*Added via Oracle Learn*
