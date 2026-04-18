---
title: SCB statement pagination continues past empty pages when same-day rows exist (PR
tags: [technical-writer, repo:bank-bot, current, scb, statement, pagination, cursor]
created: 2026-04-18
source: banks/scb/statement.js:118-134@2774dab
project: github.com/kokarat/bank-bot
---

# SCB statement pagination continues past empty pages when same-day rows exist (PR

SCB statement pagination continues past empty pages when same-day rows exist (PR #62 / 8a2ffee)

**Why:** The old page-loop stopped as soon as a page had zero "new" rows under the cursor filter. But SCB interleaves transaction times across pages — a 23:53 row on page 1 causes every 10:xx row on page 2 to be filtered out, and the scraper would then stop on page 2, missing the rest of page 2 entirely. The same-day-retain cursor rule (see `core/cursor.js` learning) is the root behavior change; this statement.js loop update is the *pagination* side of the same fix.

**How to apply:**
- When documenting SCB's statement scrape in §3.1.6 or in any future KBANK/BBL counterpart: the loop stops only when a page yielded zero new rows *and* no row on that page is from the same day as the larger of the two cursors.
- Logic lives at `banks/scb/statement.js:118-134` — future refactors should keep the `cursorDay = max(floor(lastInDateBKK/10000), floor(lastOutDateBKK/10000))` pattern or equivalent.
- The 20-page safety cap is unchanged.

Evidence at `2774dab`:
- `banks/scb/statement.js:118-134@2774dab` — `hasToday` check + `continuing` log line.
- Commit: `8a2ffee` — "Continue scanning pages if same-day transactions exist".

Pairs with the `core/cursor.js` date-only learning dated 2026-04-18. Both are required to fully explain the 4352312351 incident fix.

---
*Added via Oracle Learn*
