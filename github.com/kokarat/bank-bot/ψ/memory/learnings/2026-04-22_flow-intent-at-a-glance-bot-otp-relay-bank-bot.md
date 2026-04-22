---
title: flow intent at a glance — bot-otp-relay (bank-bot W8 2026-04-22). Scope: one inv
tags: [technical-writer, repo:bank-bot, current, flow, flow:bot-otp-relay, otp, gateway-relay, ratification-pending, s4, bot-first, reverse-engineered]
created: 2026-04-22
source: docs/flows/bot-otp-relay.md@b71aff4
project: github.com/kokarat/bank-bot
---

# flow intent at a glance — bot-otp-relay (bank-bot W8 2026-04-22). Scope: one inv

flow intent at a glance — bot-otp-relay (bank-bot W8 2026-04-22). Scope: one invocation of `core/otp_api.js::getOtpFromAPI(api, acc, ref, {timeoutMs, pollMs})` — bank-bot polls `GET /api/v1/bot/otp/:acc_number/:reference_code` on mobiz-payment-gateway until a matching unexpired `otp_logs` row appears, returns the 6-digit OTP, or throws on timeout. Three-way alt (hit/miss/error): 200 returns otp, 404 sleeps and re-polls, non-404 errors log warn and re-poll (do NOT throw). Upstream producer is an external OTP service (MacroDroid SMS + IMAP email, separate process) that POSTs to Gateway's `/bot/otp-log` — NOT in this flow's sequence, noted as §Actors precondition only. Five consumer call sites (SCB approver P1 SMS + P2 email, KTB login P1 + P2, KTB transfer P1 + P2) all pass tiny `{timeoutMs:1000, pollMs:1000}` and own the 10-second outer backoff themselves. IMAP fallback (`core/otp_email.js`) invoked by app.js getOTP closure on relay failure — EXPLICITLY OUT OF SCOPE, sibling flow `scb-email-otp-via-imap` pending. KTB login has no IMAP fallback per carried-forward `[DRIFT-login-imap-fallback]` from ktb-login-with-otp.md. Two drift references filed: `[DRIFT-gateway-5xx-swallowed]` (non-404 silently swallowed, Gateway outages indistinguishable from "OTP not arrived" in logs); `[DRIFT-expiry-invisible-to-caller]` (post-TTL OTP and never-posted OTP both appear as 404). Neither W4-queued — changing either would mask real "OTP delayed" cases. Claim strength S4; `[RATIFICATION_PENDING:39]` filed with five judgement calls. W8 root trace: ce35d223-bab7-4bab-bc9f-94b3875a002d. Bot-first cross-repo flow — no mobiz-payment-gateway sibling authored at HEAD; breadcrumb publishes the boundary for a future mobiz W8 to close the loop. Tag form: plain `cross-repo-sync` per thread #23 Q1 ratification (dropped `-bot-first` suffix).

---
*Added via Oracle Learn*
