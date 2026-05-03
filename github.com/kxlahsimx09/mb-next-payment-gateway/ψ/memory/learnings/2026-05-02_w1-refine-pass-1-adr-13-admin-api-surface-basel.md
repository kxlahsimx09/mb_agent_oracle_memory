---
title: W1 refine pass 1 — §ADR-13 Admin-API Surface baseline (`#provisional` `[RATIFICA
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-13, admin-api-surface, baseline, pass-1, provisional, ratification-pending, smallest-baseline-66-lines, lessons-from-adr-12-applied, 10-adrs-architecture-decision-phase-milestone, coordination-rule-instance-4, future-adr-placeholder-instances-2-3, thread-61-opened, thread-45-stays-open]
created: 2026-05-02
source: docs/adr.md@b3716d3 §ADR-13 + thread #61 messages + 3 mobiz learnings + §ADR-12 lessons applied
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine pass 1 — §ADR-13 Admin-API Surface baseline (`#provisional` `[RATIFICA

W1 refine pass 1 — §ADR-13 Admin-API Surface baseline (`#provisional` `[RATIFICATION_PENDING:61]`).

Closes the LAST remaining major architectural gap in deposit + payout core architecture. Architecture-decision phase substantially complete after §ADR-13 ratification — 10 ADRs covering substrate + surface + admin-API + cross-cutting decisions.

Body 66 lines — SMALLEST baseline so far. Comparison: §ADR-9 67 / §ADR-10 73 / §ADR-11 78 / §ADR-12 89 / §ADR-13 66. **Intentional discipline per §ADR-12 lesson "project less, ratify more".** Most admin endpoint concerns already covered by §ADR-2/4*/9/10/11/12; §ADR-13 covers only genuinely cross-cutting invariants.

Five sub-questions (C0 + C1-C4):
- C0 placement = §ADR-13 new top-level vs §ADR-2a subsection (architect-rec: §ADR-13 — audit/sync-validation invariants are not RBAC concerns)
- C1 sync-validation generalization = extend §ADR-12 D4 to ALL admin write endpoints (coordination-rule pattern instance #4)
- C2 audit-trail invariant = mobiz pattern preservation (admin identity in business-row + §ADR-10 cross-link); NO separate admin_actions table (future-ADR-placeholder if regulatory driver emerges)
- C3 RBAC resource-split discipline = preserve mobiz pattern (PR #175 pull-out → pull-out-tasks + pull-out-logs); architectural rule for future endpoints
- C4 fleet-control thread #45 disposition = defer to future §ADR-14 Fleet-Control; thread #45 stays open until concrete operator-imperative driver emerges

Five trade-off alternatives evaluated and rejected: A narrow-sync (Direct-Transfer only) / B admin_actions separate table / C single-resource RBAC / D fold fleet-control / E §ADR-2a subsection. 4 revisit triggers.

Lessons applied from §ADR-12 (project less, ratify more):
- 4 sub-questions + 1 placement (C0) — not 5+
- Body 66 lines smallest; intentional
- Past-state + future-state Pre-Input-5 verified at evidence sweep (admin identity per PR #f44cf44/#186/#187; RBAC split per PR #175; admin_actions table absence verified — driver-absent)
- No blind Phase-1/Phase-2 staging
- Future-ADR-placeholder for fleet-control (not folded into §ADR-13)
- Each decision references existing ratified ADR it extends (no novel substrate)

Pattern instances new this pass:
- Coordination-rule-as-architectural-invariant instance #4 (D1)
- Future-ADR-placeholder-as-deferred-question instance #2 (D2 admin_actions table)
- Future-ADR-placeholder-as-deferred-question instance #3 (D4 §ADR-14 Fleet-Control)

Architecture-decision phase milestone (post-§ADR-13 ratification): 10 ADRs covering deposit + payout core architecture:
- Substrate-shaped: §ADR-4a/4b/4c/4d + §ADR-9 + §ADR-10
- Surface-shaped: §ADR-11 + §ADR-12 + §ADR-13
- Cross-cutting: §ADR-1/2/3/5/6/7/8

Single-straight-ratification heuristic re-test: §ADR-13 satisfies all 5 original enabling conditions + the new 6th condition surfaced from §ADR-12 retro ("scope ≤2 flows / cross-cutting; not multi-flow surface ≥3 flows"). §ADR-13 is cross-cutting (admin-API invariants apply across all admin endpoints; not multi-flow). Predicts straight ratification likely. Test will validate the heuristic update — if §ADR-13 ratifies straight, heuristic 6th condition confirmed; if revise needed, find which condition was insufficient.

Pre-Input-5 checkpoint discipline applied PROACTIVELY at evidence sweep (not retroactively after user pushback). 3 past-state claims verified via Input 1 learnings (admin identity / RBAC split). 1 future-state claim (Decision #2 no admin_actions table) framed as "no driver currently" with future-ADR-placeholder. **Discipline expanded from §ADR-12 lessons; first instance of pre-emptive bidirectional Pre-Input-5 application before user pushback fires.**

Prior-art bundle: 3 mobiz learnings (PR #f44cf44 admin-identity / PR #186/#187 deposit approval / PR #175 RBAC split) + §ADR-2 + §ADR-12 D4 + §ADR-10 D3 cross-refs + thread #45 (mobiz claude-last-pending) + W10 baseline (no inheritance constraint applies). Input 5 not needed.

Threads opened: #61 (5 sub-questions C0-C4). Threads closed: none. Thread #45 explicitly stays open per Decision #4. Commit: b3716d3. PR #12 (open, not merged; stacks on PR #11 + PR #10).

Trace chain candidate: §ADR-12 pass-2 ratified (3620b6ae) — extends 11-link cross-ADR chain.

Today's session arc continues — 9 W1 + maintenance passes since 2026-04-30 17:12: §ADR-9 baseline + ratified + §ADR-10 baseline + ratified + §ADR-11 baseline + ratified + §ADR-12 baseline + ratified + maintenance pass + brew-ops handoff + §ADR-13 baseline (this pass). 4 ratified ADRs + 1 pending. Total wall-clock ~52 hours; total active work ~7 hours. Velocity sustained even with §ADR-12 revise cycles.

Next-pass candidate: §ADR-13 ratification (pass 2) when user answers thread #61 — heuristic predicts ~10 min straight if heuristic 6th condition is correct. If §ADR-13 ratifies straight, architecture-decision phase will be substantively complete.

---
*Added via Oracle Learn*
