---
title: P1#4 callback URL safety contract drafted for §ADR-9 and surfaced in DEPOSIT-001
tags: [system-architect, repo:mb-next-payment-gateway, next, adr-9, callback-dispatcher, callback-url, ssrf, security, api-design, provisional, thread-223, thread-167]
created: 2026-05-25
source: docs/adr.md + docs/requirements/epic-deposit.md + docs/requirements/epic-payout.md (local draft 2026-05-25, thread #223 pending)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# P1#4 callback URL safety contract drafted for §ADR-9 and surfaced in DEPOSIT-001

P1#4 callback URL safety contract drafted for §ADR-9 and surfaced in DEPOSIT-001/PAYOUT-001.

Context:
- Thread #167 P1#4 identified a genuine doc + design security gap: client-supplied `callback_url` was accepted by deposit/payout create stories while §ADR-9 covered callback signing/retry but not whether the gateway may safely call that URL.
- pg-writer verified mobiz current validates callback URLs on both create paths via `helpers.ValidateCallbackURL`; next-architect verified the gap as a real SSRF regression surface.

Decision draft:
- §ADR-9 now has a provisional 2026-05-25 Callback URL Safety Contract anchored to thread #223.
- `POST /deposits` and `POST /payouts` validate `callback_url` before business-state writes and reject unsafe URLs with `code=INVALID_CALLBACK_URL`.
- Phase-1 allows absolute HTTPS public URLs only, rejects localhost/private/reserved targets, embedded credentials, unsafe DNS answers, and disallowed ports, and re-checks at dispatch time to guard DNS rebinding.
- Requirement docs DEPOSIT-001 and PAYOUT-001 now include the invalid-callback rejection ACs.

Status:
- Security-sensitive; drafted as `#provisional` `[RATIFICATION_PENDING:223]`, not a binding `#decision` until the human ratifies or revises thread #223.

---
*Added via Oracle Learn*
