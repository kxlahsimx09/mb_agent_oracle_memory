---
title: pattern — viewerLoop self-recovers from maker-initiated browser recycle (page-evaluate probe + ensureBrowser + getSession)
tags: [technical-writer, repo:bank-bot, current, scb, viewer, browser-recycle, session-reuse, incident, resilience]
created: 2026-04-19
source: banks/scb + app.js@b423eca, PR #74 / commit 2d8ec5e
project: github.com/kokarat/bank-bot
---

# pattern — viewerLoop self-recovers from maker-initiated browser recycle

## The claim

At bank-bot `b423eca`, every `viewerLoop` iteration probes liveness at the top of the tick:

```js
let pageAlive = false;
try { pageAlive = await viewer.page.evaluate(() => true); } catch {}
if (!pageAlive || !browser) {
  log.info('[Viewer] Browser was recycled — re-creating viewer session');
  loginDone = false;
  await ensureBrowser();
  const newViewer = await getSession('viewer');
  viewer.page = newViewer.page;
  viewer.context = newViewer.context;
}
```
Source: `app.js:1098-1108@b423eca`.

## Why the probe is necessary

The maker calls `resetBrowser()` every `MAX_ITEMS_BEFORE_RECYCLE` items (default 20). That closes the **shared** `browser` singleton. The viewer is a fire-and-forget task launched from `init()` with its own `viewer.page` reference; it does not go through `processBatch`'s `ensureBrowser()` wrapper. Pre-fix, the viewer held a stale reference and every subsequent `ensureLoggedIn` threw at 30 s cadence. Incident: bot `5014674469` logged 8,472 errors over 99 recycles before the fix landed.

## The twin fix in the login-failure reset branch

The same `await ensureBrowser();` was added at `app.js:1121@b423eca` **before** `getSession('viewer')` inside the login-failure reset branch (after `MAX_LOGIN_FAILURES_BEFORE_RESET`). Motivation identical: if the main loop already reset the browser, `getSession` would crash with "Cannot read properties of null (reading 'newContext')". Pattern mirrors the earlier maintenance-exit branch at `app.js:1090`.

## How to apply

- Any fire-and-forget loop that holds a reference to the shared `browser` singleton MUST probe liveness (`page.evaluate(() => true)` + `!browser` check) before using its page. The probe is cheap (single RPC) and decouples the loop from the maker's recycle cadence.
- `loginDone = false` must be reset when rebuilding the session — otherwise the "Bot active" status report is skipped on the subsequent successful login.
- Mirror this pattern if a KTB viewer role is ever added, or when introducing a second background loop on any new bank adapter.

## Related

- CLAUDE.md §"app.js Flow — SCB Dual-Control" still describes only maker + approver browsers — viewer role tracked as DRIFT-6. This pattern does not resolve the drift; it only documents the recovery mechanism for an already-existing third loop.

---
*Added via Oracle Learn*
