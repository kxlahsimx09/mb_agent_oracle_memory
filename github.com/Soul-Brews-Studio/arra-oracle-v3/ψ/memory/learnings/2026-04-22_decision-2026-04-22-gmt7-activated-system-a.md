---
title: Decision (2026-04-22, GMT+7) — Activated `system-architect` as the first agent i
tags: [brew-ops, repo:cross, fleet, skill-layout, decision, system-architect, next, current, mb-next-payment-gateway, tag-convention, agent-activation, handoff]
created: 2026-04-22
source: Conversation with user 2026-04-22 GMT+7, brew-ops session. User requested first agent for new repo kxlahsimx09/mb-next-payment-gateway; skill body from anthropics/knowledge-work-plugins/engineering/skills/system-design.
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Decision (2026-04-22, GMT+7) — Activated `system-architect` as the first agent i

Decision (2026-04-22, GMT+7) — Activated `system-architect` as the first agent in `kxlahsimx09/mb-next-payment-gateway`, and ratified `#next` as the system-lifecycle tag paired with the existing `#current` (mobiz-payment-gateway + bank-bot).

Shape of the change:

New repo + agent:
- Repo: `kxlahsimx09/mb-next-payment-gateway` (ghq-cloned; empty at activation — no code yet).
- Role: `system-architect` (distinct role; not a second instance of an existing role).
- tmux window: `next-architect-oracle`.
- Fleet file: `.agent/fleet/20-mb-next-payment-gateway.json` (sync_peers: [], project_repos: [kxlahsimx09/mb-next-payment-gateway]).
- Skill body: embeds the five-phase system-design framework verbatim from anthropics/knowledge-work-plugins/engineering/skills/system-design (requirements → high-level → deep-dive → scale/reliability → trade-off analysis), wrapped in Soul-Brews oracle-memory charter (startup `arra_search query="soul-brews-core system-architect" type=principle limit=20`, AGENTS.md read, 3-layer tagging).
- Owned artifacts: `docs/design/`, `docs/adr/`, `docs/migration-map.md`, `docs/api/`, `docs/data-model.md`, `docs/diagrams/`. Does not write production code.

Ratified tag convention:
- `#current` → mobiz-payment-gateway + bank-bot (production stack). Unchanged from prior convention.
- `#next` → mb-next-payment-gateway (design/build, successor). New.
- `#migration-map` → cross-family mappings; usually paired with `#repo:cross`. Pre-existing; now binding.
- Semantics: `#current` vs `#next` describes which system family a fact is about, not recency. A learning written today about mobiz is still `#current`.

Files created/modified:
- Created (central memory `kxlahsimx09/mb_agent_oracle_memory/github.com/kxlahsimx09/mb-next-payment-gateway/.agent/`):
  - AGENTS.md (full charter; 12 sections; parallel to mobiz/bank-bot).
  - fleet/20-mb-next-payment-gateway.json.
  - skills/system-architect/SKILL.md (full identity + framework + first-session + memory discipline).
- Created (product repo):
  - `.agent` symlink → central memory path.
  - `.gitignore` (excludes `/.agent`).
- Modified (central memory, Soul-Brews-Studio/arra-oracle-v3/.agent/):
  - AGENTS.md §5 roster: expanded "Other fleet members" table with `system-lifecycle` column, added bot-writer + pg-tester + next-architect rows, added system-lifecycle tagging reference table.
  - skills/brew-ops/SKILL.md: added "Active roles without numbered workflows yet" section to the fleet workflow inventory (system-architect entry).

Why this matters for brew-ops workflow-5 (memory audit):
- Audits must now accept `#next` as a valid layer-2 tag. Learnings tagged `#system-architect #repo:mb-next-payment-gateway #next` are compliant with the 3-layer convention.
- Cross-family learnings (`#migration-map`, usually `#repo:cross`) are expected to grow as system-architect designs subsystems that reference current-system prior art.
- No numbered workflows for system-architect yet — audit should not flag missing `references/workflow-N-*.md` for this role during initial runs.

Next steps (not part of this activation):
- system-architect's first session: run `arra_search soul-brews-core` + `arra_stats`, read AGENTS.md, map current-system prior art, produce ≥3 learnings summarizing the inheritance surface, propose a first subsystem to design.
- Once repeat design patterns emerge, author numbered workflows under `skills/system-architect/references/workflow-N-<slug>.md` (MADR ADR workflow, migration-map entry workflow, etc.) and update brew-ops inventory.

---
*Added via Oracle Learn*
