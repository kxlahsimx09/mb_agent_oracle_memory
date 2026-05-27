---
title: epic authored — auth-rbac — 7 stories, trust mix S2/S4 = 6/1.
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, epic, auth-rbac, rbac, 2fa, tenant-scope, mixed-trust, campaign-228, thread-230]
created: 2026-05-26
source: docs/requirements/epic-auth-rbac.md@writer/auth-rbac-adr2
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# epic authored — auth-rbac — 7 stories, trust mix S2/S4 = 6/1.

epic authored — auth-rbac — 7 stories, trust mix S2/S4 = 6/1.

Subsystem: auth-rbac (Auth & RBAC — the gate every other epic sits behind)
Net-new epic from campaign #228 / sub-thread #230 (Pass 2, P0b). Translates §ADR-2 (Supabase Auth + G1–G6 amendment thread #85) + §ADR-7 (API-key M2M) + §ADR-13 F1–F4 (actor tiers + RBAC + tenant scope, thread #82) into human-readable stories. Grounded against current production (dpay MCP 2026-05-26).

Stories:
- AUTH-001 [S2] one identity store, 4 entity types, one login (Supabase Auth; entity_type single string; email 1:1; §ADR-2 + G2-D).
- AUTH-002 [S2] mandatory 2FA/TOTP every login (first-login enroll + temp_token, two-step verify, admin reset, lockout; §ADR-2 G1-D). Response-shape-as-contract.
- AUTH-003 [S2] two-layer authz: RLS data-isolation Layer-1 + EF-middleware RBAC Layer-2; flat resource:action roles, immediate-effect no-re-login (§ADR-2 RBAC + §ADR-13 F3/D3).
- AUTH-004 [S2] tenant-scope guard / IDOR prevention — non-admin pinned to own tenant, sub-client→parent, Layer-1 check before any read/write (§ADR-13 F1/F4; elevates PR #235 helper to architectural rule).
- AUTH-005 [S2] login audit + IP allowlist (EF middleware, per-account) + platform rate-limit; DB-fresh permissions (§ADR-2 G4-D/G5-D + §ADR-13 D2).
- AUTH-006 [S2] machine auth — client API-key+HMAC + per-client rate-limit; bot service-role JWT bound to bank_account_id (§ADR-7 + §ADR-2 G6-D + §ADR-11 idempotency).
- AUTH-007 [S4] step-up TOTP on money-out — current behaviour (helpers/totp_step_up.go, decision-required), NOT ratified for next-system; flagged.

Production grounding (dpay 2026-05-26): users=685 (user_type sub-client 494/client 109/admin 43/merchant 29/partner 10); 2FA enrolled 507/685; users.ip is a SINGLE string (next-system needs allowlist array — design gap noted in AUTH-005); parent_client_id present. roles=7 (super_admin 32 resources / super_cs 21 / cs 20 / client 9 / merchant 8 / partner 4 / Sub-Client 2) + separate resources(33)/actions(9) registries, flat namespace confirms §ADR-13 F3. clients=109 api_key+api_key_secret, NO per-min/per-day rate field at data layer (rate-limit is code-side → A3 numbers are config, S4). login_logs=37,685 (success 20,083/pending 16,321/failed 1,283; pending=2FA-challenge). activity_logs=1,507 (admin-action audit→audit_log). audit_trail=6.6M is the HTTP request log, NOT semantic audit.

KEY SCOPING DECISION (data-grounded): otp_logs (38,149; source sms 21,579/email 16,572) is keyed by acc_number+reference_code with NO user_id → it is the BANK-BOT OTP RELAY for automated transfers, NOT user-login OTP. Deliberately NOT authored as an auth story; routed to cross-repo.md as bot-side (bankbot-v2 / §ADR-6). pg-writer #227 "OTP dual-source" correctly maps here, not to user auth. The user-facing OTP/Trust = login 2FA (AUTH-002) + step-up (AUTH-007).

Open threads / flags:
- [AWAITING_THREAD:233] step-up auth (AUTH-007) scope folded into the source-flows settlement consult to next-architect.
- AUTH-006 per-client rate-limit numbers overlap A3 ratification → flagged to next-architect sub-thread #229.
- AUTH-005 force-logout/token-blacklist (current DRIFT-14, unwired) → next-system immediate session revocation is a Fleet-Control concern (§ADR-14), deferred — noted as open question.

Files: docs/requirements/epic-auth-rbac.md (new) + glossary.md (+entity-type/2fa/rbac/tenant-scope/step-up) + INDEX.md (+Auth & RBAC section) + README.md (Auth & RBAC + OTP & Trust rows) + cross-repo.md (bank-OTP-relay routing). Mermaid gate 5/5 PASS; MDX clean.

Stacked-file note: branched off origin/main (not the Pass-1 source-flows branch), so glossary.md + INDEX.md will have a trivial append-region conflict with PR #245 (both insert before the same trailing anchor line); README rows are non-overlapping (clean). Resolvable by taking both hunks or rebasing whichever merges second.

---
*Added via Oracle Learn*
