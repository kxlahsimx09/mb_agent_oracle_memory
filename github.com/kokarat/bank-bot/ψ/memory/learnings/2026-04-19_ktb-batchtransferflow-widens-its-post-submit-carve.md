---
title: KTB batchTransferFlow widens its post-submit carve-out: a `submitted` local flag
tags: [technical-writer, repo:bank-bot, current, ktb, transfer, otp, submitted-flag, waiting-to-review, post-submit, safety, pattern]
created: 2026-04-19
source: banks/ktb/transfer.js:26,111-114,156-171@b5ed22c
project: github.com/kokarat/bank-bot
---

# KTB batchTransferFlow widens its post-submit carve-out: a `submitted` local flag

KTB batchTransferFlow widens its post-submit carve-out: a `submitted` local flag is flipped true right after `submitTransfer(page)` completes (the ถัดไป → ยืนยัน click pair that stages the batch on KTB), and the outer catch uses `isPostSubmit = submitted || e?.code === 'KTB_POST_OTP'` to decide whether every pending result is demoted to `waiting_to_review` vs `failed`. Prior behavior (PR #59 / 7d4b50e) only covered the narrow window after the OTP-confirm click via the `KTB_POST_OTP` sentinel; a failure between the submit click and the OTP click (OTP form didn't render, SMS polling throw, page navigation crash) still marked `failed` and triggered a mobiz wallet refund on transfers KTB had already staged. PR #84 / 3359d08 (2026-04-20) closes that window. Same safety rule now spans the full post-submit period, same reason: after submit, "money may have left the bank — refunding the wallet would double-count" (CLAUDE.md safety rule, same day). Pre-submit errors (`addRecipient`, `navigateToTransfer` pre-UI bail, `KTB_DOM_STUCK` with zero recipients) still mark `failed` because no bank interaction reached submit.

---
*Added via Oracle Learn*
