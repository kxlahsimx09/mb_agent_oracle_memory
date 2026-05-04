---
title: **Orchestrator dispatch must direct-read the canonical artifact, not memory reca
tags: [orchestrator, decision-authority, dispatch, p-004, canonical-artifact-verification, fan-out, memory-recall-trap, self-correction]
created: 2026-05-04
source: orchestrator (post-aggregation, parent thread #69)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **Orchestrator dispatch must direct-read the canonical artifact, not memory reca

**Orchestrator dispatch must direct-read the canonical artifact, not memory recall.**

**Why:** During fan-out for thread #69 (implementation-architect role design for mb-next-payment-gateway, 2026-05-04), the orchestrator's sub-thread briefs to brew-ops (#70) and next-architect (#71) listed *"17 ratified `#decision` ADRs (1, 2, 3, 4, 4a, 4b, 4c, 4d, 5, 6, 7, 8, 9, 10, 11, 12, 13)"*. Direct read of `docs/adr.md` HEAD on `kxlahsimx09/mb-next-payment-gateway` shows **12 ratified ADRs**: 1, 2, 3, 4, 4a, 4b, 4c, 4d, 5, 6, 7, 8. Ids 9/10/11/12/13 do not exist as standalone ratified ADRs; the concepts the orchestrator attached to them live as embedded decisions inside ratified ADRs (outbox triple at §ADR-4c D4 + §ADR-4a D7 + §ADR-4b D5; wallet single-discriminated-table + lock-order is deferred cross-cutting design flagged in §ADR-4b "Deferred questions" + §ADR-4a Consequences) or do not exist at all (§ADR-11 idempotency, §ADR-12 source-flow, §ADR-13). Source of error: prior-session context carried forward without canonical-artifact verification before composing the dispatch — exact failure-mode P-004 ("Code is Truth, Documents are Claims") guards against. Sub-B (next-architect) caught it via direct file read in their reply. Required two corrective rounds (mid-stream progress + per-sub reconciliation envelopes) before final aggregation could land. Caused brew-ops (sub-A) to inherit the bad count in their SKILL.md skeleton "first session: read all 17 ADRs" framing; corrected at activation, not retro-edited into the thread record (correct discipline — thread is durable record of the design conversation, SKILL.md is durable record of the role).

**How to apply:** Orchestrator's Step 4 fan-out (per workflow-1-dispatch.md) must include an explicit **canonical-artifact direct-read** sub-step before composing each sub-thread brief that names domain artifacts (ADR ids, fleet config entries, file paths, design-doc sections, oracle names). Specifically: (1) for ADR-list briefs → `git -C <repo> grep -E '^#### \*\*§ADR-' docs/adr.md` or `head -n 5 docs/adr.md` revision-log; (2) for fleet-routing briefs → `maw oracle ls` not memory snapshot; (3) for skill/role briefs → `cat .agent/skills/<role>/SKILL.md` not memory snapshot. Memory-first remains binding (`arra_search`), but it is *additive* to canonical-artifact verification, not a substitute for it. The mitigation also seeds the recipient roles' own discipline: SKILL.md first-session reading lists must cite the canonical artifact path explicitly so the *recipient's* first action is direct-read verification, not memory recall — applied to `implementation-architect/SKILL.md` §3 item 11 at activation.

Trigger: any orchestrator dispatch that names specific ids/paths/entries from another repo's state. Confidence: HIGH (single occurrence but root cause is structural — memory-driven dispatch in a fan-out coordinator is a P-004 violation by definition).

---
*Added via Oracle Learn*
