---
title: pattern — SCB approver refuses to approve blindly; no-match or selection failure
tags: [technical-writer, repo:bank-bot, current, scb, approver, safety, batch-isolation, pattern]
created: 2026-04-19
source: banks/scb/approver.js:311-366@b5ed22c (PR #82 / 0815737)
project: github.com/kokarat/bank-bot
---

# pattern — SCB approver refuses to approve blindly; no-match or selection failure

pattern — SCB approver refuses to approve blindly; no-match or selection failure both ABORT to waiting_to_review

Before PR #82 (0815737, 2026-04-19) the approver's Phase 2 had two Select All fallback paths: (a) "selective check failed → fall back to select all" inside the selective-check try/catch, and (b) an "all matched OR no match data → select all" else-branch. Both are now removed.

Current behavior:
- `matchResult.matched.length === 0` → ABORT with `{status: 'waiting_to_review', error: 'Approver could not match any items — refusing to approve blindly', matched: [], unmatched: []}`. Screenshot `approver-no-match-abort`. The approver never touches the todo list if it cannot identify which rows belong to maker's batch.
- Has matched items → uncheck Select All first (start clean), then individually check each matched task's checkbox via `TODO_TRANSACTION_LIST.nth(taskIndex)` (API path) or `getByRole('checkbox').nth(index)` (scrape path).
- Selection throw → ABORT `waiting_to_review` with `'Failed to select items: <msg>'`. Screenshot `approver-select-failed-abort`. No Select All retry.

Rationale: Select All approves every visible todo row — including prior-batch items still in flight, cross-account items, and rows missed by API interception. Even if all current-batch items appear matched, the page may carry items that should NOT be approved. Selecting by TRANSFER ID is the only guarantee the approver approves exactly what maker sent. An abort is safer than an approval.

Phase 4 (reject unmatched) still runs after approve — this change does not touch rejection logic.

---
*Added via Oracle Learn*
