---
title: gotcha — anti-detection ranges and viewport are load-bearing, not tuneable
tags: [technical-writer, repo:bank-bot, current, security, gotcha]
created: 2026-04-17
source: core/util.js:57-69 + core/browser.js:7-12 @ 95dbb70
project: github.com/kokarat/bank-bot
---

# gotcha — anti-detection ranges and viewport are load-bearing, not tuneable

The bot's anti-detection is a handful of small constants that directly impact whether banks classify the session as a bot. AGENTS.md §9 forbids silent changes; this learning records the exact values and the incidents that anchor them so future agents can't lose the context when editing.

## The values at 95dbb70

- `humanDelay(min=800, max=2000)` — every inter-click pause. Jitter is `Math.random() * (max - min + 1) + min`. (`core/util.js:57-60`).
- `humanType(locator, text, delayPerChar=100)` — per-character typing with `delay: delayPerChar + Math.random() * 50` jitter. (`core/util.js:62-69`).
- Viewport fixed at 1920×1080 in both headed and headless modes. Not overridable by env. (`core/browser.js:12`).
- `optimizePage` disables all CSS animations/transitions (stability; not anti-detection). Set `BLOCK_RESOURCES=false` to un-block images/fonts/media for debug runs. (`core/browser.js:63-85`).

## Why the viewport is 1920×1080 specifically

At 1024×768 SCB's transfer review page hid `ข้ามไปหน้าตรวจสอบข้อมูล` / Submit buttons below the fold. This was the 2026-04-11 incident where items rotted in `processing` status until manual intervention. The fix is called out in `core/browser.js:7-12` with date and rationale.

## How to apply

- Do NOT treat `humanDelay` as a latency knob. Every reduction is a measurable detectability increase — banks notice.
- When adding a new bank, reuse these helpers; don't invent per-bank delays.
- When tuning for a new portal that needs a different viewport, document the reason at the call site like `core/browser.js` does — make it re-discoverable.
- Screenshot retention is a related constant (`KEEP_DAYS=7` in `core/util.js:4`); undocumented in CLAUDE.md but benign.

---
*Added via Oracle Learn*
