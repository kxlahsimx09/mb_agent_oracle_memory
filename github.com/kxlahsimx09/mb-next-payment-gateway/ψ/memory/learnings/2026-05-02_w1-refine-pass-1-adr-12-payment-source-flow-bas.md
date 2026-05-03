---
title: W1 refine pass 1 — §ADR-12 Payment Source-Flow baseline (`#provisional` `[RATIFI
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-12, payment-source-flow, taxonomy, pullout, settlement, direct-transfer, payout, drift-closure-instance-4, coordination-rule-instance-3, phase-1-2-staging-instance-5, baseline, pass-1, provisional, ratification-pending, substrate-convergence-8-instances, thread-60-opened, largest-surface-gap-closed]
created: 2026-05-02
source: docs/adr.md@5e41b07 §ADR-12 + thread #60 messages + 5 mobiz learnings
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine pass 1 — §ADR-12 Payment Source-Flow baseline (`#provisional` `[RATIFI

W1 refine pass 1 — §ADR-12 Payment Source-Flow baseline (`#provisional` `[RATIFICATION_PENDING:60]`).

Closes the largest remaining surface gap in deposit + payout core architecture: source-flow create/schedule layer for the 4 §ADR-8-routed flows (Payout / Settlement / Pullout / Direct-Transfer). After §ADR-9/10/11 ratified the substrate-shaped phase, §ADR-12 covers the surface-shaped phase. Body 89 lines (slightly larger than §ADR-9/10/11 baseline shapes 67/73/78 due to taxonomy table + 4-flow scope; still well under 150-line extract threshold).

Five decisions, each [RATIFICATION_PENDING:60]:
- C1 source-flow taxonomy = 4-row matrix (creator-role × trigger-class × idempotency-source); critical insight — Pullout uses server-derived per-trigger dedup primitive (cooldown timestamp / advisory lock) NOT §ADR-11 client-cooperation contract; server-internal flows have no HTTP retry surface to dedup against
- C2 Settlement creation = admin-driven Phase-1; merchant-pulled/scheduled Phase-2 trigger-driven (mirrors §ADR-9/10/11 staging discipline)
- C3 Pullout multi-trigger consolidation = single dispatcher; 4 triggers feed it (manual / scheduler-tick / balance-threshold / demand-refill); closes acknowledged drift accumulation per PR #342 "MUST NOT modify any existing flow" + "deliberately copy-pasted"
- C4 Direct-Transfer = sync-validate-all-before-INSERT architectural invariant; closes DTR1776285027RZE1H2 self-transfer + balance-insufficient async-failure incident structurally; admin "Approved" UI signal cannot diverge from execution
- C5 endpoint topology = per-flow distinct endpoints; polymorphic /source-flows rejected (conflates auth/RBAC/validation surfaces)

Seven trade-off alternatives evaluated and rejected: A no-taxonomy / B Phase-1 auto-recurring / C Phase-1 hybrid / D 4-path Pullout parity / E async Direct-Transfer validation / F polymorphic endpoint / G §ADR-11 for Pullout. 6 revisit triggers documented.

Three patterns reused reflexively this pass:
1. Drift-closure-as-decision instance #4 (after §ADR-10 D4 silent-skip / §ADR-9 D2 callback-resend / §ADR-11 D1+D5 client-replay) — Decision #3 closes Pullout 4-path multi-trigger drift
2. Coordination-rule-as-architectural-invariant instance #3 (after §ADR-10 D5 canonical lock-order / §ADR-11 D5 Idempotency middleware) — Decision #4 sync-validate-all-before-INSERT as Direct-Transfer invariant
3. Phase-1/Phase-2 staging instance #5 (after §ADR-2 RBAC / §ADR-9 retry / §ADR-10 audit/balance / §ADR-11 TTL) — Decision #2 Settlement Phase-1 admin-driven; Phase-2 merchant-pulled/scheduled trigger-driven

Substrate convergence count → 8 (post-ratification expected 9). §ADR-12 reuses 5+ prior ADR shapes — almost no novel substrate introduced (80%+ pattern reuse).

Single-straight-ratification heuristic prediction: pass-1 satisfies all 5 enabling conditions (Phase-1/2 staging on hedged decisions ✓ via D2; architect-rec on every sub-question ✓ 5/5; trade-offs rejected inline ✓ 7 alternatives; drift-closure-as-decision ✓ D3; coordination-rule-as-invariant ✓ D4) — predicts straight ratification likely (similar to §ADR-10 + §ADR-11 precedents).

Prior-art bundle: 5 mobiz learnings (PR #342 demand-refill / PR #336 DestCap guard / PR #323 random band / DTR1776285027RZE1H2 incident / payout-auto-reconcile flow) + §ADR-7 + §ADR-11 auth/idempotency parents + §ADR-8 fair-router downstream + §ADR-2 admin RBAC + §ADR-10 D5 + §ADR-11 D5 coordination-rule precedents + W10 baseline (no inheritance constraint applies).

Pre-Input-5 checkpoint NOT triggered this pass — no "current does X" claim made without prior-learning citation; 5 mobiz learnings name file:line + commit precisely. Input 5 not needed.

Threads opened: #60 (5 sub-questions C1-C5). Threads closed: none. Commit: 5e41b07. PR #10 (open, not merged).

Trace chain candidate: §ADR-11 pass-2 ratified (5d7a99b1) — §ADR-12 covers source-flow upstream of §ADR-8 routing + cites §ADR-11 Idempotency-Key contract for request-driven flows.

Architectural milestone: §ADR-12 closes the LARGEST remaining surface gap. After ratification, deposit + payout core architecture covers all substrate-shaped + most surface-shaped decisions. Remaining gaps: Admin-API surface ADR (medium; may fold as §ADR-2a subsection); sibling cross-cut amendment maintenance pass (small).

Today's session arc spans 3 calendar days: 7 W1 passes total since 2026-04-30 17:12 — §ADR-9 baseline + §ADR-9 ratified + §ADR-10 baseline + §ADR-10 ratified + §ADR-11 baseline + §ADR-11 ratified + §ADR-12 baseline (this pass). 3 ratified ADRs + 1 pending. Velocity peak sustained.

Next-pass candidate: §ADR-12 ratification (pass 2) when user answers C1-C5 — heuristic predicts straight ratification ~10 min. After §ADR-12 ratifies: Admin-API surface ADR (90-120 min) — last remaining major architectural gap. Then sibling cross-cut amendment maintenance pass to update §ADR-7/§ADR-4* deferred-questions referencing newer ratified ADRs.

---
*Added via Oracle Learn*
