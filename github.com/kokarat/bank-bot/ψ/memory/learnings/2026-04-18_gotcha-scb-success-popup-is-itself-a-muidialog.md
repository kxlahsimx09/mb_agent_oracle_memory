---
title: gotcha — SCB success popup is itself a MuiDialog
tags: [["gotcha", "scb", "approver", "muidialog", "success-popup", "otp", "waiting_to_review", "session_expired", "safety", "popup", "playwright", "selector", "technical-writer", "repo:bank-bot", "current"]]
created: 2026-04-18
source: banks/scb/approver.js:599-654@4ca226c (PR #69, commits efa9077 + a07c3d5)
project: github.com/kokarat/bank-bot
---

# gotcha — SCB success popup is itself a MuiDialog

gotcha — SCB success popup is itself a MuiDialog

The SCB approver success popup (testId `CusLanding-SucceessPopUp_SumbitBtn`) is rendered as a `.MuiDialog-root`. Any "blind" dismiss loop that clicks the first button inside `.MuiDialog-root` or presses Escape on every visible MuiDialog after OTP confirm will click the success button itself, navigate to the dashboard, and the bot will never see the success signal → transfer gets marked `waiting_to_review` even when the money moved.

**Why:** This mistake was shipped in PR #67 (e986846) and PR #68 (1c658cc) as an attempt to fix the 93.9 % `waiting_to_review` rate caused by a different MuiDialog (session / error popup) overlapping the success popup. Only PR #69 (efa9077) diagnosed that the success popup **is** the MuiDialog — reverting the blind dismiss restored the success signal.

**How to apply:**
- In `banks/scb/approver.js` after OTP confirm, do **not** call a generic MuiDialog dismiss. The code at 4ca226c has no such call in that region — keep it that way.
- `dismissPopups()` from `banks/scb/login.js` is safe to call after OTP confirm: it targets session-expired / generic-error dialogs by text content, not every `.MuiDialog-root`. Use it (once) as the fallback path between the 30 s primary wait and the 15 s retry — the current shape at lines 612-635.
- If you ever add a MuiDialog clean-up in `banks/scb/approver.js` or `banks/scb/login.js:dismissPopups`, explicitly exclude the success-popup testId before clicking anything.
- A todo-list fallback (`/landing` → `ต้องทำ (0)` text check) is the last line of defense at lines 637-654; it confirms success by the absence of pending items rather than by catching the popup.

---
*Added via Oracle Learn*
