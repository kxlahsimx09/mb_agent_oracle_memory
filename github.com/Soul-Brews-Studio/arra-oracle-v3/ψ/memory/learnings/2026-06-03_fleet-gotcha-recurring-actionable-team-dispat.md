---
title: FLEET GOTCHA (recurring, actionable) — team-dispatch-finish.sh leaves the teamma
tags: []
created: 2026-06-03
source: orchestrator session 2026-06-03 — 6 campaigns, finish-script orphan pane observed every time; local-main-staleness caught in nextverify2 rerun
project: github.com/soul-brews-studio/arra-oracle-v3
---

# FLEET GOTCHA (recurring, actionable) — team-dispatch-finish.sh leaves the teamma

FLEET GOTCHA (recurring, actionable) — team-dispatch-finish.sh leaves the teammate's claude pane IDLE-ALIVE; orchestrator must kill the window explicitly after finish.

OBSERVED 6× in one session (2026-06-03 campaigns depprobe, nextclean, nextverify, nextrev9, nextfixa, nextverify2): scripts/team-dispatch-finish.sh runs `maw team shutdown --merge --force` which reports "All teammates already exited / cleaned up" AND removes the wt-c-<slug> worktree AND `maw cleanup --zombie-agents` finds "No zombie agent panes" — yet the teammate's claude TUI pane is STILL RUNNING (idle, "⏺ Idle." loop), because the team-manifest shutdown and the actual tmux pane lifecycle are decoupled. The chat-watcher then nags "teammate looks idle/done — answered 10 keepalive pings." 

WORKAROUND (orchestrator, every finish): after team-dispatch-finish.sh, explicitly verify + kill: `tmux list-panes -a -F '#{pane_id} #{window_name}' | grep <pane>` then `tmux kill-window -t <role>-<slug>`. The zombie-agents sweep does NOT catch an idle-but-alive teammate pane (it only catches true zombies). Do this BEFORE considering the campaign closed.

RELATED GOTCHA (caught by next-tester, same session): a fresh team-dispatch worktree branches campaign/<slug> from LOCAL main, which lags origin/main after PR merges (local main was 6bd9538 while origin/main had advanced to fe3065c post-merge of #316/#317/#318). So a "rerun on post-fix main" campaign spawned at the PRE-fix HEAD. The tester self-corrected by `git merge --ff-only origin/main` in its worktree before running. Mitigation: orchestrator should ensure the mb-next primary local main is ff'd to origin/main (AGENTS §3c) BEFORE spawning a campaign that must run at a just-merged HEAD, OR instruct the teammate to fetch+ff its worktree first.

tags: [orchestrator, brew-ops, team-dispatch, fleet-infra, finish-script-orphan-pane, idle-pane-not-zombie, chat-watcher-nag, local-main-staleness, worktree-spawns-pre-fix, gotcha, repo:arra-oracle-v3, maw-js, fleet]

---
*Added via Oracle Learn*
