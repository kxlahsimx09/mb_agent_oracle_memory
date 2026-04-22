---
title: bank-bot `processSingleTransfer` now calls `safeMarkSuccess(id, '', result.bankR
tags: [technical-writer, repo:bank-bot, current, ktb, safeMarkSuccess, bankRef, slot-fix, track-commit]
created: 2026-04-22
source: app.js:1643,1712@5cb8cb3 + core/api.js:72-77@5cb8cb3; PR #72 / e3db48a fixes #71
project: github.com/kokarat/bank-bot
---

# bank-bot `processSingleTransfer` now calls `safeMarkSuccess(id, '', result.bankR

bank-bot `processSingleTransfer` now calls `safeMarkSuccess(id, '', result.bankRef || '')` — bank reference goes in slot 3, not slot 2. `core/api.js:markSuccess(itemId, bankTransactionId, bankReference)` posts slot 2 as `bank_transaction_id` and slot 3 as `bank_reference`. Before PR #72 / e3db48a (2026-04-19), both KTB call sites in app.js (batch dispatcher + per-item single loop) passed `bankRef` in slot 2, so KTB's bank-reference string was being stored in the gateway's `bank_transaction_id` column and slot 3 was always empty. Only KTB was affected; SCB's dual-control maker records its TRANSFER id via the separate `setTransactionID` endpoint, not through the success call. No data migration was needed — KTB never writes a distinct `bank_transaction_id`, so the displaced value had no correct slot-2 content to compete with.

---
*Added via Oracle Learn*
