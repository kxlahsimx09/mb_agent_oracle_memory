---
title: W9 bank-bot 5cb8cb3..338070b: flow:ktb-login-with-otp Step 6 (three-field humanT
tags: [technical-writer, repo:bank-bot, current, drift, flow-drift, flow:ktb-login-with-otp, step:6, ktb, login, humantype]
created: 2026-04-22
source: docs/flows/ktb-login-with-otp.md
project: github.com/kokarat/bank-bot
---

# W9 bank-bot 5cb8cb3..338070b: flow:ktb-login-with-otp Step 6 (three-field humanT

W9 bank-bot 5cb8cb3..338070b: flow:ktb-login-with-otp Step 6 (three-field humanType) drifted at 338070b. Live code now clears each field with field.fill('') before humanType (banks/ktb/login.js:429-458@338070b) to prevent autofill or retained-value doubling — observed live as company code submitted as SSKBA08526SSKBA08526. Flow doc step description still says "humanType via core/util.js, 100ms per-char jitter, 500-1000ms humanDelay between fields" with no mention of the clear step. Pointer left at @1cf5e14 with [DRIFT-field-fill-before-humantype] marker per W9 spec; queued for W4 sweep.

---
*Added via Oracle Learn*
