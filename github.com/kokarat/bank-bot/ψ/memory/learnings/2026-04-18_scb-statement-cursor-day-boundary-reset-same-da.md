---
title: SCB statement cursor: day-boundary reset + same-day full-timestamp comparison (9
tags: [technical-writer, repo:bank-bot, current, scb, ktb, statement, cursor, day-boundary]
created: 2026-04-18
source: core/cursor.js:59-75@146ce63 (commit 9791647)
project: github.com/kokarat/bank-bot
---

# SCB statement cursor: day-boundary reset + same-day full-timestamp comparison (9

SCB statement cursor: day-boundary reset + same-day full-timestamp comparison (9791647, 2026-04-18)

`core/cursor.js:isTransactionNew` (lines 59-75 @ 146ce63) compares by day first:
- `txnDay = floor(txn.transaction_date_bkk / 10000)`, same for `refDay`.
- `txnDay > refDay` → keep (newer day).
- `txnDay < refDay` → skip (older day).
- Only `txnDay === refDay` falls through to `txnDate >= ref` (full `YYYYMMDDHHMM` compare).

Why: this shape reverts part of the earlier "date-only, keep every same-day row" rule (PRs #62 + eab43bc, same day earlier). That prior fix correctly solved the late-night-cursor-blocks-morning bug (bot 4352312351 / PromptPay 23:53), but it made every 30 s scrape re-scan 8+ pages and depend on backend `POST /bot/bank-statements` dedup to absorb the flood. The day-boundary reset preserves the late-night fix (the 23:53 row now lives in yesterday's day bucket; today's morning rows pass `txnDay > refDay`) while dropping scan cost back to 1-2 pages.

How to apply: KBANK/BBL adapters MUST use `isTransactionNew`/`normalizeCursor`/`hasAnyCursor` from this module — do not re-invent. When writing statement-scraping docs, "day-boundary reset" is the load-bearing phrase, not "keep all same-day" and not "single lastKnownDateBKK".

---
*Added via Oracle Learn*
