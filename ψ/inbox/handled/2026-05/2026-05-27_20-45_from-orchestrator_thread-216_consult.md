---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: consult
thread: 216
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-21-20260526-150518
subject: GATING — does ADR pin production placement+substrate for ADD-3/4/5? Is Bun PoC gateway faithful? (blocks §C.7 topology a/b)
context: see thread #216 msg 1208. User challenges the §C.7 topology: before picking (a) EF-path vs (b) hosted-Bun-gateway, is the production placement+substrate for rate-limit (ADD-3, §ADR-7/11 "Postgres counter, edge-layer"), auth/RBAC/RLS (ADD-4, AUTH-003 "EF RBAC + RLS", §ADR-2/13), idempotency (ADD-5, CLIENT-001 §ADR-11 "shared-middleware + DB dedup") ratified in the ADRs? Is the poc Bun gateway a faithful stand-in or a PoC artifact? Which §C.7 topology is faithful (a/b/neither)? If ADRs don't pin it → flag the gap + recommend placement → escalate to user. Read docs/adr.md + epics DIRECTLY (vector index degraded, brew-ops #253). Holding §C.7 Medium run until grounded.
needs_response: true
priority: high
created: 2026-05-27T20:45:00+07:00
handled_at: 2026-05-27T21:50:00+07:00
handled_by_thread: 216
handled_by_inbox: ψ/inbox/for-orchestrator/2026-05-27_14-50_from-next-architect_thread-216_reply.md
handled_note: GATING answered — placement IS pinned (EF middleware chain; gateway REJECTED §ADR-2 G5-D); §C.7 topology (a) faithful / (b) unfaithful; real gap = PoC EF-middleware fidelity (auth stub + rate-limit absent); rec = (A) complete-EF-middleware-then-run vs (B) run-now-and-scope → escalate to user; thread #216 msg 1209.
---

Full brief in thread #216 (msg 1208). Gating question — read the actual ADRs + answer: per-concern production placement+substrate (cited) for ADD-3/4/5, whether the Bun PoC gateway is faithful, and the faithful §C.7 topology (a/b/neither, or the placement gap + your recommendation). §C.7 Medium run is held until this is answered. Reply on thread #216.
