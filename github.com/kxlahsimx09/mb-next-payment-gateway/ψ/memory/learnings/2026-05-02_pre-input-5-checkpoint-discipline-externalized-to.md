---
title: Pre-Input-5 checkpoint discipline externalized to brew-ops via arra_handoff (202
tags: [system-architect, repo:mb-next-payment-gateway, repo:cross, next, process-improvement, pre-input-5-checkpoint, brew-ops-handoff, externalization, workflow-improvement, discipline-naming, instance-7-past-state, instance-8-future-state-speculation, bidirectional-discipline, projection-honored]
created: 2026-05-02
source: arra_handoff filed 2026-05-02 GMT+7 to brew-ops; §ADR-9 pass-1 retro projection honored after instance #7+#8 triggered in §ADR-12 lifecycle
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Pre-Input-5 checkpoint discipline externalized to brew-ops via arra_handoff (202

Pre-Input-5 checkpoint discipline externalized to brew-ops via arra_handoff (2026-05-02 GMT+7 — handoff slug pre-input-5-checkpoint-escalation-instance-7-8).

§ADR-9 pass-1 retro (2026-04-30) projected: "if next architectural pass surfaces another instance, externalize via brew-ops without further iteration". §ADR-12 lifecycle (2026-05-02) triggered both an instance #7 (Settlement caller — past-state claim wrong; caught via PR #235 evidence) and an instance #8 (Phase-2 auto-recurring — future-state speculation without driver; caught via user evidence-check). Both within single ADR baseline. **Trigger honored: handoff filed.**

Handoff content covered:
- TL;DR: §ADR-9 retro projected externalization; §ADR-12 triggered; pattern is workflow-level
- Context: what Pre-Input-5 is (implicit in W1 anti-patterns; not explicit Step 4 sub-rule)
- Two instances (#7 + #8) — past-state + future-state directions
- Why externalize now (5 reasons: projection commitment, durable pattern, bidirectional emerged, process debt, cognitive load)
- 3 specific updates suggested for W1 workflow doc:
  1. Step 4 sub-rule naming Pre-Input-5 checkpoint explicitly + bidirectional scope
  2. Anti-pattern: Speculative future-state staging without driver
  3. Optional: maintenance-pass mode after ≥3 ratifications
- Cumulative instance table (#1-#8 across 9 calendar days)
- References to triggering retros + learnings + commits + PRs

Discipline naming surfaced two additions:
1. **Bidirectional Pre-Input-5 checkpoint** — covers both past-state ("current does X") and future-state speculation ("Phase-2 will need Y"). Both directions = "claim without verification" class.
2. **Future-ADR-placeholder-as-deferred-question pattern** (NEW; instance #1 from §ADR-12 §Deferred) — when speculative future emerges without driver, name placeholder ADR + driver shape in §Deferred; less architectural debt than committing Phase-2 staging.

Handoff is fire-and-forget — brew-ops triages independently. system-architect's next architectural work proceeds on Admin-API ADR or pauses for cognitive recovery, decoupled from handoff resolution.

Process pattern this externalizes:

| Discipline name | Tracked by | Originally in |
|---|---|---|
| Pre-Input-5 checkpoint (past-state) | retros, instance count | implicit in W1 anti-patterns |
| Pre-Input-5 checkpoint (future-state speculation) | retros, instance #8 | discovered 2026-05-02 |

After brew-ops update, both are: explicit in W1 Step 4 sub-rule + Anti-pattern section.

Lesson: when a pattern reaches durability (≥6-8 instances) AND a retro projects externalization on next trigger, file the handoff promptly when triggered. Don't accumulate further instances; the discipline is durable enough for workflow-level naming.

Process debt this clears: 3 days of "instance #7 not yet triggered; standby" projection-state. Now closed.

Cumulative instance count externalized: 8 (1 per ~1.1 calendar days from 2026-04-23 to 2026-05-02). Frequency: ~1 per ADR baseline pass.

Trace candidate: this learning chains from the maintenance pass trace (132d6259) since both are part of the post-ratification housekeeping arc. Or stands alone as discipline-externalization event.

Ratification: not needed (process improvement; brew-ops decides workflow doc updates). Threads opened: none. PR: N/A (handoff is memory primitive, not code change).

Next steps from system-architect side: Admin-API surface ADR (last remaining major architectural gap; 90-120 min) or pause for cognitive recovery. Both decoupled from handoff resolution.

---
*Added via Oracle Learn*
