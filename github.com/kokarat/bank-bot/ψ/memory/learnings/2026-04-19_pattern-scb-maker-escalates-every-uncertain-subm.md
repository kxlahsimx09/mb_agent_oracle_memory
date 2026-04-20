---
title: pattern — SCB maker escalates every uncertain submit to waiting_to_review, never
tags: [technical-writer, repo:bank-bot, current, scb, maker, waiting-to-review, safety, pattern]
created: 2026-04-19
source: banks/scb/maker.js:657-690@b5ed22c; app.js:485-492@b5ed22c (PRs #83 dd5966b + 9525cff + 6ebee00)
project: github.com/kokarat/bank-bot
---

# pattern — SCB maker escalates every uncertain submit to waiting_to_review, never

pattern — SCB maker escalates every uncertain submit to waiting_to_review, never failed

Before PR #83 (dd5966b, 2026-04-19), `makerFlow`'s post-submit error handling had two branches: if `clearStaleRecipients` reported cleanup-succeeded → demote to `failed` (wallet refund safe), cleanup-failed → `waiting_to_review`. This was removed because `clearStaleRecipients` can report false-clean (count=0 while recipients still exist), so a cleanupOk signal is not strong enough to guarantee SCB rejected the transfer.

New rule: whenever `submitFailReason` is set AND zero new TRANSFER IDs were scraped (Skip-to-review or Submit path timed out), every success row is unconditionally demoted to `waiting_to_review` with `<submitFailReason> — needs manual verification`. The missing-TRANSFER-ID case for individual rows is likewise `waiting_to_review` (not the old `failed` with "partial scrape"). Follow-on commit 6ebee00 removed a duplicate status-deciding cleanup block left behind by dd5966b, so `clearStaleRecipients` runs exactly once per failed batch — as a best-effort pre-next-batch cleanup, with its return value ignored for status purposes.

Paired app.js change (PR #83 / 9525cff): the no-bankTransactionId defense in `makerLoop` likewise calls `safeMarkWaitingToReview` instead of `safeMarkFailed`. Same reason: a `status: 'success'` return with a missing TRANSFER ID means submit reached SCB but scrape failed — the transfer may exist and wallet refund via `failed` is unsafe.

Rule of thumb across SCB maker + app.js dispatch: only mark `failed` when the transfer was provably NOT submitted (e.g., `addRecipient` failed before submit). Anything that touched Submit must be `waiting_to_review` until admin verifies against bank statement.

---
*Added via Oracle Learn*
