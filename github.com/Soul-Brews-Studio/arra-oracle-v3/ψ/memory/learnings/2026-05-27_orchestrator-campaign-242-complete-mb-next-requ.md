---
title: orchestrator campaign #242 COMPLETE — mb-next requirement remediation arc (revie
tags: []
created: 2026-05-27
source: orchestrator / parent thread #242 (2026-05-27)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator campaign #242 COMPLETE — mb-next requirement remediation arc (revie

orchestrator campaign #242 COMPLETE — mb-next requirement remediation arc (review → §ADR-12 + §ADR-8 amendments → SETTLE batch), all merged

tags: [orchestrator, decision-authority, fan-out, requirement-remediation, settlement-channel, adr-amendment, ratification, money-scope, relay-not-decide, sequential-merge-cadence, next-writer, next-architect, thread-242, repo:arra-oracle-v3, mb-next-payment-gateway, fleet, accepted]
source: parent #242 (subs #243 next-writer / #244 next-architect / #245+#247 brew-ops / #246 writer↔architect), 2026-05-27; user direct-CLI orchestrator session.

ARC (one user request "re-check mb-next requirements" → a full remediation, all user-ratified, all merged):
1. #239 two-lens review (next-writer internal-completeness × pg-writer vs-production) → surface substantially complete; remaining = R1 (§ADR-8 A2 9th-filter propagation) + B1/B2 (Pullout demand-refill default-OFF, DTR refund wallet capture) + R2 (partner-settlement scope) + AUTH-005 (lockout lifecycle).
2. User-directed SETTLE finding (client uses UI not API) → architect (P-004) caught it contradicts the RATIFIED §ADR-12 D1 taxonomy → required a §ADR-12 §Amendment, NOT a doc-edit. User ratified FULL scope (channel=dashboard JWT+RBAC, no API-Key/Idempotency-Key, partner-self Phase-1, partner-wallet pre-satisfied by §ADR-10). PR #262.
3. R2 flipped defer→Phase-1 after the orchestrator relayed the gist/channel evidence (partner-self is the same uniform JWT path → excluding costs more than including).
4. User-FOUND R1 over-generalization in PR #261 ("filter applies to every withdrawal source") → orchestrator dispatched correction → next-writer scoped it to fair-router/payout + ESCALATED a deeper money-gap to architect (#246).
5. §ADR-8 AF3 (fair-router scope, architect authority) + AF4 money-gap (21,886 uncapped >50k txns) → user ratified (A) faithful-port; (B) recorded deferred (revisit=DT-refund Phase-2). PR #263.
6. SETTLE batch (PR #264). AUTH-005 user-HELD.

DECISION-AUTHORITY PATTERNS (all user reactions = accepted/ratified, none corrected):
- Money-movement scope (settlement channel as ratified-ADR change; partner-self Phase-1; AF4 cap-enforcement) → ALWAYS escalated to user, never orchestrator-decided (Principle 2a + §9). User ratified each.
- relay-not-decide propagated DOWN the chain: next-writer escalated the AF4 money-gap to the architect instead of deciding; the architect routed AF4 to the user instead of self-binding. The discipline held at every level.
- A doc-fix can detonate into a ratified-ADR amendment: the "UI not API" SETTLE edit looked trivial but contradicted §ADR-12 D1's ratified core → architect amendment + user ratification. Always check whether a "faithfulness fix" touches a ratified ADR before treating it as a writer doc-edit.
- User catches real errors in agent output (the R1 over-generalization) — surface PRs for review BEFORE merge; the user's find prevented a wrong scope baking into the requirement surface.
- Sequential-merge cadence honored: PR #261 merged before the SETTLE batch (both touch epic-source-flows.md) to avoid append-region conflict; ADR PRs (#262/#263) merged independently (docs/adr.md, no overlap).
- Two orthogonal review lenses stay non-redundant on a second pass (pg-writer found silent production-behavior drops the internal pass structurally can't see).

OPS SIDE-EFFECTS this campaign surfaced: (a) the orchestrator §11l whole-dir Stop-hook false-blocks concurrent sessions on sibling-owned envelopes → fixed by PR #108 (#238), needs post-merge install-hook redeploy; (b) wt-22's active p2p-hub campaign accumulates unarchived #232 envelopes → brew-ops #247. Held the line on sibling (#232) envelopes ~6× rather than corrupt wt-22's audit trail (P-001).

---
*Added via Oracle Learn*
