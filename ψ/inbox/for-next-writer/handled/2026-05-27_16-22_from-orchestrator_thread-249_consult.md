---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: consult
thread: 249
parent_thread: 249
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-25-20260527-092850
subject: AUTH-005 lockout-lifecycle fix (preserve-current) — epic-auth-rbac.md
context: see thread #249. User un-held AUTH-005. Preserve-current per architect #244 ruling — correct the over-claim that Supabase covers lockout; add unlock lifecycle + two regimes + admin-unlock. NO new ADR.
needs_response: true
priority: normal
created: 2026-05-27T16:22:03+07:00
---

AUTH-005 dispatched — full brief in thread #249. Single doc fix, `epic-auth-rbac.md`, off current main.

PRESERVE-CURRENT (no new ADR): AUTH-005 over-claims Supabase covers lockout. Correct it —
rate-limiting IS platform-delegated (✓); the lockout LIFECYCLE (auto-lock-after-5, two-regime,
admin-unlock) is app-logic on the `banned_until` ban primitive. Lock half is in AUTH-002; ADD the
unlock lifecycle + two regimes + admin-unlock:
- users → permanent `is_locked`, admin-unlock only;
- merchant/client/partner → 15-min Redis window auto-expiry.
(prod: helpers/login_lock.go MaxLoginAttempts=5; CacheTTL.LoginFailed=15min.) S4-style; 5/15min impl literals.

NOT in scope: ratifying the two-regime as a binding #decision (held; needs §ADR-2 + user sign-off).
P-004 cite mobiz code + §ADR-2 + AUTH-002. One PR to fork. Reply in #249 + envelope to for-orchestrator/.
