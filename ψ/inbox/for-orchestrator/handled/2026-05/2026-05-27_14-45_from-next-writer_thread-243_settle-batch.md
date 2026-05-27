---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: notify
thread: 243
parent_thread: 242
parent_oracle: orchestrator
subject: SETTLE batch DONE — PR #264 (SETTLE-001/002 + SRCFLOW-001 + WALLET SC4 + DEPOSIT-011 pin), cites ratified §ADR-12 §Amendment 2026-05-27 + §ADR-8 AF4
needs_response: true
priority: normal
created: 2026-05-27T14:45:26+07:00
handled_at: 2026-05-27T14:48:00+07:00
handled_by_thread: 243
handled_note: SETTLE batch PR #264 delivered (all 5 items) — completes #243 authoring scope. Responded in-thread #243 msg 1156 (closing ack); #243 CLOSED. PR #264 surfaced to user for review/merge. AUTH-005 stays held (separate task). Deliberate closing-ack, no action envelope (next-writer's authoring complete). Closes needs_response loop via handled_note.
---

SETTLE batch delivered in thread #243 (msg 1155).

**PR #264** — https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/264
branch `next-writer/settle-batch-243` off updated main @e958bc8. Five items, all citing
ratified §ADR-12 §Amendment 2026-05-27 (SC1-4, #262) + §ADR-8 §Scope-correction AF4 (#246).
P-004 throughout; no substrate change.

1. SETTLE-001 — dashboard JWT + RBAC `settlement:create` (NOT API-Key, NO Idempotency-Key);
   initiator {admin·client-self·sub-client·partner-self}; [open question partner Phase-1?]
   RESOLVED → IN-SCOPE (SC3); enqueue moved create→admin-approve (freeze@create M1,
   EnqueueWithdrawal source_type=settlement priority 4 @approve).
2. SETTLE-002 — admin-only approve→enqueue (freeze settles out on bank-success); entity_type=partner
   on admin-create; reject-release owner-agnostic.
3. SRCFLOW-001 — single Settlement (dashboard) taxonomy row replacing the machine/API-Key + admin-UI
   rows; settlement off the Idempotency-Key surface; taxonomy 4 rows.
4. WALLET-epic SC4 — "partners never freeze" corrected at the 3 named spots (WALLET-001/003/005);
   partner-self settlement freezes a partner wallet; owner-agnostic (§ADR-10 D1+AM6 + §ADR-12 M1);
   MDR fan-out still credits balance only. No substrate change.
5. DEPOSIT-011 pin — 1-line deferred-defense-in-depth cross-ref → §ADR-8 §Scope-correction AF4(B).

Trust: SETTLE-001 S2 (now genuinely ADR-backed); SETTLE-002 S3; WALLET unchanged S2.

Closes the SETTLE/R2 hold. **AUTH-005 (`epic-auth-rbac.md`) was NOT in this batch — still awaiting
your separate dispatch (architect #244 flagged it as a distinct `epic-auth-rbac.md` writer task).**

Learning: `2026-05-27_settle-batch-pr-264-dashboard-jwt-partner-self-phase1`.
