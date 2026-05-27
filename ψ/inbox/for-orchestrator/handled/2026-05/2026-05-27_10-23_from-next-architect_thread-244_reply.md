---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: notify
thread: 244
parent_thread: 242
parent_oracle: orchestrator
subject: Reply — R2 (defer partner-initiated settlement) + AUTH-005 (lockout = app-logic, not platform)
needs_response: false
priority: normal
created: 2026-05-27T10:23:06+07:00
handled_at: 2026-05-27T10:29:00+07:00
handled_by_thread: 244
handled_note: SUPERSEDED by the 10-27 corrected envelope (R2 flipped defer→Phase-1). notify/needs_response=false. Live ruling handled via #244 reply msg 1127.
---

Sub-B rulings delivered in thread #244 (msg 1122). Both P-004-verified, not asserted.

**R2 — partner-initiated settlement → DEFER to Phase-2 (partner NOT dropped).**
Phase-1 settlement = client-API (SETTLE-001) + admin create/review (SETTLE-002); the one
active partner is served Phase-1 via admin-create with `entity_type=partner` permitted.
dpay 2026-05-27: the 140 partner settlements (4.7%) are partner-INITIATED (`created_by_type
=partner`, one account "ownner-mdr"; admin only approves) via **dashboard login — partners
have no API key**. That's a third caller-shape §ADR-12 D1 doesn't model; not worth a
self-service surface for one tenant. Zero-risk defer (shared rails). **No ADR amendment.**

**AUTH-005 — Supabase does NOT fully cover lockout. → edit needed.**
Rate-limiting IS platform-delegated (✓ "can't hammer the endpoint"); the lockout lifecycle
(auto-lock-after-5, two-regime, admin-unlock) is **app logic on the `banned_until` ban
primitive** — AUTH-005 over-claims it. Lock half already in AUTH-002; missing = unlock +
two regimes + admin-unlock. Faithful-to-current (not a novel posture like AUTH-007), closes
as preserve-current without a new §ADR-2 clause. KEEP the risk-tiered two-regime asymmetry;
elevating it to a binding #decision is the only bit needing a §ADR-2 line + user sign-off.

**Epic edits (both next-writer follow-ups):**
- R2 → `epic-source-flows.md` — **foldable into #243 sub-A** (same file, B1/B2).
- AUTH-005 → `epic-auth-rbac.md` — **separate** from #243 (different file); own writer task.

Learnings: `2026-05-27_scope-ruling-thread-244-relayed-to-user-via-orc` (R2) +
`2026-05-27_auth-005-lockout-ruling-thread-244-relayed-to-u` (AUTH-005). Ready to converge.
