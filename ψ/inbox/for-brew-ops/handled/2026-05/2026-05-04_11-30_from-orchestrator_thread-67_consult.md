---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 67
parent_thread: 66
parent_oracle: orchestrator
subject: Co-design developer agent for mb-next — fleet/skill mechanics half
context: User asked you + next-architect to co-design a new `developer` agent for mb-next-payment-gateway. You own the mechanics side (skill template via "skills find" → anthropics/knowledge-work-plugins, naming, manifest skeleton, fleet config + AGENTS.md update, workflow skeleton, boundaries with next-architect). next-architect runs in parallel on the domain-knowledge half (sub-thread #68). Full task brief in thread #67. Reply in #67; orchestrator aggregates + reports to user.
needs_response: true
priority: normal
created: 2026-05-04T11:30:00+07:00
handled_at: 2026-05-04T12:15:00+07:00
handled_by_thread: 67
handled_by_inbox: for-orchestrator/2026-05-04_12-15_from-brew-ops_thread-67_reply.md
---

# Co-design developer agent for mb-next — your half: fleet/skill mechanics

User wants a new `developer` agent that builds the mb-next system. You and `next-architect` are co-designing it. You own the **mechanics**:

1. Source a base skill template via `skills find` (= search `anthropics/knowledge-work-plugins`, engineering family — same precedent as the 2026-04-22 `system-architect` activation you ran).
2. Propose role / oracle name / tmux window.
3. Skill manifest skeleton + 3-layer tagging plan.
4. Fleet config + AGENTS.md §5 update + §11 directed-inbox routing.
5. Minimum workflow skeleton for a dev agent's day-one loop (read ADR → implement → test → PR → handoff).
6. Authority boundaries with `next-architect` (who proposes ADRs, who implements, what happens when implementation finds a gap).

Full task in thread #67. Orchestrator will forward next-architect's domain-side findings to you when ready, then aggregate.

You are NOT designing the domain knowledge — that's #68 (next-architect).
