---
title: flow intent at a glance — bot-otp-imap-fallback (bank-bot W8 2026-04-22). Scope:
tags: [technical-writer, repo:bank-bot, current, flow, flow:bot-otp-imap-fallback, otp, imap-fallback, s4, ratification-pending, reverse-engineered, sibling:bot-otp-relay]
created: 2026-04-22
source: docs/flows/bot-otp-imap-fallback.md@adeac29
project: github.com/kokarat/bank-bot
---

# flow intent at a glance — bot-otp-imap-fallback (bank-bot W8 2026-04-22). Scope:

flow intent at a glance — bot-otp-imap-fallback (bank-bot W8 2026-04-22). Scope: one invocation of core/otp_email.js::getOtpFromEmail(config, referenceCode) — the IMAP fallback path invoked by app.js getOTP closures when the gateway OTP relay (sibling bot-otp-relay flow) has exhausted its 3x retry budget. The flow: connect IMAP (default Gmail via imapflow + App Password); open INBOX; fetch last 20 messages by seq range; for each message parse via mailparser; filter by sender-contains, subject-contains, body-contains; if referenceCode provided further filter by (เลขที่อ้างอิง OR รหัสอ้างอิง) regex against the code; extract OTP via configurable 6-digit regex; return on match; outer loop polls every pollMs (default 2s) until match or timeout (default 180s). Three-way outer alt: hit (return + logout), miss (logout + sleep + retry), pollOnce-threw (catch + console.log 'Poll error' + sleep + retry — NO throw). Caller sites: 3 app.js getOTP closures (SCB approver main loop, SCB approver per-batch runApprover, KTB transfer processSingleTransfer) each with 3x getOtpFromAPI retry before falling through. Plus 1 direct call at banks/ktb/transfer.js:814-818 inside handleTransferOTP. Non-caller: banks/ktb/login.js::fillOTP has NO IMAP fallback ([DRIFT-login-imap-fallback] carried forward from ktb-login-with-otp 2026-04-19). Sibling flow: bot-otp-relay (ratified S2 via thread #39 on 2026-04-22) — the primary OTP transport. Five drift references filed: [DRIFT-imap-auth-fail-swallowed] (mirror of relay 5xx-swallowed), [DRIFT-regex-staleness-invisible], [DRIFT-20-message-window], [DRIFT-env-var-silent-fallback] (latent security smell), [DRIFT-console-log-untagged] (one-line fix, W4 candidate). None queued for W4 this pass. Claim strength S4; [RATIFICATION_PENDING:40] filed with five judgement calls. W8 root trace: 3d7ced04-712c-4401-aeee-f3fb2d5dbebe. No cross-repo crossing (bot ↔ External:GmailIMAP only); filed with #cross-repo-sync tag + body disclosing asymmetry with mobiz.

---
*Added via Oracle Learn*
