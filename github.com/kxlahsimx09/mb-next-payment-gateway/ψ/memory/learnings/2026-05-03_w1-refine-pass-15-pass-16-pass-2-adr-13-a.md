---
title: W1 refine pass 1.5 + pass 1.6 + pass 2 — §ADR-13 Admin-API Surface ratified `#de
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-13, admin-api-surface, ratified, decision, pass-15, pass-16, pass-2, combined-pass-instance-2, thread-61-closed, 10-adrs-architecture-decision-phase-milestone, deliberate-divergence-from-mobiz-via-postgres-feature-instance-2, user-pushback-instance-6, audit-log-canonical, trigger-based-denormalization, option-d]
created: 2026-05-03
source: docs/adr.md@77fd6c0 §ADR-13 + thread #61 closed messages 121-124
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine pass 1.5 + pass 1.6 + pass 2 — §ADR-13 Admin-API Surface ratified `#de

W1 refine pass 1.5 + pass 1.6 + pass 2 — §ADR-13 Admin-API Surface ratified `#decision` (thread #61 closed; multi-message dialogue across 2 calendar days; 2 pre-ratification revises driven by user-pushback-as-design-force pattern).

Architecture-decision phase milestone reached — 10 ADRs ratified covering deposit + payout core architecture (substrate-shaped + surface-shaped + admin-API-shaped + cross-cutting infrastructure). Substantially complete.

§ADR-13 lifecycle journey:
- Pass 1 baseline (2026-05-02 19:04) — body 66 lines smallest baseline; 5 sub-questions C0-C4
- Pass 1.5 revise (2026-05-03; after C1 evidence-check pushback) — 3-layer rule + Thunder Layer-2 + C2 mobiz-full-pattern (audit_log discovered)
- Pass 1.6 revise (2026-05-03; after C2 row-bloat concern) — Option D audit_log canonical + Postgres trigger-based denormalization + 4 typed columns
- Pass 2 ratification (2026-05-03) — all 5 sub-questions ratified

Final ratified shape (5 decisions + C0 placement):
- C0 placement = §ADR-13 new top-level (not §ADR-2a subsection)
- C1 admin write 3-layer invariant (Layer 1 validate / Layer 2 load-bearing-execute / Layer 3 async out-of-band; Thunder = Layer 2 special case because verdict is deliverable)
- C2 audit-trail Option D = audit_log canonical + Postgres AFTER INSERT trigger denormalizes 4 typed columns (last_admin_action_type/by/at/reason) on business-row + §ADR-10 wallet_change_logs cross-link
- C3 RBAC resource-split discipline (preserve mobiz PR #175 pattern)
- C4 fleet-control defer to §ADR-14 (thread #45 stays open)

Architecture-decision phase milestone — 10 ADRs:
- Substrate: §ADR-4a/4b/4c/4d + §ADR-9 + §ADR-10
- Surface: §ADR-11 + §ADR-12 + §ADR-13
- Cross-cutting: §ADR-1/2/3/5/6/7/8
- Remaining: §ADR-14 Fleet-Control placeholder only

NEW PATTERN — Deliberate-divergence-from-mobiz-via-Postgres-feature instance #2 (after §ADR-4c D10 view contract). §ADR-13 D2 uses Postgres AFTER INSERT trigger to achieve cleanliness mobiz Go pattern cannot — constant 4 typed columns regardless of admin action types vs mobiz per-transition fields scaling N×M. **Pattern qualifies as durable.** Heuristic: when mobiz pattern is functionally correct but architecturally verbose/messy AND Postgres has a feature (view / trigger / partial index / etc.) that enables cleaner shape, divergence is justified. Architecture-vs-design-discipline note: divergence preserves business semantics; only changes data-model shape.

User-pushback-as-design-force pattern instances #5 + #6 (cumulative count: 8 across full session arc). §ADR-13 contributed 2 instances within single lifecycle (similar to §ADR-12's 3 instances). Lesson: even with proactive Pre-Input-5 + small body baseline (66 lines), generalization claims (sync-validate-all + no admin_actions table) need their own evidence verification.

Combined pass shape — pass 1.6+2 second instance (first was §ADR-9 pass 1.5+2). When user-pushback drives within-scope revise during ratification AND user immediately ratifies revised body in same dialogue, combine commits. Pattern note: combined-pass shape works when (a) revise scope is bounded to user-named architectural concern, (b) user explicitly indicates ratification intent post-revise.

Pre-Input-5 checkpoint instances #9 + #10 caught proactively by user during ratification (pass 1.5 — C1 wording vague + C2 audit_log existence missed at pass-1 evidence sweep). Brew-ops handoff filed 2026-05-02 to externalize discipline naming. Pass 1.6 was driven by architectural-cleanliness concern (row-bloat) not Pre-Input-5 — different pattern.

Single-straight-ratification heuristic limitation surfaced again — §ADR-13 satisfied 6 enabling conditions per pass-1 retro projection but still required 2 revises. Heuristic update candidate: "scope ≤2 flows + cross-cutting + architecturally-clean-by-construction (no parity-without-improvement)". §ADR-13 pass-1 D2 was mobiz parity (3 mechanisms compose) without architectural improvement; user-pushback drove improvement to Option D.

Body sizing: 66 → 83 → 95 lines across 3 passes. Architecture-vs-design discipline scaled — additions are layer/mechanism enumeration + schema illustrations; not design content. Compare: §ADR-9 78 / §ADR-10 73 / §ADR-11 78 / §ADR-12 92 / §ADR-13 95.

Threads closed: #61 (closing message_id 124 with full ratification arc + pattern observations + 10-ADR milestone). Threads opened: none. Thread #45 explicitly stays open per Decision #4. Commit: 77fd6c0. PR #12 (open, not merged; stacks on PR #11 + PR #10).

Trace chain: 07d70b54 (§ADR-13 pass-1) → this pass — extends 12-link cross-ADR chain. f9c519ad → 541c6fdd → c327e4d9 → e003baff → b304445f → c7380258 → 5d7a99b1 → 85892602 → 3620b6ae → 132d6259 → 07d70b54 → this pass.

Today's session arc continues — 12+ passes (W1 + maintenance + handoff) across 4 calendar days; 5 ratified ADRs + 2 process passes. Total active work ~8 hours. Velocity sustained.

Next-pass candidates after §ADR-13 ratification:
- W2 sync-clean — regenerate docs/architecture.md snapshot. Closes architecture-decision phase artifact.
- Brew-ops handoff #2 — document 10 patterns surfaced (drift-closure / coordination-rule / Phase-1/2 staging / single-straight-ratification / user-pushback-as-design-force / Pre-Input-5 checkpoint expanded / future-ADR-placeholder / ADR-network-coherence-as-maintenance-pass / combined-pass / deliberate-divergence-from-mobiz). 30-45 min.
- Sibling cross-cut amendment maintenance pass #2 — touch §ADR-2 + §ADR-12 §Deferred to cite §ADR-13. ~15 min.
- Transition to design-pass / impl-pass / migration-map work.

---
*Added via Oracle Learn*
