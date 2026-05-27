---
title: AUTH-005 lockout ruling (thread #244, relayed to user) — Supabase platform-deleg
tags: [system-architect, repo:mb-next-payment-gateway, next, auth, rbac, scope, decision, security, supabase, adr-2, provisional]
created: 2026-05-27
source: thread #244 ruling AUTH-005; Supabase GoTrue capability (banned_until/ban_duration + endpoint rate-limits); docs/requirements/epic-auth-rbac.md AUTH-002/005
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# AUTH-005 lockout ruling (thread #244, relayed to user) — Supabase platform-deleg

AUTH-005 lockout ruling (thread #244, relayed to user) — Supabase platform-delegation does NOT cover the account-lockout lifecycle; it is application logic built on the platform's ban primitive. Needs a small next-writer follow-up. Companion to the R2 partner-settlement ruling in the same thread.

## Question
AUTH-005 delegates session/brute-force "to the platform." Does Supabase Auth cover the production permanent-lock + admin-unlock lifecycle? Production (`helpers/login_lock.go`, MaxLoginAttempts=5): 5 failed logins → lock, in TWO regimes — admin/`users` = **permanent** `is_locked=true`, admin-unlock only (no TTL); merchant/client/partner = **15-min** auto-expiry (Redis window).

## Verify-not-assert — what Supabase Auth (GoTrue) actually provides
- **Endpoint rate-limiting**: YES — per-window sign-in rate limits. This genuinely covers AUTH-005's "an attacker cannot hammer the login endpoint." Delegation is correct HERE.
- **Auto-lock after N consecutive failures**: NO — GoTrue has no `failed_login_attempts` counter + auto-lock. Must be application logic (a counter, exactly like current `login_lock.go`).
- **Two-regime unlock policy** (permanent-admin-unlock vs time-boxed auto-expiry): NO — not a platform feature.
- **Admin-unlock action** (clear a locked account): NO — a real operator support surface, not an AC anywhere today.
- **Enforcement PRIMITIVE available to build on**: YES — `auth.users.banned_until` / Admin-API `ban_duration` ('none' to clear). Permanent lock = ban cleared only by admin; time-boxed = `ban_duration:'15m'` auto-expires. Platform gives the enforcement hook; the trigger + policy + unlock workflow are app logic.

## Ruling
NOT fully platform-covered. AUTH-005 over-claims by folding "brute-force" under "rate-limited by the platform." Split needed: rate-limiting = platform (delegation correct); account-lockout = application logic on the `banned_until` primitive.

## Where it lands (the lock half already exists)
AUTH-002 already owns the lock (AC#5 "account is locked... visible to operators" + data source `is_locked`/`failed_login_attempts`/`locked_at`). The MISSING half = the **unlock lifecycle + two-regime + admin-unlock action**. Recommend folding into AUTH-002 (lighter than a new AUTH-008): add (a) unlock lifecycle AC/edge — two regimes + admin-unlock; (b) correct AUTH-005's edge to scope platform-delegation to rate-limiting and name the lockout as app-logic-on-`banned_until`.

## Security framing / ratification
This is faithful-to-current (inherit the existing lock-after-5 + two-regime + admin-unlock), NOT a novel security posture (unlike AUTH-007 fail-closed, which needed #236 human ratification). The writer can document it as preserve-current (S4-style, impl literals 5/15min deferred) WITHOUT a new §ADR-2 clause. The ONE genuinely architectural sub-decision: keep the two-regime asymmetry (high-privilege internal accounts lock hard + admin-reviewed; external tenants lock soft + self-recover — a sensible risk-tiered policy, recommend KEEP) vs unify. If the two-regime is elevated to a binding next-system #decision (beyond "inherit current"), that warrants a §ADR-2 line + user sign-off — user's call via the orchestrator relay.

## Epic-edit implication → next-writer follow-up (epic-auth-rbac.md)
Separate from #243 sub-A (which touches epic-source-flows + epic-bot-dispatch, NOT epic-auth-rbac) — sequence as its own writer task after this ruling.

---
*Added via Oracle Learn*
