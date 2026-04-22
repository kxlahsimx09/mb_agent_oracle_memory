---
title: W2 bank-bot 2026-04-22 hotfix: KTB silently renamed the username-field placehold
tags: [technical-writer, repo:bank-bot, current, ktb, login, selector, selector-drift, playwright, w2, hotfix]
created: 2026-04-22
source: banks/ktb/selectors.js:14@338070b
project: github.com/kokarat/bank-bot
---

# W2 bank-bot 2026-04-22 hotfix: KTB silently renamed the username-field placehold

W2 bank-bot 2026-04-22 hotfix: KTB silently renamed the username-field placeholder from `ระบุรหัสผู้ใช้งาน` → `ระบุชื่อผู้ใช้งาน` on https://business.krungthai.com/#/login. bank-bot's LOGIN.USERNAME Thai-label was updated in banks/ktb/selectors.js:14 (commit c4e0cf7, PR #96). Impact: getByRole('textbox', { name: LOGIN.USERNAME }).waitFor stalled at 30s; saved storage-ktb-*.json sessions masked the break until session expiry — 8 KTB droplets then stuck in pre-claim-login-failures → browser-recycle loop. docs/current-system.md §3.2.1 updated + citation bumped to @338070b. Historical note retained (label rename) so future readers understand why the old string disappeared from the selectors module.

---
*Added via Oracle Learn*
