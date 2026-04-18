---
title: Statement cursor comparison is date-only (YYYYMMDD), not full timestamp (eab43bc
tags: [technical-writer, repo:bank-bot, current, scb, ktb, statement, cursor, drift-adjacent]
created: 2026-04-18
source: core/cursor.js:59-73@2774dab
project: github.com/kokarat/bank-bot
---

# Statement cursor comparison is date-only (YYYYMMDD), not full timestamp (eab43bc

Statement cursor comparison is date-only (YYYYMMDD), not full timestamp (eab43bc, 2026-04-18)

**Why:** SCB's intraday statement tab occasionally renders a previous-day transaction with a late timestamp (e.g. 23:53 on 17/04) under today's (18/04) page. With the old full-`YYYYMMDDHHMM` compare, that one row pushed the IN cursor to `202604182353`, and every morning row (10:xx) was then dropped as "older than cursor". Bot 4352312351 lost 6 PromptPay deposits this way on 2026-04-18.

**How to apply:**
- Any doc/code describing the cursor compare must say *same-day rows are always kept*, not *strictly greater timestamp*. The second phrasing was only correct for the old logic.
- The cost is that same-day rows already stored get re-posted to `POST /bot/bank-statements`; the mobiz-side dedup check (existing contract) absorbs them. If that dedup is ever loosened on the backend side, the bot will start over-reporting — cross-repo concern, worth a heads-up to `pg-writer-oracle`.
- When KBANK/BBL adapters land, they must not introduce their own cursor compare — everything goes through `core/cursor.js`.

Evidence at `2774dab`:
- `core/cursor.js:59-73@2774dab` — `isTransactionNew` computes `txnDay = Math.floor(txnDate / 10000)` and `refDay = Math.floor(ref / 10000)`, returns true when `txnDay >= refDay`.
- Incident: bot 4352312351 on 2026-04-18 — "PromptPay +300 at 23:53 pushed cursor ahead → 6 new deposits (10:34-10:39) skipped."
- Commit chain: `d756b5e` (first attempt: compare day first, then full time within same day) → `eab43bc` (second attempt: day-only, backend handles dedup). The simpler version shipped.

**Related drift:** CLAUDE.md §"Bank Statement Scraping" still describes a single `lastKnownDateBKK` (tracked as DRIFT-9 since the prior W1 at `7d4b50e`). This learning does not re-open or resolve that drift — just re-confirms it is still open and now compounds (CLAUDE.md has neither per-direction cursors nor date-only semantics).

---
*Added via Oracle Learn*
