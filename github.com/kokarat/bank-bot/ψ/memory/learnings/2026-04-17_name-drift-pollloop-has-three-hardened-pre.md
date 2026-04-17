---
title: drift — pollLoop has three hardened pre-claim gates and a viewer role that CLAUDE.md omits
tags: [technical-writer, repo:bank-bot, current, drift]
created: 2026-04-17
source: docs/current-system.md §8 DRIFT-5, DRIFT-6, DRIFT-7 @ 95dbb70
project: github.com/kokarat/bank-bot
---

# drift — pollLoop has three hardened pre-claim gates and a viewer role that CLAUDE.md omits

At 95dbb70 app.js:1903-2129 has matured significantly past the "poll → claim → process" sketch in CLAUDE.md. Three gates run before each claim: (1) maintenance window check with auto-logout+reset+status='maintenance', (2) pre-claim API health check (KTB-only, verifies server-side session), (3) pre-claim login verification (3-strike reset counter). Separately, init() spawns a third `viewer` browser session when `credentials.viewer` is configured. None of this is in CLAUDE.md.

## Pre-claim gates (app.js:1913-2050)

**Gate 1 — Maintenance window (lines 1929-1949):**
- `config.maintenance_time` is a string like `"18:00-08:00"` parsed by `isInMaintenanceWindow()` (app.js:103-124) in Bangkok time. Overnight ranges are supported.
- On entry: logout current role → resetBrowser → clearStorage → reportStatus('maintenance').
- Config is refreshed every 5 min inside pollLoop so operators can change the window without restarting the bot.

**Gate 2 — Pre-claim API health (lines 1965-1980, KTB only):**
- Calls `bankModule.checkApiHealth(page)`; SCB default is no-op `true`, KTB overrides with a `getAccountSummaryAPI` probe (banks/ktb/index.js:101-119).
- On failure: clear storage, resetBrowser, skip this cycle — items stay in pending.

**Gate 3 — Pre-claim login verification (lines 1993-2036):**
- `bankModule.ensureLoggedIn(...)`; returning false increments `consecutiveLoginFailures`.
- Hard threshold `MAX_LOGIN_FAILURES_BEFORE_RESET = 3` → resetBrowser + counter clear.
- Reports status='online' only after this gate passes (so dispatcher does not assign items to a bot that hasn't actually logged in).

## Viewer role (app.js:200-213, viewerLoop at app.js:1022)

- Only runs when `config.credentials?.viewer?.length > 0` AND `bankModule.isDualControl()` is true.
- Logged in and started at init() as a fire-and-forget promise — runs in its own browser session for the entire bot lifetime.
- When running, the maker idle-branch skips statement+balance scraping (line 617 in makerLoop) because viewer handles them.
- Three browser sessions exist simultaneously: maker + approver + viewer. Default storage keys are `scb-maker`, `scb-approver`, `scb-viewer`.

## How to apply

- When CLAUDE.md says "Bot claims items via POST /queue/claim", know that there are three gates in front of that call.
- When someone wonders why the bot reports "offline" at start despite being a new process — it's intentional, Gate 3 flips to "online" only after real login.
- When writing docs for a future target bot, replicate these gates; removing any of them reintroduces production incidents documented inline in the source.

---
*Added via Oracle Learn*
