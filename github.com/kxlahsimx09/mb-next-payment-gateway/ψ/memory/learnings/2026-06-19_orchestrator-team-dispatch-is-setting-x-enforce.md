---
title: orchestrator team-dispatch — "is setting X enforced? if not, build it" (mb-next 
tags: [orchestrator, team-dispatch, 2b-fan-out, accepted, system-bank-enforcement, money-material, fair-router, mb-next-payment-gateway, adr-30, decision-authority]
created: 2026-06-19
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# orchestrator team-dispatch — "is setting X enforced? if not, build it" (mb-next 

orchestrator team-dispatch — "is setting X enforced? if not, build it" (mb-next system-bank) → auto-decided after architect verdict + explicit owner GO → accepted.

REQUEST: owner asked whether the editable System-bank (`bank_account`) settings are ENFORCED at transaction time; if not + no spec, build it. Campaign family slug `sysbankenf*` (own team, never reused other campaigns' agents).

SHAPE + ROUTING that worked (workflow-2 team dispatch, build-workflow de-bias chain):
1. Read-only investigation FIRST (2 Explore sub-agents): mapped enforcement reality (Code-is-Truth) + ADR-29 scope. Found 6 settings enforced, 3 by-design bot-side, 2 real gaps.
2. next-architect (role token in mb-next is `system-architect` skill-dir BUT the spawnable oracle/owner-name is `next-architect` — use `next-architect`; owner corrected this live, killed %489 re-spawned %492) → ADR-30 verdict: the 2 gaps (`availability`, per-bank `withdrawal_min/max`) are ALREADY-RATIFIED-but-unbuilt (§ADR-6 T5, §ADR-8 AF1/AF3) "BOT-001..004 fair-router hardening", both land in ONE function `fair_router_assign`, MONEY-MATERIAL. Architect corrected stale evidence (withdrawal cols now exist via PROV-006).
3. MONEY-MATERIAL → escalated the build GO to owner (AskUserQuestion) even though owner had pre-said "ก็ทำเลย" — correct, because it changes which bank services real payouts. Owner: GO.
4. Build chain under own slugs: next-dev-1 (slot dev-1, SPEC-first + migration CREATE OR REPLACE + self-verify) → brew-ops cross-deploy to tester+seal (pre-merge, orchestrator-authorized named exception) → next-tester (code-blind, separate slug/worktree, discrimination proof) → next-investigator (seal, independent falsify = SEAL) → next-code-reviewer (APPROVE, body-header verdict). All GREEN.
5. Owner merged #634 (code) + #633 (ADR docs). Staging auto-deploy is DISABLED by owner → brew-ops deployed 000500 to staging sinuw MANUALLY (Mgmt-API SQL + ledger insert), confirmed 4 predicates live.

DURABLE GOTCHAS: (a) spawn architect as `next-architect` not `system-architect`; (b) money-material build = get explicit owner GO even under standing "just do it"; (c) staging auto-deploy disabled → always route brew-ops manual deploy after a gateway main-merge; (d) keep docs-PR (#633) separate from code-PR (#634) on separate slugs so the §9a CODE self-merge carve-out vs owner-merge-docs split stays clean; (e) close each teammate on idle (kill window + verify 0 procs) keeping worktree, finish-script at end.

---
*Added via Oracle Learn*
