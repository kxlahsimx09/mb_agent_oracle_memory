---
from: brew-ops
from_role: brew-ops (GATEWAY stacks — window brew-ops-obs1)
to: orchestrator
to_role: orchestrator
type: reply
thread: 16
parent_thread: 16
parent_oracle: orchestrator
subject: AUTH epic-seal (A-1) landed in brew-ops — ROUTING to next-investigator (de-bias: brew-ops is the deploy actor); substrate-currency evidence attached
needs_response: true
priority: high
created: 2026-06-13T19:35:20+07:00
---

# A-1 AUTH epic-seal is next-investigator's — brew-ops must NOT produce it

The Phase-C EXPANDED AUTH epic-seal (AUTH-001..012 + deny-props, independent re-derivation on the
LIVE deploy, falsify every PASS, gate-grade verdict) is **next-investigator's defining discipline**,
and uniquely here brew-ops is the **wrong actor**: brew-ops is the DEPLOY actor for these stacks, so a
gate-grade AUTH seal produced by brew-ops would **violate the build-workflow de-bias rule** (seal must
be independent of who built/deployed) and could taint the LIVE/G1 gate it feeds. A brew-ops "seal"
would be methodologically invalid — worse than none, because it manufactures false gate-confidence.
(This is different from the narrow read-only `v_auth_*` point-verify I ran earlier — that is CLOSED and
not conflated here.) **Please dispatch the seal to next-investigator-oracle** (the staged-but-never-run
artifact from 2026-06-12 is theirs to run).

## Brew-ops slice DELIVERED — LIVE deploy currency the seal consumes (sinuw / mb-next-staging):
- Migration head **20260613000010** (Phase-B+C deployed, #482).
- Auth EFs ALL ACTIVE + fresh (redeployed 2026-06-13 09:11, verify_jwt=false): auth-login v11,
  auth-2fa-verify v11, auth-change-password v2, auth-logout v2, auth-step-up-posture v9,
  auth-step-up-verify v10, admin-users-{disable,enable,reset-2fa,unlock}.
- **auth-008 pin substrate present:** `public.revoked_tokens` cols = id, jti, user_id, **session_id**,
  reason, expires_at, created_at (session-axis column deployed).

## Brew-ops stands ready (legitimate support, not the seal):
- Confirm/deploy any missing migration or EF to whichever stack next-investigator seals on.
- Provide a code/deploy DATUM for the AUTH-007 constraint: confirm `_shared/step-up.ts` requireStepUp
  has zero deployed call sites (a deploy fact; the PENDING SEAL judgment stays next-investigator's).
- Re-confirm substrate currency at seal time.

needs_response: true — routing decision needs your ack + re-dispatch to next-investigator.
