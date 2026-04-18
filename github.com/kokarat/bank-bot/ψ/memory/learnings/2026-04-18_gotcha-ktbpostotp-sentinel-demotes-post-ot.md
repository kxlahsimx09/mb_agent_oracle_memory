---
title: # gotcha — `KTB_POST_OTP` sentinel demotes post-OTP failures to `waiting_to_revi
tags: [technical-writer, repo:bank-bot, current, ktb, transfer, otp, gotcha, safety, post-otp]
created: 2026-04-18
source: W1 baseline @ 7d4b50e (PR #60, commit 0789b4b)
project: github.com/kokarat/bank-bot
---

# # gotcha — `KTB_POST_OTP` sentinel demotes post-OTP failures to `waiting_to_revi

# gotcha — `KTB_POST_OTP` sentinel demotes post-OTP failures to `waiting_to_review`

**Tags**: technical-writer, repo:bank-bot, current, ktb, transfer, otp, gotcha, safety

**What**: KTB's single-transfer flow now throws a dedicated error `KTB_POST_OTP` (literal string sentinel) from `banks/ktb/transfer.js` L842-844 when the OTP confirm step has already been submitted but the subsequent success verification fails or errors.

```js
throw new Error('KTB_POST_OTP');  // or similar literal
```

**Consumer**: `banks/ktb/transfer.js:batchTransferFlow()` L157-167 inspects the thrown error message; if it matches the sentinel, the item's status is branched:

```js
const isPostOTP = /KTB_POST_OTP/.test(err.message);
const statusForPending = isPostOTP ? 'waiting_to_review' : 'failed';
```

**Why it matters**: KTB's OTP confirm is not transactional from the bot's perspective — after the confirm button is clicked, the bank may have already moved the funds even if the bot's page crashes, times out, or fails to read the success panel. A naive `markFailed` on any exception would invite the dispatcher to retry a transfer that already succeeded. The sentinel communicates "the failure happened *after* the point of no return" so the caller knows to pause rather than retry.

**Interaction**: This is the KTB-side mirror of the SCB approver's three `waiting_to_review` paths (L593-603, L665-680 in `banks/scb/approver.js`). Both banks adopt the same safety invariant: post-OTP ambiguity → human review, never auto-retry.

**How to apply**: When wrapping any submit-then-verify flow, distinguish "failed before submit" (safe to retry) from "submitted, verification unclear" (not safe to retry). A literal-string sentinel in the error message is a blunt but clear way to cross a throw/catch boundary with state.

**Source**: docs/current-system.md §3.2.3 + PR #59 @ 7d4b50e.

---
*Added via Oracle Learn*
