---
title: **otplogsenh — owner resolved the 5 open /otp-logs + /bank-accounts forks (2026-
tags: [next, otp-log, bank-account, adr, ratification, retention, from_email, otp-relay, append-only, cross-repo-scope, system-architect]
created: 2026-06-17
source: next-architect, campaign otplogsenh (PR #576, merged 414cedc)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# **otplogsenh — owner resolved the 5 open /otp-logs + /bank-accounts forks (2026-

**otplogsenh — owner resolved the 5 open /otp-logs + /bank-accounts forks (2026-06-17); recorded append-only in §ADR-23/§ADR-6/§ADR-22 + epics, SPEC'd the 2 builds. PR #576 merged (414cedc).**

The five FINAL owner decisions:
- **① otp_logs retention = 7 DAYS** (was 24h-post-expiry) — resolves §ADR-23 (c1). BUILD. Mechanism = the BBOT-010 pg_cron `purge-expired-otp-logs` DELETE interval `24h → 7 days` (`20260614000010_bbot010_otp_relay.sql:322-333`). This is a §ADR-6/BBOT-010 substrate edit (recorded §ADR-6 §Revision 2026-06-17 OR2). The EXPIRY-ONLY read gate (`get_bot_otp`, otp_expires_at > app_now()) is UNCHANGED.
- **② from_email PORTED** (reverses §ADR-23 P2 deliberate omission) — BUILD. Add `from_email` to otp_logs + `p_from_email` pass-through on save_bot_otp + bot-otp-log EF + project in v_otp_logs + /otp-logs UI.
- **③ method badges D/T/P/S = DROP** (no build) — they're `bank_account_method` config → belong on /system-bank, not the relay log; otp_logs has no method column.
- **④ parse-failure visibility = SKIP** (no build) — resolves §ADR-23 (c2); a parse failure never lands a row (save_bot_otp RAISEs otp_parse_failed → EF 400), so the view shows successful relays only — already shipped.
- **⑤ §ADR-22 BENE-007 enforced payout linkage = ADVISORY (parity)** (no build) — resolves §ADR-22 (b1); registry has no server-side payout↔beneficiary enforcement; enforced linkage NOT adopted.

**TEETH preserved throughout:** §ADR-23 P2 — v_otp_logs NEVER projects otp_logs.otp. ① keeps a dead/zero-grant code longer at rest but never exposes it (OTP is single-use + ~5min TTL = dead-on-expiry; base SV7b zero-grant; view always redacts → the redact@24h+keep-metadata@7d split was weighed and NOT chosen — marginal at-rest-only gain not worth breaking OR2's append-only posture). ② adds the SENDER-ADDRESS metadata, not the code.

**KEY CROSS-REPO FINDING (the ② scope question):** the next bank-bot (mb-next-bank-bot) is the OTP **CONSUMER, not the producer** — `core/otp_api.js::getOtpFromAPI` only READS {otp,source} via the bot-otp poll; never writes a relay row, never handles from_email. The PRODUCER (writes via bot-otp-log → save_bot_otp) is the out-of-tree External:OTPService; in SIM = `sim/mock-portal/otp-service.js` which posts `source:'sms'` ONLY (SMS-only). The email/IMAP producer write-path (`bot-otp-accounts` discovery) is OR5-DEFERRED Phase-2 (not built). `core/otp_email.js` is the bot's OWN direct-IMAP login fallback (returns OTP to its login flow — does NOT relay from_email to the gateway). ⇒ from_email port is **gateway + portal-UI scope, column NULL-for-now** (populates when the deferred email producer lands); **bank-bot needs NO change**. The gateway substrate (otp_logs + save_bot_otp + bot-otp-log EF) has NO from_email today.

**Marker-clearing discipline (P-001 append-only):** flip active `[RATIFICATION_PENDING:owner]`/`[ESCALATE_TO_HUMAN]` tokens → `[RESOLVED 2026-06-17:owner ...]` (preserve the original question text as "kept for the record"); append a new §Amendment block + a newest-first revision-log entry; do NOT rewrite the immutable baseline revision-log entries (add the resolving entry above them). House precedent = the ST4/GP1-GP7 "RATIFIED `#decision` (owner GO ...)" pattern.

SPEC: `docs/spec/otp-logs-retention-fromemail-enhancement-slice.md` (the ①② build delta — migrations, view re-create projecting from_email with otp still absent, EF pass-through, pgTAP TEETH re-run + extend). Build is a separate orchestrator-run phase (next-dev → brew-ops → next-ui).

---
*Added via Oracle Learn*
