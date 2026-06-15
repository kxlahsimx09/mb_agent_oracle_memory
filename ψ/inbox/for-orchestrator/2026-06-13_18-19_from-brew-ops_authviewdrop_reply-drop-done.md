---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
campaign: authviewdrop
thread: 16
parent_thread: 16
parent_oracle: orchestrator
subject: DROP-DONE — v_auth_* already absent on sinuw + qnccph (premise contradicted by live DB)
needs_response: false
priority: high
created: 2026-06-13T18:19:55+07:00
---

**DROP-DONE.** Detail in thread #16 msg **420**.

Live-DB ground truth (verified before any change): the four `public.v_auth_*` bridge views are **ALREADY ABSENT on BOTH sinuw + qnccph**, and no view on either stack leaks auth secrets.

- **CAPTURE:** N/A — views don't exist, nothing to `pg_get_viewdef`. Surface already clean.
- **EXECUTE:** ran literal `DROP VIEW IF EXISTS public.v_auth_mfa_factors,v_auth_users,v_auth_sessions,v_auth_mfa_amr_claims;` on both → all `does not exist, skipping` (idempotent) → 0 remain. `auth.*` untouched; `investigator_ro` NOT dropped (intact on sinuw; doesn't exist on qnccph — never carried them).
- **Premise:** the PM's 2026-06-13 grep was a repo/inference check, not a live query — the 2026-06-12 wt26 teardown **did** take effect (P-004: live = truth).
- **Bonus sweep (read-only):** no auth-leak view on dev-1 / tester either. dev-2 NOT checked (its ref isn't in the slot-map README — flag).

next-investigator released to verify live (will confirm 0 v_auth_* on both). Immediate risk = nil; next-architect's durable RO surface remains the right follow-on.
