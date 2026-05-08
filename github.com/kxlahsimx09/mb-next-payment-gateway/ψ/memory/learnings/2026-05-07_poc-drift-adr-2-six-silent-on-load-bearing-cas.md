---
title: poc-drift: §ADR-2 — six silent-on-load-bearing-case gaps surface from W1 Step 2+
tags: [implementation-architect, repo:mb-next-payment-gateway, next, auth, adr-2, poc-drift, handoff, drift, silent-on-load-bearing-case, step-5c, supabase-auth, 2fa, rbac, tier-3-deferred]
created: 2026-05-07
source: poc/2/README.md (pre-scaffold; W1 Step 2+3 claim-list extraction, no runnable PoC — Tier-3 per SKILL.md)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# poc-drift: §ADR-2 — six silent-on-load-bearing-case gaps surface from W1 Step 2+

poc-drift: §ADR-2 — six silent-on-load-bearing-case gaps surface from W1 Step 2+3 claim-list ↔ #current-evidence diff before runnable PoC

§ADR-2 (Supabase Auth Replaces Custom JWT) covers identity-store + JWT + session + brute-force + RLS data-isolation + EF-middleware RBAC sufficiently, but is silent on six load-bearing cases the current-system replacement must close. Drift surfaces from claim-list extraction (W1 Step 2) cross-referenced against #current evidence (W1 Step 3); no failing test (5b) — pre-PoC because each gap is an architecture-level decision next-impl would otherwise have to make at PoC author-time.

## Evidence
- W1 claim list extracted: C1 unified login endpoint; C2 entity_type via raw_app_meta_data → JWT; C3 RLS Layer-1 isolation; C4 DB-fresh RBAC at EF middleware; C5 gotrue rate-limit replaces custom brute-force; C6 Supabase sessions replace Redis; C7 custom login EF wraps profile.
- #current sources: controllers/UserController.go:148-394 (admin login + 2FA QR-on-login), :833-930 + :1212-1257 (super_admin 2FA toggle/reset); MerchantController.go:351-411 (rate-limit "Too many failed attempts"); ClientController.go:40-98 + PartnerController.go:40-99 (peer login flows); middlewares/jwtAuth.go:11-28 (JWT claim shape); middlewares/rbac.go:25-110 (Permission middleware); middlewares/allowIP.go:14-40 (IP allowlist); middlewares/botAuth.go (bot service auth); controllers/LoginLogController.go.
- Precedent: learning 2026-04-27_incident-2fa-enforcement-on-login-1d746ee-pr — 2FA mandatory on every login since mobiz 1d746ee (#245); broke 35 VAS integration tests; proves G1 is structural not corner.

## Diagnosis
ADR-2 silent on 6 load-bearing cases:
- G1 — 2FA / TOTP migration (Supabase MFA enroll/verify + super_admin reset RPC + QR-on-first-login UX shape — none specified).
- G2 — email-uniqueness across 4 entity types in single auth.users namespace (data-migration shape unspecified; collision currently structurally possible).
- G3 — custom login EF wrap latency budget + shape (couples to §ADR-1 EF cold-start; no cross-ref).
- G4 — LoginLog audit topology vs auth.audit_log_entries (no cross-ref to §ADR-13 D2 audit-trail invariants).
- G5 — IP allowlist placement (out-of-scope for Supabase Auth — EF middleware? gateway? firewall?).
- G6 — bot auth lane disambiguation vs §ADR-6 / §ADR-7 (no explicit OUT-OF-SCOPE).

## Alternatives
(i) Single §ADR-2 amendment covering G1–G6 as sub-sections — coherent surface, one ratification cycle, mirrors §ADR-2 RBAC subsection precedent. Larger amendment.
(ii) Split: §ADR-2 amends G1+G2+G3; cross-ref §ADR-13 for G4; new §ADR-2a for G5+G6 (gateway-layer) — smaller per-decision; more cross-ADR coupling.
(iii) Defer to PoC author-time with [AWAITING_THREAD] markers — rejected per SKILL.md "Threads-first for ambiguity"; reproduces architecture-by-implementation.

Lean: (i).

## Trade-offs
- Complexity: (i) > (ii) per amendment; (ii) couples cross-ADR.
- Time-to-market: (i) one window; (ii) two-or-three.
- Maintainability: (i) wins — full auth contract one read.
- Security surface: equal; G1+G5 closed in both.
- Team familiarity: Supabase MFA + Auth Hooks doc'd; G2 is the unfamiliar cut, same shape in both.

## Scope
single ADR — amends §ADR-2 (Decision + RBAC subsection); G4 cross-refs §ADR-13 D2 without modifying. No [REOPEN_ADR] — fundamentals hold (Supabase Auth as identity store; entity_type via app_metadata; RLS Layer-1; EF Layer-2). Only silent-on-cases need filling.

## Precedent
G1: 2026-04-27_incident-2fa-enforcement-on-login-1d746ee-pr — analogue: #current 2FA enforcement is load-bearing every-login. Chain: #current incident → this #poc-drift §ADR-2 G1.
G2/G3/G4/G5/G6: novel — first observation by impl-architect W1 Step 2+3.

---
*Added via Oracle Learn*
