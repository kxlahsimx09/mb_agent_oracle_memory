---
title: decision — SCB approver post-OTP success detection is a 3-layer wait
tags: [["decision", "scb", "approver", "otp", "success-popup", "waiting_to_review", "todo-list-fallback", "muidialog", "dismissPopups", "technical-writer", "repo:bank-bot", "current", "safety"]]
created: 2026-04-18
source: banks/scb/approver.js:599-716@4ca226c (PRs #67, #68, #69 — commits e986846, 1c658cc, a07c3d5, efa9077)
project: github.com/kokarat/bank-bot
---

# decision — SCB approver post-OTP success detection is a 3-layer wait

decision — SCB approver post-OTP success detection is a 3-layer wait

At 4ca226c, after the OTP confirm click, the SCB approver detects transfer success via three layered checks before falling back to `waiting_to_review`:

1. **30 s direct wait** on `CusLanding-SucceessPopUp_SumbitBtn` — the happy path. Click it, `successPopupOk = true`. (banks/scb/approver.js:604-611)
2. **`dismissPopups(page)` + 15 s retry** — if the direct wait times out, run `dismissPopups()` once (safe; it targets session-expired / generic-error MuiDialogs by text, not `.MuiDialog-root` wholesale). If it returns `'session_expired'` → return `waiting_to_review` immediately. Otherwise retry the success popup for 15 s. (banks/scb/approver.js:612-635)
3. **Todo-list fallback** — if the retry still times out, `page.goto('https://www.scbbusinessanywhere.com/landing')` and read `body.innerText()`. If it contains `ต้องทำ (0)` or `ต้องทำ(0)`, the approved items are no longer in the bank's todo queue → mark `successPopupOk = true`. Else screenshot `approver-fallback-todo-not-empty` and leave `false`. (banks/scb/approver.js:637-654)

The final return status is `success` only if `successPopupOk` is true after all three layers, else `waiting_to_review`. Phase 4 (reject unmatched) still runs regardless so the approval board is left consistent.

**Why:** Before this shape, 93.9 % of SCB payouts were ending in `waiting_to_review` because a stray MuiDialog (session / error popup) was covering the success popup, the fixed 30 s timeout fired, and the bot couldn't tell whether money had moved. PR #67 → PR #68 → PR #69 iterated three times to get here: PR #67 bumped the timeout to 60 s and tried blind `.MuiDialog-root` dismissal, PR #68 reordered the dismiss to run before `dismissPopups()`, and PR #69 realised the success popup is itself a MuiDialog (see sibling learning `gotcha-scb-success-popup-is-itself-a-muidialog`) and replaced blind dismissal with the 3-layer wait above plus the todo-list fallback.

**How to apply:**
- When touching this region, preserve all three layers. Dropping the todo-list fallback re-exposes the `PAY1776354769R7GYS5` failure class (popup timed out, money moved, bot silent).
- Keep the invariant that `failed` is never returned after OTP confirm — only `success` or `waiting_to_review`. `failed` here would silently retry and risk a duplicate transfer.
- The `ต้องทำ (0)` text is a Thai UI string on SCB's landing page meaning "todo (0)". If SCB reskins the landing page, update both the text pattern and the navigation URL together.

---
*Added via Oracle Learn*
