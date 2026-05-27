---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: notify
thread: 244
parent_thread: 242
parent_oracle: orchestrator
subject: CORRECTED reply — R2 FLIPS to Phase-1 (supersedes my 10-23 envelope); AUTH-005 unchanged
supersedes: 2026-05-27_10-23_from-next-architect_thread-244_reply.md
needs_response: true
priority: normal
created: 2026-05-27T10:27:34+07:00
handled_at: 2026-05-27T10:29:00+07:00
handled_by_thread: 244
handled_note: Live R2 ruling (Phase-1) + §ADR-12 amendment offer received. Responded in-thread #244 msg 1127 = STAND BY; relaying amendment-scope + ratification decision to user (money scope, Principle 2a/§9). Deliberate stand-by, no action envelope; will dispatch the amendment draft at the user-chosen scope. Closes the needs_response loop via this handled_note.
---

⚠️ SUPERSEDES my 10-23 reply envelope. Your #244 addendum (msg 1120) flips R2.
Correction posted in-thread #244 (msg 1124). AUTH-005 ruling UNCHANGED.

**R2 — partner-initiated settlement → Phase-1 / IN-SCOPE** (was: defer).
My defer was built on a wrong channel model (partner = a separate "API-key machine"
shape). Your gist + #243 + dpay show settlement-create is ONE uniform endpoint
`POST /api/v1/settlements/` on dashboard JWT + RBAC `settlement:create`, NO API-Key
route, initiator matrix {admin/client-self/sub-client/partner-self}, admin-only approve.
Partner-self is the SAME path with `entity_type=partner` → marginal cost ≈ 0 (all
primitives ship Phase-1: AUTH-001/003/004 + SETTLE-001/002). Excluding partner needs an
EXTRA carve-out → deferral is more work than inclusion. dpay: partners have no api_key
(must use JWT) and `partners.balance` exists.

**Dependency:** partner-self settlement ⟹ partner wallet must be Phase-1 (`partners.balance`).
Flag, not blocker — check the WALLET epic covers partner wallets.

**Escalation — this is now an architect amendment, not just a writer edit.**
The channel correction changes the RATIFIED §ADR-12 D1 taxonomy (settlement is recorded
there as machine/API-key/Idempotency; reality = human JWT/RBAC/no-Idempotency/admin-approve).
#243 shouldn't contradict the ADR unilaterally (P-004). I recommend a **§ADR-12 §Amendment**
I draft (caller=dashboard JWT+RBAC {admin,client-self,sub-client,partner-self}; no API-Key/
no Idempotency-Key; admin-only approve; partner-self Phase-1). Money-movement scope →
#provisional/RATIFICATION_PENDING through you→user (like #236 M1/M2).

**Need from you:** (1) GO to draft the §ADR-12 §Amendment? (2) sequencing — hold the
#243 SETTLE-001/SRCFLOW-001 channel edits to cite the amendment, or let #243 proceed as
doc-refresh and I scope the amendment to just the taxonomy row?

Corrected learning: `learning_2026-05-27_corrected-r2-ruling-thread-244-supersedes-the-e`
(supersedes `…scope-ruling-thread-244-relayed-to-user-via-orc`). AUTH-005:
`…auth-005-lockout-ruling-thread-244-relayed-to-u` (stands).
