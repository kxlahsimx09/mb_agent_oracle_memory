---
title: Campaign nextteam C0 scaffold COMPLETE (brew-ops, PR #9 on kxlahsimx09/mb_agent_
tags: [brew-ops, repo:cross, next, nextteam, campaign-nextteam, scaffold, fleet, next-dev, next-tester, next-code-reviewer, next-investigator, next-pm, engine-swap, virtual-clock, project-registration, gotcha, decision, handoff]
created: 2026-05-31
source: brew-ops campaign nextteam C0; PR kxlahsimx09/mb_agent_oracle_memory#9 (branch campaign/nextteam)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Campaign nextteam C0 scaffold COMPLETE (brew-ops, PR #9 on kxlahsimx09/mb_agent_

Campaign nextteam C0 scaffold COMPLETE (brew-ops, PR #9 on kxlahsimx09/mb_agent_oracle_memory branch campaign/nextteam — NOT merged per AGENTS.md §9). Filed under arra-oracle-v3 because the mb-next project slug is STILL not registered in the running Oracle MCP (see gotcha below).

Scaffolded 5 build-team roles for mb-next-payment-gateway, mirroring the existing role-SKILL skeleton, each encoding owns/does-not-own/principles from the locked CAMPAIGN BRIEF:
- next-dev (claude/opus; instances dev-1+dev-2) — builder; BINDING rule: time is an injectable dependency (never Date.now/now/NOW/CURRENT_TIMESTAMP).
- next-tester (claude/opus) — forks poc/integration harness; READ-ONLY on prod code; builds V1-V4 evidence; no self-cert.
- next-code-reviewer (claude/opus; [ENGINE_SWAP:codex]) — 3-dimension REVIEW gate via gh pr review (requirement-conformance / clean / perf-smells).
- next-investigator (claude/opus; [ENGINE_SWAP:codex]) — evidence-only skeptic; owns VERIFY V1+V5; issues the epic seal; runs OWN regression on OWN seal env.
- next-pm (claude/opus|sonnet) — reports DoD from artifacts not word (mirrors orchestrator 2a); oracle-studio progress dashboard.

Each role: .agent/skills/<role>/SKILL.md + psi/memory/mailbox/<role>/standing-orders.md (NEW subtree). Plus 6 fleet windows (engine=claude; engine_swap_todo field carries the [ENGINE_SWAP:codex] marker on reviewer+investigator since JSON has no comments); oracle-studio data-contract stub + ProgressPanel placeholder under .agent/oracle-studio/; 4 placeholder secret slots (dev-1,dev-2,tester,investigator) reserved OUT-OF-GIT in ~/.arra-oracle-v2/fleet-secrets/mb-next-payment-gateway/slots/ with REPLACE_ME values (no real keys).

KEY GOTCHA #1 — PR target repo: SKILLs/fleet/standing-orders MUST go to the central memory repo (mb_agent_oracle_memory), NOT the product repo — product repo gitignores /.agent and its .agent is a symlink into central. Built in an isolated worktree off origin/main to avoid disturbing the live central checkout (which sat on skill/orchestrator-gap-sweep-lessons with unrelated uncommitted work).

KEY GOTCHA #2 — project registration: arra_learn project=github.com/kxlahsimx09/mb-next-payment-gateway STILL REJECTS (Unknown project) as of 2026-05-31, even though .agent/fleet/20-mb-next-payment-gateway.json declares project_repos:[kxlahsimx09/mb-next-payment-gateway]. getKnownProjects() unions baseline+fleet-derived but is cached → needs an Oracle MCP server RESTART to take effect. This blocks all 5 roles from filing learnings against mb-next until restarted.

OWNER TODO: (1) restart Oracle MCP server; (2) provision 4 substrate stacks + fill secret slots; (3) review/merge PR #9; (4) oracle-studio React panel follow-up PR in the oracle-studio repo. next-architect TODO: the env+clock ADR (every role's clock rule depends on it; first-sessions halt without it).

---
*Added via Oracle Learn*
