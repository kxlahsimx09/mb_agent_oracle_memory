---
title: drift — bot OTP timing is two-phase (SMS → email), not "60-90 seconds"
tags: [technical-writer, repo:bank-bot, current, scb, ktb, otp, drift]
created: 2026-04-17
source: docs/current-system.md §8 DRIFT-13 @ 95dbb70
project: github.com/kokarat/bank-bot
---

# drift — bot OTP timing is two-phase (SMS → email), not "60-90 seconds"

CLAUDE.md says "SCB takes 60-90 seconds to enable the OTP request button". That 60-90 s is only the first gate — the actual OTP-retrieval protocol is a two-phase loop shared by SCB approver + KTB login + KTB transfer: Phase 1 polls backend for SMS-sourced OTP every 10 s while waiting for the email button to enable (SCB cap 180 s, KTB cap 60 s); Phase 2 clicks the email request button, re-reads the rotated reference code, and polls the backend every 10 s for up to 180 s, with final fallback to direct IMAP (core/otp_email.js).

## The real protocol at 95dbb70

Shared by `banks/scb/approver.js:419-556`, `banks/ktb/login.js:229-310`, `banks/ktb/transfer.js:720-834`:

**Phase 1 — SMS while waiting for email button:**
- SCB: up to 180 s cap (OTP TTL is 5 min). Loop at 1 s resolution; every 10 s call `getOtpFromAPI(api, acc, ref, {timeoutMs:1000, pollMs:1000})`. Exit as soon as either `otp` arrives or the email request button enables.
- KTB: 6 × 10 s attempts = 60 s cap (OTP TTL is 3 min).
- If SMS lands first, skip Phase 2 entirely.

**Phase 2 — Email after button enabled:**
- Click `otp-form.request_email` (SCB) / `ส่งรหัส OTP ผ่านอีเมล` (KTB).
- Re-read the reference code (SCB and KTB both rotate it at this moment).
- 18 × 10 s = 180 s of backend poll (`getOtpFromAPI` with `timeoutMs:1000`, self-managed 10 s sleep between polls).

**Final fallback:** legacy `getOTP(otpConfig, ref)` which is direct IMAP via `core/otp_email.js`. This is what covers the bot when the OTP service is down.

## Why this matters

- "60-90 seconds" is a misleading framing — the total budget is up to 360 s (SCB worst case) or 240 s (KTB worst case).
- The Phase 1 SMS race is a load-bearing latency optimization — without it every SCB approval waits the full email round-trip.
- The reference-code rotation is the easiest thing to silently break: a refactor that reuses the pre-click ref code will cause the email match regex in `core/otp_email.js` to miss every OTP.

## Resolution path

Doc fix: CLAUDE.md "SCB-Specific Notes" → expand OTP wait description to two-phase; "KTB-Specific Notes" → document same shape; add the 240 s / 360 s totals.

## How to apply

- When debugging "OTP timeout" incidents, always check which phase failed — the log lines `Phase 1`/`Phase 2`/`Phase 2 fallback` are what to grep.
- When tuning rate limits, the outer 10 s cadence is the knob; never reduce `timeoutMs:1000` in the inner call (that is the "single GET then return" contract).

---
*Added via Oracle Learn*
