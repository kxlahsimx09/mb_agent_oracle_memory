---
title: refresh-on-amendment — AUTH-005 lockout-lifecycle fix (thread #249) — over-claim
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, refresh-on-amendment, auth-rbac, auth-005, auth-002, lockout, login-lock, two-regime, admin-unlock, banned_until, supabase, preserve-current, s4-reverse-engineered, p-004, thread-249, thread-244]
created: 2026-05-27
source: docs/requirements/epic-auth-rbac.md@e6191e0 + mobiz helpers/login_lock.go + helpers/cache.go + architect ruling thread #244
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# refresh-on-amendment — AUTH-005 lockout-lifecycle fix (thread #249) — over-claim

refresh-on-amendment — AUTH-005 lockout-lifecycle fix (thread #249) — over-claim corrected + unlock lifecycle/two-regimes/admin-unlock added, preserve-current, NO new ADR.

What changed (epic-auth-rbac.md, AUTH-005 story + INDEX row):
- CORRECTED the over-claim that folded brute-force lockout under "rate-limited by the platform." Split into two distinct defenses: (1) sign-in ENDPOINT rate-limit = genuinely platform-delegated (Supabase GoTrue) ✓ kept; (2) account-LOCKOUT lifecycle = application logic on the platform's `banned_until`/`ban_duration` ban primitive — NOT Supabase-covered (GoTrue has no lock-after-N counter, no two-regime unlock, no admin-unlock action).
- ADDED the unlock lifecycle: auto-lock after 5 consecutive failures; TWO REGIMES — internal `users`/admin = permanent hard lock, super-admin-unlock only (no TTL); external tenants (merchant/client/sub-client/partner) = ~15-min soft auto-expiry; admin-unlock clears the lock + resets the failed-attempt count.
- Cross-ref AUTH-002 (the lock half + operator-visibility already lives there; AUTH-005 owns the unlock lifecycle). Left AUTH-002 untouched per brief.
- Flagged the HELD item: elevating the two-regime asymmetry to a binding next-system #decision needs a §ADR-2 line + user sign-off — documented as faithful-to-current until then.

Trust: story heading stays [S2 ratified] (core audit/IP/endpoint-rate-limit is §ADR-2 G4-D/G5-D · §ADR-13 D2 ratified); lockout additions flagged inline as preserve-current/S4, literals (5 / 15-min) = current-prod baselines NOT ratified — same convention as AUTH-006 caps / AUTH-007 under an S2 heading.

P-004 grounding (verified against current code, not assumed): mobiz `helpers/login_lock.go` (`MaxLoginAttempts = 5`; `users` → permanent `is_locked=true`+`locked_at`, no TTL; `UnlockAccount` clears `is_locked`/`failed_login_attempts`/`locked_at`; admin-unlock route `PUT /:id/unlock` guarded `RequireRole(RoleSuperAdmin)`) + `helpers/cache.go` (`CacheTTL.LoginFailed = 15 * time.Minute`); external tiers use a Redis failed-attempt counter checked `>= 5` over the 15-min window. Code-finder confirmed all 6 claims; precision note: sub_client is in the external/Redis regime too (brief said merchant/client/partner) — included for faithfulness.

Authoritative source: architect ruling learning `2026-05-27_auth-005-lockout-ruling-thread-244-relayed-to-u` (thread #244). Classification per [[feedback_writer_fix_contradicts_ratified_adr]] = type (b) grounding-not-contradicting (architect pre-ruled preserve-current) → cleared to write, no architect amendment needed.

PR: writer/auth-005-lockout-lifecycle-249. File: docs/requirements/epic-auth-rbac.md@e6191e0 (+ INDEX.md row). Mermaid gate green (5/5 blocks); MDX brace/kramdown scan clean.

---
*Added via Oracle Learn*
