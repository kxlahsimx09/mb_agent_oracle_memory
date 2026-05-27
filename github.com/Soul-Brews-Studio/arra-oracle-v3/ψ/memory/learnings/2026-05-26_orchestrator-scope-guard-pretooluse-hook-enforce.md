---
title: orchestrator scope-guard — PreToolUse hook enforces "I dispatch, others do the w
tags: [orchestrator, decision-authority, scope-guard, pretooluse-hook, dispatch-not-do, dangerously-skip-permissions, tmux-window-gating, brew-ops, model-tiering, sub-agents, fork-pr-103, relay-not-verdict]
created: 2026-05-26
source: brew-ops scope-creep review 2026-05-26 — 109 orchestrator transcripts; fork PR #103; central SKILL commit 945b400
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator scope-guard — PreToolUse hook enforces "I dispatch, others do the w

orchestrator scope-guard — PreToolUse hook enforces "I dispatch, others do the work" (2026-05-26)

**Finding (brew-ops review of 109 orchestrator transcripts):** SKILL principle 2 rested on discipline alone and leaked. Most orchestrator "Edit/Write" volume is legitimate envelope manipulation (e.g. wt-3/082076b5 EW=116 = all inbox/*.md archiving; wt-1/3bff545d EW=104 = all for-pg-writer consult envelopes) — NOT code work; the orchestrator mostly behaves (wt-51/6812815d: th=93, EW=1). BUT genuine scope-creep exists: wt-9 (06f8cfa6) edited docs/requirements/epic-payout.md ×3 and src/commands/shared/wake-cmd.ts ×1 — agent work owned by pg-writer/architect/brew-ops. Soft scope-creep too: forming wrong technical verdicts (the 2026-05-17→19 campaign: PR #147 "half-reconciled" + "don't --resume a dead session" — both wrong, corrected by owners).

**Root cause:** orchestrator launches with `claude --dangerously-skip-permissions` → no structural guard; role set by the user's greeting ("ในฐานะ orchrestrator"), not build_task_prompt → SKILL-path session detection fails (use the greeting/tmux-window as the marker instead).

**Fix shipped:**
- `scripts/orchestrator-guard-hook.sh` (PreToolUse, matcher Edit|Write|MultiEdit) — blocks edits outside inbox/, ψ/ vault, ~/.cache/orchestrator-bot/, /tmp. Self-gates on tmux window `orchestrator-oracle` (no-op for brew-ops/pg-writer/etc.). Fail-open. Bash-exempt. PreToolUse hooks STILL run+block under --dangerously-skip-permissions (verified). Deployed ~/.claude/hooks/ + registered ~/.claude/settings.json. 18/18 tests. arra-oracle-v3 fork PR #103.
- SKILL.md (central mb_agent_oracle_memory main, commit 945b400): Core principle 2a "relay questions, don't render technical verdicts" + §Scope guard.

**For orchestrator:** if the guard blocks you, that's the system working — the refused edit is agent work; open a sub-thread + envelope it to for-<role>/ (workflow-1-dispatch §Step 4). Never route around via Bash; escalate to user if you believe it's truly coordination.

**Reusable infra fact:** the wake envelope already supports per-dispatch `engine: claude|codex`, `model:`, `reasoning_effort:` (inbox-watcher.sh envelope_engine/model/reasoning_effort); `maw wake --engine/--model/--reasoning-effort` — enables model-tiering dispatch (cheap model for routine, opus for hard) without code changes. `.claude/agents/` has unused sub-agents (context-finder/executor/marie-kondo, all haiku) — latent capacity for an opus advisor sub-agent.

---
*Added via Oracle Learn*
