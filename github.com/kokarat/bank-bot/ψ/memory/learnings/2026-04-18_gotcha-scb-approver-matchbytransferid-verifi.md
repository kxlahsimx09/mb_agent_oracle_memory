---
title: # gotcha — SCB approver `matchByTransferId` verifies amount against maker's task
tags: [technical-writer, repo:bank-bot, current, scb, approver, gotcha, safety, matching]
created: 2026-04-18
source: W1 baseline @ 7d4b50e (PR #60, commit 0789b4b)
project: github.com/kokarat/bank-bot
---

# # gotcha — SCB approver `matchByTransferId` verifies amount against maker's task

# gotcha — SCB approver `matchByTransferId` verifies amount against maker's task

**Tags**: technical-writer, repo:bank-bot, current, scb, approver, gotcha, safety

**What**: When the SCB approver walks the on-page TRANSFER list to match each pending queue item to its row, it no longer trusts TRANSFER ID alone. Since TRANSFER IDs are assigned by the bank and could theoretically collide across an IBFT-merge event, the approver now also verifies that the row's displayed amount matches the queue item's expected amount to within ฿0.01:

```js
if (Math.abs(taskAmount - batchAmount) > 0.01) { /* skip — not a match */ }
```

**Where**: `banks/scb/approver.js:matchByTransferId()` L62-86 @ 7d4b50e.

**Why it matters**: Without the amount guard, a merged batch where two items got the same TRANSFER ID would mark the *first* matching item as success — even if the bank actually debited the amount for the second. The guard means a row with a mismatched amount is treated as "not my item" and the queue item stays in processing (eventually timing out to `waiting_to_review` per the post-OTP guards below).

**Interaction with `waiting_to_review`**: `banks/scb/approver.js` has three distinct paths that now return `waiting_to_review` instead of `failed`:
- L593-603: OTP confirm click succeeds but post-OTP verification times out
- L665-680 (2 paths): post-OTP success-table parse fails, or items with no matching row after OTP

Each path represents "we cannot safely claim success or failure — the bank may have already moved the funds."

**How to apply**: Anywhere you match a bank-side row to a bot-side task by a single identifier, verify at least one secondary field (amount, recipient, reference). Single-key matching is a liability when the bank can collide keys.

**Source**: docs/current-system.md §3.1.4 + PR #58 @ 7d4b50e.

---
*Added via Oracle Learn*
