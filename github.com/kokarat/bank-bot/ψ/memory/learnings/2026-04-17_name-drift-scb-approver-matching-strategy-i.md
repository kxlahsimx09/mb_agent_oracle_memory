---
title: drift — SCB approver matching strategy is far richer than "OTP approval flow"
tags: [technical-writer, repo:bank-bot, current, scb, approver, drift]
created: 2026-04-17
source: docs/current-system.md §8 DRIFT-12 @ 95dbb70
project: github.com/kokarat/bank-bot
---

# drift — SCB approver matching strategy is far richer than "OTP approval flow"

CLAUDE.md's SCB section summarizes the approver as a one-line "OTP approval flow". At 95dbb70 the approver actually runs: API interception of /landing/inquiry → masterStagingId-exact match → backend processing-queue cross-check (promote unknown-but-processing tasks, demote matched-but-cancelled tasks) → selective checkbox approve → selective reject-unmatched on a fresh post-approval API intercept. The workflow/scb-transfer.md narrative does cover it but CLAUDE.md does not.

## Architecture at 95dbb70 (banks/scb/approver.js)

- `interceptTodoTasks(page)` (lines 38-56): `page.reload()` while `page.waitForResponse('/landing/inquiry')` fires, then parses `data.toDoList.data.sections[0].tasks`.
- `matchByTransferId(apiTasks, batchItems)` (lines 62-79): exact match on `task.masterStagingId === batchItem.bankTxnId`.
- Backend cross-check (lines 214-271) via `api.fetchProcessingItems(systemBankId)`:
  - PROMOTE: an unmatched task whose `masterStagingId` is in the backend processing queue is treated as approved (it's a prior batch still in flight).
  - DEMOTE: a matched task whose `bankTxnId` is NO LONGER in processing (backend cancelled/failed/expired between maker submit and approver reach) is moved to reject, so the bot never approves a bank transfer for a backend-cancelled payout.
- Fallback scrape path (lines 86-164): `scrapeApprovalItems` extracts name (MuiTypography-noWrap, filtered against Thai month pattern) + amount, `matchItems` does fuzzy name+amount pairing using `bankResolvedName || destName`.
- Selective approve (lines 304-365): uncheck select-all, then `TODO_TRANSACTION_LIST.nth(taskIndex)` for each matched item.
- Phase-4 reject unmatched (lines 611-654): post-success re-intercept fresh tasks, pick the ones that still match `masterStagingId`, click Reject, choose `AcnReasonsDialog-reason`.

## Why this matters

- The cross-check is a hard safety property: it's the reason the bot does not approve bank transfers for payouts that the backend has already cancelled. Silently documenting "OTP approval flow" under-sells this and invites "simplifications" that would remove it.
- Anyone changing the approver needs to know the PROMOTE+DEMOTE invariant before editing.

## Resolution path

Doc fix: expand CLAUDE.md "SCB-Specific Notes" to summarise the four phases and link to `workflow/scb-transfer.md` for the full narrative. Not blocked on code changes.

## How to apply

- When touching `banks/scb/approver.js`, preserve the cross-check branches; add tests rather than remove them.
- When answering "why does the approver sometimes reject an SCB task that's technically on the approval page?", point at lines 243-263 — backend already dropped it.

---
*Added via Oracle Learn*
