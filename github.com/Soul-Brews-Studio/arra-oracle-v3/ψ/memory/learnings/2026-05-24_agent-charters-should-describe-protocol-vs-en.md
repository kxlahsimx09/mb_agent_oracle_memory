---
title: agent charters should describe protocol separately from engine-specific plumbing
tags: [brew-ops, repo:arra-oracle-v3, charters, skills, codex, claude, engine-parity, docs, orchestrator]
created: 2026-05-24
source: brew-ops implementation bundle 2026-05-24 (PR #7 in mb_agent_oracle_memory)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# agent charters should describe protocol separately from engine-specific plumbing

agent charters should describe protocol separately from engine-specific plumbing.

## Superseded record note
Canonical indexed slug for this fact is:
`2026-05-24_agent-charters-should-describe-protocol-separately.md`

This file is retained for append-only history (P-001) and PR traceability.

#repo:arra-oracle-v3 #fleet #charter #skills #engine-parity

**Observed shape (pre-fix):** `.agent/AGENTS.md` + role `SKILL.md` mixed two layers:

- protocol-level rules (directed inbox, campaign wake key, loop-closure)
- runtime-specific implementation details (Claude paths/wording)

When codex became a first-class role engine, this wording made behavior look Claude-bound even where protocol was actually engine-neutral.

**Fix applied (mb_agent_oracle_memory PR #7, commit 59f12d9):**

- make charter/skill wording engine-aware (`claude|codex`) where policy is shared
- keep explicit callouts where implementation is still runtime-specific (e.g., current hook deployment paths)
- update failure-playbook references to include codex session-log paths alongside claude

Files touched:

- `.agent/AGENTS.md`
- `.agent/skills/brew-ops/SKILL.md`
- `.agent/skills/brew-ops/references/workflow-5-memory-audit.md`
- `.agent/skills/orchestrator/references/workflow-1-dispatch.md`

**Reviewer intent:** this docs patch does not change routing logic; it removes conceptual drift so reviewers and future agents can distinguish:

- **what must always hold** (protocol)
- **how current runtime executes it** (engine plumbing)

---
*Added via Oracle Learn*
