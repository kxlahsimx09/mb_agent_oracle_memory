---
title: fleet shared sub-agents — user-level sonnet delegation for code-search + dpay pr
tags: [sub-agents, code-finder, dpay-finder, model-tiering, sonnet, user-level-agents, mcp-in-subagent, dpay, delegation-defaults, brew-ops, fork-pr-105, token-efficiency]
created: 2026-05-26
source: brew-ops fleet sub-agent rollout 2026-05-26 — fork PR #105 (8f4fbeb11), central commit b37fde0
project: github.com/soul-brews-studio/arra-oracle-v3
---

# fleet shared sub-agents — user-level sonnet delegation for code-search + dpay pr

fleet shared sub-agents — user-level sonnet delegation for code-search + dpay prod (2026-05-26)

Realizes the "latent .claude/agents/ capacity" noted in [[orchestrator-scope-guard-pretooluse-hook-enforce]]. Two sonnet sub-agents now serve every role in every repo:
- **code-finder** (sonnet): read-only code search → file:line + excerpts. tools: Read, Grep, Glob, Bash.
- **dpay-finder** (sonnet): read-only dpay PRODUCTION payment-DB queries. tools: the 5 mcp__dpay__* only (structurally read-only — no write path). Routes across ~50 collections (transactions, ts_deposits, ts_payouts, wallets, settlements, callback_logs, audit_trail, …).

**Why sonnet sub-agents:** both jobs emit large/noisy/PII-heavy output; isolating them in a sub-agent keeps it out of the (opus) main session → leaner context + cheaper, main gets only the distilled conclusion. This is the realized form of model-tiering.

**Reusable infra pattern (how to add a fleet-wide sub-agent):**
1. Author source in `arra-oracle-v3/.claude/agents/<name>.md` (git-tracked; frontmatter name/description/tools/model). Use "Use PROACTIVELY …" in `description` to drive auto-delegation.
2. Deploy to USER level `~/.claude/agents/` via `scripts/install-fleet-subagents.sh` (idempotent cp). User-level = available to ALL repos, not just the source repo. Works because dpay + arra-oracle-v2 MCP servers are configured user-level in `~/.claude.json` (so MCP-backed sub-agents work everywhere).
3. Reinforce usage with AGENTS.md "§8a Delegation defaults" — sibling-synced across all 4 repos' charters (commit b37fde0, central mb_agent_oracle_memory main).
4. Sub-agents load in NEW/resumed sessions only (not a running one) — same as hooks.

**Gotchas:** a sub-agent's `tools:` can list MCP tools by full name (`mcp__dpay__find` etc.). project-level `.claude/agents/<name>` overrides user-level same-name (keep content identical to avoid drift). Source PR: arra-oracle-v3 fork #105 (merged 8f4fbeb11).

---
*Added via Oracle Learn*
