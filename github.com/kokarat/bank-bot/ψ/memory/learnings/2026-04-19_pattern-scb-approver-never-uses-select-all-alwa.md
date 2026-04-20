---
title: pattern — SCB approver never uses Select All; always selects by TRANSFER ID.
tags: [technical-writer, repo:bank-bot, current, scb, approver, safety, batch-isolation]
created: 2026-04-19
source: banks/scb/approver.js:311-366@6ebee00 (PR #82 / 0815737)
project: github.com/kokarat/bank-bot
---

# pattern — SCB approver never uses Select All; always selects by TRANSFER ID.

pattern — SCB approver never uses Select All; always selects by TRANSFER ID.

The SCB approver's Phase 2 ("Select items") removed every Select All path on 2026-04-19 (PR #82, commit 0815737). Previously the code had two fallbacks to Select All: (a) when match data was empty, (b) when the individual-select loop threw. Both now ABORT and return status "waiting_to_review" with an explicit error message, leaving the batch for admin verification rather than approving blindly.

The invariant this enforces: the approver only ever approves tasks whose `masterStagingId` equals a `bankTxnId` from the batch that maker just submitted. Even when every currently-intercepted task matches, SCB's todo page can legally hold tasks that `/landing/inquiry` interception missed — late-arriving tasks or rows from a prior batch. Select All would approve those too. Individual-select-only guarantees batch isolation.

This is the approver-side twin of the maker-side "submit outcome uncertain → waiting_to_review" shift in the same PR (commits dd5966b + 6ebee00). Together they express a single design rule: prefer `waiting_to_review` (admin verifies) over `failed` (auto wallet refund) or `success` (auto mark complete) whenever the SCB browser state leaves any ambiguity.

Screenshots on abort: `approver-no-match-abort`, `approver-select-failed-abort`.

---
*Added via Oracle Learn*
