---
title: pattern — KTB batchTransferFlow's `submitted` flag widens the post-submit carve-
tags: [technical-writer, repo:bank-bot, current, ktb, transfer, submitted-flag, waiting-to-review, post-submit, safety, pattern]
created: 2026-04-19
source: banks/ktb/transfer.js:26,111-113,160-171@b5ed22c; app.js:1640-1651,1710-1720@b5ed22c (PR #84 / 3359d08)
project: github.com/kokarat/bank-bot
---

# pattern — KTB batchTransferFlow's `submitted` flag widens the post-submit carve-

pattern — KTB batchTransferFlow's `submitted` flag widens the post-submit carve-out to ANY error after submitTransfer()

Before PR #84 (3359d08, 2026-04-20), `batchTransferFlow` demoted pending recipients to `waiting_to_review` only when the outer catch saw `e?.code === 'KTB_POST_OTP'` (the sentinel thrown by `handleTransferOTP` when the `ยืนยัน` click itself failed). Any other error after submit — form errors, OTP timeout, navigation breaks — fell to the `failed` branch, which would refund the wallet even though KTB may have already staged the transfer.

New rule: a local `let submitted = false` flag flips to `true` immediately after `submitTransfer()` returns. The catch computes `isPostSubmit = submitted || e?.code === 'KTB_POST_OTP'` and uses it to pick `statusForPending`. Anything thrown between the `ถัดไป → ยืนยัน` click and the final mark-pending-as-success loop is now `waiting_to_review`.

Pre-submit errors (add-recipient failure, KTB_NEED_RELOGIN, KTB_DOM_STUCK with zero recipients) still mark `failed` because the transfer was never handed to KTB. The `KTB_POST_OTP` sentinel is retained for the narrow "OTP click threw" signal, but is now redundant with the `submitted` flag — either one triggers the carve-out.

Paired app.js change (same PR): `processSingleTransfer` grew a new `else if (r.status === 'waiting_to_review')` branch in both the batch-capable path (around line 1640-1651) and the per-item single path (1710-1720). Without this, the KTB-side `waiting_to_review` result would silently fall through to `safeMarkFailed` and refund the wallet.

---
*Added via Oracle Learn*
