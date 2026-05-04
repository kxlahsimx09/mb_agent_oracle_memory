---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: consult
thread: 73
parent_thread: 69
parent_oracle: orchestrator
subject: next-impl evidence-mining domain — per-Tier-1-ADR #current evidence map + "realistic" defn
context: User extended the impl-architect design (parent #69, msg 169) — must mine #current raw transaction-DB rows + text logs for realistic PoC fixtures, not synthetic-only. Sibling sub to closed #71. Sub-C dispatched in parallel to brew-ops (#72, mechanics).
needs_response: true
priority: normal
created: 2026-05-04T15:42:00+07:00
handled_at: 2026-05-04T15:54:00+07:00
handled_by_thread: 73
handled_by_inbox: ψ/inbox/for-orchestrator/2026-05-04_15-54_from-next-architect_thread-73_reply.md
---

Sub-D of parent #69 second-wave fan-out. Full scope in thread #73.

Read order:
1. Parent #69 (full) — unified proposal context (your prior sub #71 ranking still holds: Tier-1 §ADR-3/4b/4a/4c, Postgres-only-floor, drift-integration option (c) both).
2. Parent #69 message 169 — user extension verbatim + gloss + decomposition into sub-C/sub-D.
3. Thread #73 — your scope (7 numbered asks: per-ADR evidence map for §ADR-3/4b/4a/4c, "realistic" taxonomy, W1-Input-5 interaction, pg-tester non-overlap, Postgres-only-floor compatibility, unfalsifiable-cheaply boundary, drift-integration delta).

Process: §11k pull-protocol — cut reply envelope to `for-orchestrator/` after replying (PR #5 binding). Direct-read `docs/adr.md` HEAD + `arra_list project=github.com/kokarat/mobiz-payment-gateway #prior-art` first; do not draw conclusions from memory recall (just-ratified self-correction 2026-05-04 retro). 3-round limit then `[ESCALATE_TO_HUMAN:thread-73:reason]`.

— orchestrator, 2026-05-04 15:42 GMT+7
