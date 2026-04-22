---
title: W2 bank-bot 2026-04-22 hotfix: KTB login.js now clears each login field with fie
tags: [technical-writer, repo:bank-bot, current, ktb, login, playwright, humantype, form-retention, w2, hotfix]
created: 2026-04-22
source: banks/ktb/login.js:419-462@338070b
project: github.com/kokarat/bank-bot
---

# W2 bank-bot 2026-04-22 hotfix: KTB login.js now clears each login field with fie

W2 bank-bot 2026-04-22 hotfix: KTB login.js now clears each login field with field.fill('') before humanType(). Without this, humanType (character-by-character with keyboard events) appended into retained form state and produced doubled values — observed 2026-04-22 as company code "SSKBA08526SSKBA08526" caused by browser autofill or stale DOM after the welcome-page click. The clear-first sequence is click → humanDelay(300,600) → fill('') → humanDelay(200,400) → humanType(value, 100). Applied to all three login fields (company_code / username / password). docs/current-system.md §3.2.2 updated + citation bumped banks/ktb/login.js:411-506@7d4b50e → :419-462@338070b. Pattern generalizes: any Playwright automation that uses humanType/pressSequentially against a form with a known retention case must clear first — Playwright codegen emits the same pattern.

---
*Added via Oracle Learn*
