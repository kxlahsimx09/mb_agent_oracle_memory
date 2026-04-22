---
title: Orphan marker — docs/flows/ktb-login-with-otp.md header at line 5 still carries 
tags: [technical-writer, repo:bank-bot, current, orphan-marker, flow-drift, flow:ktb-login-with-otp, thread-23, w8-handoff]
created: 2026-04-22
source: docs/flows/ktb-login-with-otp.md
project: github.com/kokarat/bank-bot
---

# Orphan marker — docs/flows/ktb-login-with-otp.md header at line 5 still carries 

Orphan marker — docs/flows/ktb-login-with-otp.md header at line 5 still carries [RATIFICATION_PENDING:23] but Oracle thread #23 was ratified+closed by human on 2026-04-20 (S4 → S2 promote, all four Q ratified). Sibling docs that were ratified in the same wave (bot-bootstrap-and-status-reporting.md thread #30, ktb-single-transfer-withdrawal.md thread #21, bot-maintenance-mode-window.md thread #35) all got the post-ratification doc edit applied (header bumped to S2 + marker stripped + // ratified-via-thread:N added). ktb-login-with-otp.md was the one miss — likely because thread #23 ratification landed without an accompanying W8-revision doc edit. Per W9 Step 4b case 4, not stripping on faith; flagging here for the next W8 sweep to apply the conventional S4 → S2 promotion + marker strip + // ratified-via-thread:23 add. No code change required.

---
*Added via Oracle Learn*
