---
title: pattern — viewerLoop self-recovers from maker-initiated browser recycle (page-ev
tags: [technical-writer, repo:bank-bot, current, scb, viewer, browser-recycle, session-reuse, incident, resilience, pattern, recovered-from-double-wrap]
created: 2026-04-19
source: banks/scb + app.js@b423eca, PR #74 / commit 2d8ec5e — recovered 2026-04-19
project: github.com/kokarat/bank-bot
---

# pattern — viewerLoop self-recovers from maker-initiated browser recycle (page-ev

pattern — viewerLoop self-recovers from maker-initiated browser recycle (page-evaluate probe + ensureBrowser + getSession)

The viewerLoop is a per-bank read-only live-view loop that polls the bank portal for balance + statement snapshots while the maker-side does transfer work in the same browser context. When the maker initiates a browser recycle (e.g. page-crash recovery, MAX_ITEMS_BEFORE_RECYCLE, explicit resetBrowser), the viewer's cached page handle goes stale — any subsequent `page.screenshot`, `page.locator`, etc would throw `TargetClosedError`. Without recovery logic the viewer loop would die permanently on the first recycle and the balance/statement stream would stop until the bot restarted.

The recovery pattern, observed in `app.js:1095-1125@b423eca` (PR #74 / commit `2d8ec5e`):
1. Before each iteration, a cheap `page.evaluate(() => 1)` liveness probe runs inside a try/catch.
2. On probe failure, the viewer calls `ensureBrowser()` (shared lazy-init — returns the current browser or boots one) and then `getSession(bankAccountId)` to get a fresh page bound to the bank session.
3. Loop body then proceeds with the new page handle.

Why `page.evaluate(() => 1)` specifically: it's the cheapest roundtrip that forces the CDP channel to be exercised. A `page.url()` or similar synchronous Playwright call won't detect a closed target until you try to actually use the page; `evaluate` is the canonical "is this still alive?" probe in the Playwright community. Running it pre-interaction rather than post-failure means the recovery is deterministic rather than racing against whatever the viewer was about to do.

The twin `ensureBrowser()` call in the login-failure reset branch (`app.js:1095-1125` also covers the symmetrical case where the login flow caused the reset): both paths converge on the same "rebuild via ensureBrowser + getSession" pattern. Prior to this fix the viewer loop and the recovery branch had divergent implementations and the recovery branch sometimes got a page handle that pointed at the wrong bank account after recycle.

Incident context: before PR #74 (commit `2d8ec5e`) bot `5014674469` logged 8,472 `TargetClosedError` lines in 48 hours because viewerLoop was catching + retrying on the SAME stale page. The fix is load-bearing — removing either the probe or the ensureBrowser call in that block regresses to that failure mode.

Adjacent docs: viewerLoop is referenced from `docs/flows/deposit-auto-match-from-statement.md` (bot-side, landed same day in PR #75) as the upstream scraper that feeds the statement-matcher ingress. The recovery pattern is now assumed invariant in that flow's precondition section.

RECOVERED 2026-04-19 from double-wrap file `2026-04-19_title-pattern-viewerloop-self-recovers-from.md`; supersedes `learning_2026-04-19_title-pattern-viewerloop-self-recovers-from`.

---
*Added via Oracle Learn*
