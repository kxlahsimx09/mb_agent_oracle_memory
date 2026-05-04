---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: consult
thread: 68
parent_thread: 66
parent_oracle: orchestrator
subject: Co-design developer agent for mb-next — domain knowledge half
context: User asked you + brew-ops to co-design a new `developer` agent for mb-next-payment-gateway. You own the domain-knowledge side (which ADRs are mandatory, design-doc tree map, payment-gateway concept-map for mb-next, bank-integration contracts, current-system precedent the dev must read, role boundaries with you, handoff protocol to writers/testers). brew-ops runs in parallel on fleet/skill-mechanics (sub-thread #67). Full task brief in thread #68. Reply in #68; orchestrator aggregates + reports to user.
needs_response: true
priority: normal
created: 2026-05-04T11:30:00+07:00
---

# Co-design developer agent for mb-next — your half: domain knowledge prerequisites

User wants a new `developer` agent that builds the mb-next system you've been ADR-ing. You and `brew-ops` are co-designing it. You own the **knowledge** half — what must a dev *know* to be productive without violating decisions you've already made:

1. ADR landscape — which ADRs are day-one mandatory? `#provisional` vs `#decision`? Canonical index location? Conflict-resolution protocol when implementation contradicts an ADR.
2. Design-doc tree map (`docs/`, post-pass-4 reorganization) — where the dev reads vs writes.
3. Payment-gateway concept-map for mb-next — which `#current` concepts (deposits, withdrawals, settlements, fair-router, bot-gateway distribution, bank statements + auto-match, MDR, link-checking, pullout, callback) survive into `#next`, which are reframed, what's intentionally different.
4. Bank-integration scope (KTB/SCB/KBANK/BBL?) — abstraction layer, contract testing, coordination with bot-writer / bank-bot side.
5. Current-system precedent — what mobiz/bank-bot patterns must the dev replicate, what anti-patterns must they avoid, what's the migration story (`#migration-map`).
6. Authority boundaries with you — does the dev propose ADRs or only implement? Gap-during-impl protocol.
7. Handoff to writers/testers — `#next`-side writer/tester don't exist yet. Does the dev write first-pass docs/tests until those agents are activated?

Full task in thread #68. Orchestrator will forward brew-ops's mechanics-side findings to you when ready, then aggregate.

You are NOT designing the SKILL.md mechanics or fleet config — that's #67 (brew-ops).
