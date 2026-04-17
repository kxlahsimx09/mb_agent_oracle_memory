---
title: drift — KTB session death is a real, silently-surfaced class of failure not in CLAUDE.md
tags: [technical-writer, repo:bank-bot, current, ktb, session-reuse, statement, drift]
created: 2026-04-17
source: docs/current-system.md §8 DRIFT-14 @ 95dbb70
project: github.com/kokarat/bank-bot
---

# drift — KTB session death is a real, silently-surfaced class of failure not in CLAUDE.md

At 95dbb70 KTB has three hardened death signals not described in CLAUDE.md: (1) REST API returning 500 N times in a row (N=SESSION_DEAD_THRESHOLD, default 5 via env KTB_API_FAIL_THRESHOLD), (2) keepSessionAlive unable to return to dashboard after 3 rotation attempts, (3) profile button visible but dashboard API rejecting requests. Any of these triggers `KTB_SESSION_DEAD` sentinel which app.js catches to reset the browser and force a fresh login.

## Why the bot needs its own death signal

KTB's standard checkSession heuristic ("profile button visible") returns `logged_in` even when the server-side Angular session has silently expired. Production incident 0170681475 (2026-04-11) burned 24 hours of cycles looping on a page that looked logged in. Incidents 0170679675/0170689786 (2026-04-13) repeated the pattern when the bot wedged on the detail page.

## Signals at 95dbb70

**Signal 1 — Dashboard REST 500 burst (`banks/ktb/statement.js:19-32`):**
```js
let consecutiveDashboardApiFailures = 0;
const SESSION_DEAD_THRESHOLD = parseInt(process.env.KTB_API_FAIL_THRESHOLD || '5', 10);
function isSessionLikelyDead() {
  return consecutiveDashboardApiFailures >= SESSION_DEAD_THRESHOLD;
}
```
Every successful `/v1/account/dashboard` resets to 0.

**Signal 2 — keepSessionAlive wedged (`banks/ktb/index.js:285-302`):**
- After clicking the account card, if the bot cannot click back to the dashboard in 3 retries (sidebar at `(30, 85)` → `แดชบอร์ด` link → verify card visible), throw `KTB_SESSION_DEAD`.

**Signal 3 — scrapeStatement explicit throw (`banks/ktb/index.js:165-185`):**
- If `scrapeStatementAPI` returns null AND `isSessionLikelyDead()` is true → clearStorage('ktb-transfer') + throw sentinel.

## Downstream handling

- `app.js` idle branch (line 2077) catches `e?.code === 'KTB_SESSION_DEAD'`, runs `resetBrowser()`, skips the rest of the cycle.
- `app.js` pre-claim API health check (line 1965-1980) calls `bankModule.checkApiHealth(page)` specifically to catch a dead session BEFORE any items are claimed — this is the difference between losing 5 items to failed state and keeping them untouched in the queue for the next healthy cycle.

## How to apply

- Any change to `banks/ktb/statement.js` that touches the failure counter must preserve the "reset to 0 on success" path.
- `KTB_API_FAIL_THRESHOLD` is tuneable per-droplet if a particular account has a flakier network; never lower it below 2 (one transient 500 is normal, five in a row is not).
- SCB has no equivalent signal because its statement scrape is purely DOM-based (no REST layer to rate-limit).

---
*Added via Oracle Learn*
