---
title: AUTH-007 step-up TOTP on money-out — architect recommendation; SECURITY-SENSITIV
tags: [system-architect, repo:mb-next-payment-gateway, next, auth, totp, step-up, security, provisional, adr-2, thread-236, money-out]
created: 2026-05-26
source: mobiz helpers/totp_step_up.go@815418e + §ADR-2 G1-D + AUTH-007 (epic-auth-rbac.md) + thread #236/#233
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# AUTH-007 step-up TOTP on money-out — architect recommendation; SECURITY-SENSITIV

AUTH-007 step-up TOTP on money-out — architect recommendation; SECURITY-SENSITIVE, requires human ratification (thread #236 / #233).

AUTH-007 (fresh step-up second-factor before a money-out action) — architect consult #236. SECURITY-SENSITIVE per charter §9 + skill escalation rules → I RECOMMEND but do NOT bind #decision; requires explicit human ratification before becoming #decision.

CURRENT STATE: §ADR-2 G1-D ratifies LOGIN 2FA only. Step-up (re-prove operator presence at the moment of a money-out action) is a DISTINCT control, unratified for next-system. Mobiz substrate = helpers/totp_step_up.go @815418e: VerifyTOTPStepUp(user, secret, code, purpose) — purpose-scoped; Redis-backed replay block (SETNX, 90s TTL, key per (user,purpose,sha256(code)[:8])) + failure-counter lockout (5 fails / 15 min) + FAIL-OPEN on Redis outage (the TOTP itself is always validated regardless). Reuses the login-2FA authenticator seed (users.two_factor_secret). Currently guards deposit refund (RefundDeposit + ResolveRefund); tagged decision-required (mobiz thread #75 — never ratified for current system either).

ARCHITECT RECOMMENDATION (pending human ratification):
1. SCOPE = ADMIN-initiated / admin-forced money-out actions in the admin UI (human callers). NOT machine/client API flows — clients authenticate per-request via API-Key + Idempotency-Key (§ADR-7/§ADR-11); a human step-up does not fit a machine caller.
2. Recommended action set: deposit refund · admin-created Direct-Transfer · admin-created Settlement + Settlement approve · admin payout override / confirm-completed / cancel (§ADR-4d money-state forcing). Principle: irreversible or high-value money movement initiated or forced by a human admin.
3. POSTURE: port purpose-scoped replay + lockout, BUT the FAIL-OPEN posture must be an EXPLICIT ratified choice (fail-open lets a replayed code through during a substrate outage; mobiz chose it to avoid deadlocking real refunds). Replay/lockout substrate on Supabase (no Redis assumed) = impl/design pass.
4. Proposed home: a future §ADR-2 step-up amendment, authored once the human ratifies (a) scope/action-set and (b) fail-open vs fail-closed posture.

Until ratified, AUTH-007 stays S4 / unratified. The [AWAITING_THREAD:233] anchor updates to: 'architect recommendation filed (admin money-out scope, list above); pending human security ratification → proposed §ADR-2 step-up amendment.'

---
*Added via Oracle Learn*
