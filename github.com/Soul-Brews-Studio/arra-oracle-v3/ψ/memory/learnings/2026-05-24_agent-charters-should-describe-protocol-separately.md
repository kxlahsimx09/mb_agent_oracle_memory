---
title: agent charters should describe protocol separately from engine-specific plumbing
tags: [charter, skills, engine-parity, claude, codex, orchestrator]
created: 2026-05-24
source: brew-ops implementation bundle 2026-05-24 (PR #7 in mb_agent_oracle_memory)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# agent charters should describe protocol separately from engine-specific plumbing

agent charters should describe protocol separately from engine-specific plumbing.

Observed pre-fix shape:
- AGENTS/SKILL mixed protocol-level invariants with Claude-specific runtime wording
- codex adoption made shared protocol look falsely claude-bound

Fix in PR #7 (commit 59f12d9):
- rewrite charter/skill wording to engine-aware claude|codex where rules are shared
- preserve explicit callouts where implementation is still runtime-specific
- update failure-playbook references to include codex session-log locations

Files:
- .agent/AGENTS.md
- .agent/skills/brew-ops/SKILL.md
- .agent/skills/brew-ops/references/workflow-5-memory-audit.md
- .agent/skills/orchestrator/references/workflow-1-dispatch.md

Reviewer intent: docs/charter clarity so reviewers and agents can separate invariant protocol from current engine plumbing.

---
*Added via Oracle Learn*
