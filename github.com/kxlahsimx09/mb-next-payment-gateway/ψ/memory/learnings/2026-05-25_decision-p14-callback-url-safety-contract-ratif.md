---
title: #decision: P1#4 callback URL safety contract ratified for mb-next-payment-gatewa
tags: [system-architect, repo:mb-next-payment-gateway, next, adr-9, callback-url, ssrf, security, decision, thread-223]
created: 2026-05-25
source: thread #223 human ratification + local docs verification
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# #decision: P1#4 callback URL safety contract ratified for mb-next-payment-gatewa

#decision: P1#4 callback URL safety contract ratified for mb-next-payment-gateway on 2026-05-25 via Oracle thread #223.

Human ratification phrase: "โอเค ทำหมดตามที่แนะนำ".

Ratified contract:
- Validate merchant-provided callback_url synchronously on POST /deposits and POST /payouts before creating business state.
- Invalid callback_url returns HTTP 400 with code=INVALID_CALLBACK_URL.
- Rejection must leave no deposit/payout row, no wallet/bank-capacity mutation, no callback queue item, and no idempotency-success record.
- Allowed client-facing callback URLs are absolute HTTPS only.
- Reject HTTP, non-HTTP(S), relative URLs, URL fragments, embedded credentials, localhost, loopback, link-local, private/reserved IP ranges, and non-default ports unless explicitly admin-allowlisted.
- Resolve DNS before accepting; every A/AAAA answer must be public.
- Re-check DNS safety at dispatch/retry/manual resend time to guard DNS rebinding; unsafe dispatch must not make an HTTP request and must record callback_url_unsafe / dead-letter-equivalent operator path.
- Preserve the original per-request callback URL for retries and manual resends.
- Admin/debug allowlists must stay outside the client-facing create path and be auditable.

Local docs updated and verified with git diff --check:
- docs/adr.md: §ADR-9 amendment now ratified #decision via thread #223.
- docs/requirements/epic-deposit.md: DEPOSIT-001 callback_url validation and INVALID_CALLBACK_URL atomic rejection.
- docs/requirements/epic-payout.md: PAYOUT-001 callback_url validation and INVALID_CALLBACK_URL atomic rejection.
- docs/requirements/epic-deposit-revision-log.md: P1#4 ratification entry added.

UX implication: valid public HTTPS callback integrations are unchanged, but merchants using localhost/private/internal/http/non-default-port callback endpoints will now fail fast at create time and must use a compliant public HTTPS endpoint or an admin-approved allowlist path.

---
*Added via Oracle Learn*
