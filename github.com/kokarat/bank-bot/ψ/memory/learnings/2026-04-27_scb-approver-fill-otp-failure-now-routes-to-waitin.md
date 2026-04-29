---
title: SCB approver Fill OTP failure now routes to waiting_to_review instead of failed.
tags: [technical-writer, repo:bank-bot, current, scb, approver, otp, waiting-to-review, fill-otp, safety, double-spend]
created: 2026-04-27
source: banks/scb/approver.js:577-590@2b99fb9
project: github.com/kokarat/bank-bot
---

# SCB approver Fill OTP failure now routes to waiting_to_review instead of failed.

SCB approver Fill OTP failure now routes to waiting_to_review instead of failed. When the browser/context is killed after the Approve button was clicked and the email OTP was delivered to SCB, but before the 6 digits were typed into the OTP form, the catch at approver.js:577-590 now returns {status: 'waiting_to_review', error: 'Fill OTP failed (approve was clicked — OTP may still be pending on SCB): ...'}. Rationale: the SCB approver queue already holds the item with a pending OTP; marking failed would refund the wallet while a subsequent approver batch could still match the TRANSFER ID and confirm — double spend. PR #104 (commit 2b99fb9). This extends the post-Approve waiting_to_review invariant to the fill phase, complementing the existing confirm-click and success-popup-timeout cases.

---
*Added via Oracle Learn*
