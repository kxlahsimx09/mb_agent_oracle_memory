---
title: app.js `processSingleTransfer` now has a three-arm result-status switch that mir
tags: [technical-writer, repo:bank-bot, current, ktb, app.js, processSingleTransfer, waiting-to-review, safety, pattern]
created: 2026-04-19
source: app.js:1639-1651,1710-1720@b5ed22c
project: github.com/kokarat/bank-bot
---

# app.js `processSingleTransfer` now has a three-arm result-status switch that mir

app.js `processSingleTransfer` now has a three-arm result-status switch that mirrors the maker-branch escalation from §2.4: `success → safeMarkSuccess`, `waiting_to_review → safeMarkWaitingToReview`, else → `safeMarkFailed`. Both the all-items-in-one-batch branch (batchTransferFlow return path, ~line 1640) and the one-by-one fallback (transferFlow per item, ~line 1710) now have the `waiting_to_review` middle arm. Before PR #84 (3359d08, 2026-04-20), app.js had only `success` vs else; any `waiting_to_review` status the KTB adapter returned (from `KTB_POST_OTP` carve-out) silently fell through to `safeMarkFailed`, defeating the adapter-level safety. The contract is now: KTB adapter owns the three-way return shape; app.js dispatches all three. Applies only to single-transfer banks — dual-control (SCB) path has its own escalation logic inside startDualControlLoops.

---
*Added via Oracle Learn*
