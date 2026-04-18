---
title: # gotcha — SCB `clearStaleRecipients()` guards against IBFT-merge contamination
tags: [technical-writer, repo:bank-bot, current, scb, maker, gotcha, incident, safety]
created: 2026-04-18
source: W1 baseline @ 7d4b50e (PR #60, commit 0789b4b)
project: github.com/kokarat/bank-bot
---

# # gotcha — SCB `clearStaleRecipients()` guards against IBFT-merge contamination

# gotcha — SCB `clearStaleRecipients()` guards against IBFT-merge contamination

**Tags**: technical-writer, repo:bank-bot, current, scb, maker, gotcha, incident

**What**: SCB's "Select All" button selects every recipient currently visible in the recipient list — across batches. If a prior batch left residual recipients in the page's DOM, the next batch's "Select All" will sweep them up too, merging batches unpredictably and causing the approver to sign for more than intended.

**Incident that motivated it**: `PAY1776373741DXPO1O` — a prior batch's leftover recipient was merged into the following batch's approval, creating an untrackable state where the approver's TRANSFER IDs didn't match the maker's memory. Root cause was that the maker's cleanup ran *after* batch completion only, so a maker crash/reload mid-batch left stale recipients.

**Fix**: `banks/scb/maker.js:clearStaleRecipients()` (L252-302 @ 7d4b50e) now runs **twice** per batch:
- **Pre-batch** (L315-328): before adding any recipient, scan the list. If any pre-existing recipient is found, abort the batch with `waiting_to_review` rather than proceeding — someone needs to check whether the residual recipients reflect a prior partial send.
- **Post-batch cleanup** (L622-663): after batch submit, unconditionally remove every recipient. If the cleanup itself fails (e.g., a timeout), the app-level wrapper in `app.js` L460-471 throws a RECYCLE error that recycles the browser, so the next batch starts from a clean page.

**Why it matters**: Silent batch merging is a money-moving bug — the bot could approve 10 transfers when the backend only authorized 5. Detecting contamination *before* submit is cheaper than reconciling after.

**How to apply**:
- Never assume SCB's recipient list is empty at batch start. Always call `clearStaleRecipients()` first.
- If you see unexplained TRANSFER ID count mismatches between maker signals and approver signs, check whether `clearStaleRecipients` ran — and whether the pre-batch check fired.

**Source**: docs/current-system.md §3.1.3 + PR #58 @ 7d4b50e.

---
*Added via Oracle Learn*
