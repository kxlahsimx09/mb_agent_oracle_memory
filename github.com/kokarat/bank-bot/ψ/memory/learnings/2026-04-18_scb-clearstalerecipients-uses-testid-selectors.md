---
title: SCB `clearStaleRecipients` uses testId selectors + text-counted recipient detect
tags: [technical-writer, repo:bank-bot, current, scb, maker, selector, testid, stale-recipients]
created: 2026-04-18
source: banks/scb/maker.js:252-287@2774dab
project: github.com/kokarat/bank-bot
---

# SCB `clearStaleRecipients` uses testId selectors + text-counted recipient detect

SCB `clearStaleRecipients` uses testId selectors + text-counted recipient detection (PR #61)

**Why:** The previous implementation (baseline `7d4b50e`) counted `<tr>` rows inside `Transfer-AddedRecipients_AddedRecipientsTable` — header rows were counted as stale, inflating the count. It also clicked `getByRole('button', { name: 'ลบ' })` which does not match SCB's delete button. Both broke the stale-guard: false-positive count triggered a delete flow that then failed to find the button, returning `-1` and aborting batches.

**How to apply:**
- Documenting any selector work in `banks/scb/maker.js` must use the testIds `Transfer-AddedRecipients_DeleteSelectedAccountBtn` (delete) and `Transfer-DeleteSelectedAccountPopup_DeleteBtn` (confirm), registered in `banks/scb/selectors.js` as `TRANSFER.DELETE_SELECTED_BTN` + `TRANSFER.DELETE_CONFIRM_BTN`.
- Stale detection is now by the regex `ผู้รับเงินที่เลือก\s*\((\d+)\)` against the section text — not by `tr` count.
- If a future selector sweep across banks proposes to "simplify" `clearStaleRecipients` by going back to role-based queries, flag as `#regression-candidate`.

Evidence at `2774dab`:
- `banks/scb/selectors.js:27-28@2774dab` — new `DELETE_SELECTED_BTN` + `DELETE_CONFIRM_BTN`.
- `banks/scb/maker.js:252-287@2774dab` — new implementation.
- Prior incident: bot 4192118234 / bot PAY1776373741DXPO1O (2026-04-17) — the failure mode this guard addresses.
- Source: PR #61 / commit `5160689`.

---
*Added via Oracle Learn*
