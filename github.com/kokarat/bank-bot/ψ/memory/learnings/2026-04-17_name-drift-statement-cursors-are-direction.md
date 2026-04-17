---
title: drift — statement cursors are direction-aware, not a single lastKnownDateBKK
tags: [technical-writer, repo:bank-bot, current, statement, drift]
created: 2026-04-17
source: docs/current-system.md §8 DRIFT-9 @ 95dbb70
project: github.com/kokarat/bank-bot
---

# drift — statement cursors are direction-aware, not a single lastKnownDateBKK

CLAUDE.md describes statement-scrape stop logic using a single `lastKnownDateBKK`. At 95dbb70 both SCB and KTB share `core/cursor.js` which tracks `{lastInDateBKK, lastOutDateBKK}` per direction. A row's cursor is chosen from its own direction; pagination stops only when both directions have seen boundary rows (via `hasAnyCursor`). The bug that spawned this module: an OUT withdrawal at 08:15 used to push the cursor to 08:15 and silently drop unscraped IN deposits at 07:36-07:42 — PR #12.

## Evidence at 95dbb70

- `core/cursor.js:30-39` — `normalizeCursor` accepts either a number (legacy, applied to both directions) or `{lastInDateBKK, lastOutDateBKK}`.
- `core/cursor.js:59-66` — `isTransactionNew(txn, cursor)` picks `txn.direction === 'out' ? cursor.lastOutDateBKK : cursor.lastInDateBKK`.
- `banks/scb/statement.js:108-120` and `banks/ktb/statement.js:797-809` both import and use the shared helpers.
- Backend endpoint `GET /api/v1/bot/bank-statements/last/:account_number` returns both cursors (core/api.js:162-164).

## How to apply

- Anyone documenting statement scraping in this repo must use "per-direction cursors" language, not "last known transaction timestamp".
- When KBANK/BBL adapters land they MUST import from `core/cursor.js` — do not re-invent a single-cursor comparison.
- CLAUDE.md "Bank Statement Scraping" section needs updating (Workflow 4 fix).

---
*Added via Oracle Learn*
