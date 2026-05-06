---
title: Step-up TOTP defense for money-out operations (`helpers/totp_step_up.go` NEW `81
tags: [technical-writer, repo:mobiz-payment-gateway, current, security, totp, 2fa, step-up, money-out, decision-required]
created: 2026-05-04
source: helpers/totp_step_up.go:1-149 @ 815418e
project: github.com/kokarat/mobiz-payment-gateway
---

# Step-up TOTP defense for money-out operations (`helpers/totp_step_up.go` NEW `81

Step-up TOTP defense for money-out operations (`helpers/totp_step_up.go` NEW `815418e` #399, 2026-05-05). VerifyTOTPStepUp(username, secret, code, purpose) wraps pquerna/otp/totp.Validate with two Redis-backed defenses: per-(user,purpose) failure counter at 2fa:fail:{purpose}:{username} (5 fails / 15 min → ErrStepUpLockedOut, cleared on success) and per-(user,purpose,sha256(code)[0:8]) replay block at 2fa:replay:... via SETNX with 90 s TTL (ErrStepUpReplay on second use). FAIL OPEN on Redis outage — every Redis branch logs WARNING and proceeds; rationale per file comment is that an outage cannot deadlock real refunds. The TOTP itself is always validated regardless of Redis state. Code hash uses 8 hex chars (32-bit), short enough to keep keys compact, long enough that collision per (user,purpose) is negligible at 90 s TTL. Replay scope is per-purpose, so the same 6 digits CAN be reused across distinct purposes within 30 s (e.g., deposit_refund then deposit_refund_resolve back-to-back). Sister helper SanitizeRefundFreeText(in, maxLen) lives in same file: trim, drop ASCII control chars except \\n\\t\\r, rune-aware truncate. Used to defang admin reason/notes before BSON / Telegram / merchant callbacks. SECURITY-SENSITIVE — fast-fix-disqualified per Workflow 2 (helpers/security.go-class file). Thread #75 opened with security_auditor for ratification of fail-open posture, replay scope, and hash truncation. Doc placement: §3.2.6 (refund flow), §6.7 (services list), §7.5b (NEW security subsection) — all carry [AWAITING_THREAD:75] markers until the thread closes.

---
*Added via Oracle Learn*
