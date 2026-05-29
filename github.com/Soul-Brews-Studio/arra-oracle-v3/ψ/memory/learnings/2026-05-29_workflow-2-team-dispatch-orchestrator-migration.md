---
title: workflow-2 team-dispatch — orchestrator migration from envelope+watcher to `maw 
tags: [orchestrator, workflow-2, team-dispatch, maw-team, agent-teams-native, parent-session-id, watcher-deprecation, campaign-254, worktree-granularity-campaign-repo, brew-ops-bot, multi-orchestrator, phase-1, fork-pr-111, brew-ops]
created: 2026-05-29
source: brew-ops Phase 1 team-dispatch rollout 2026-05-29 — fork PR #111 merged (829664a), central commit 5f5dbaf
project: github.com/soul-brews-studio/arra-oracle-v3
---

# workflow-2 team-dispatch — orchestrator migration from envelope+watcher to `maw 

workflow-2 team-dispatch — orchestrator migration from envelope+watcher to `maw team` (2026-05-29)

**Driver:** [[inbox-watcher-deliveredtoowner-delivered]] cost campaign #254 ~12h of silent drift via the `delivered_to_owner` ≠ delivered failure mode. The watcher's send-keys race, JSONL-gate misread, §151 owner-record fragility, and dual-wake collision are all consequences of the **envelope+send-keys dispatch architecture itself** — not bugs to patch. The fleet's `maw team` plugin (~14 files in maw-js) already had a clean alternative using Claude Code's native `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` + `--parent-session-id`, but **0 SKILLs referenced it and only 8 transcripts ever used it** — entirely latent.

**Phase 1 shipped (PR #111 → feat/all-prs-rebased, merge 829664a; central SKILL/workflow commit 5f5dbaf):**
- `scripts/team-dispatch-helper.sh` — one teammate per call. Creates/reuses `<repo>.wt-c-<slug>` on branch `campaign/<slug>`, injects `.agent` + `.secrets` symlinks, runs `maw team create` + `maw team spawn --model sonnet --prompt …` without `--exec` (captures the `Run:` claude cmd), then `tmux split-window -c <wt>` so the teammate's pane starts cwd-correct in its worktree. Closes the gap that `spawnTeammatePane` (layout-manager.ts L119) has no cwd flag — wraps around it instead of patching maw-js.
- `scripts/team-dispatch-finish.sh` — `maw team shutdown <slug> --merge --force` (preserves findings to `ψ/memory/mailbox/<role>/`), removes every `*.wt-c-<slug>` worktree, `maw cleanup --zombie-agents --yes`.
- SKILL.md §"How I work" split: **workflow-2 (team dispatch) = default** for orchestrator-driven campaigns; workflow-1 (envelope+watcher) demoted to cron path (W1/W2/W9 daily baselines only).
- `references/workflow-2-team-dispatch.md` — full 142-line step-by-step.

**Locked design (from planning conversation):**
- Worktree granularity = **per (campaign × repo)** — agents in the same repo + campaign share one worktree. Reduces the worktree count behind the 47-wt hand-purge by ~10×.
- Topology: pane-per-teammate inside the orchestrator's own tmux window. Each campaign already gets its own window via `/new orchestrator <slug>` in brew-ops-bot — no daemon changes needed.
- Telegram daemon = **unchanged**. brew-ops-bot's existing `/new <role> [slug] [engine]` + `/chat <role>/<slug>` + `/close` already handle the multi-orchestrator chat model the user wanted. mb_orchrestrator_bot left for future retirement.
- [[orchestrator-scope-guard-pretooluse-hook-enforce]] unchanged: its matcher `orchestrator-*` keys on the window name, so teammates (different window names) are no-op'd and keep full edit rights.

**Reusable mechanic (how to add a new replace-the-watcher path):** the `maw team spawn` without `--exec` prints `  Run: <claude cmd>` — capture via `sed -n 's/^  Run: //p'`, then split with `tmux split-window -c <cwd> "$cmd"`. Any wrapper that needs to set cwd, env, or open in a specific tmux target can do this without patching `spawnTeammatePane`.

**Phase 2 (not done):** retire mb_orchrestrator_bot + chat-watcher of it. Optional `maw team` upstream PR to add `--cwd` flag and per-campaign mailbox subdir.

---
*Added via Oracle Learn*
