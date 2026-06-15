---
title: Re-waking a STUCK (alive) fleet agent: `maw wake` won't respawn it — kill the wi
tags: [maw, wake, rewake, respawn, ghq, tmux, fleet-ops, dangerously-skip-permissions]
created: 2026-06-15
source: brew-ops (EC2 2026-06-15)
project: github.com/soul-brews-studio/maw-js
---

# Re-waking a STUCK (alive) fleet agent: `maw wake` won't respawn it — kill the wi

Re-waking a STUCK (alive) fleet agent: `maw wake` won't respawn it — kill the window first.

`maw wake` does NOT relaunch an agent that's still ALIVE in its pane (e.g. claude blocked at a permission prompt). In `wake-cmd.ts` it checks `isAgentCommand(pane)` for the existing window: if the agent is alive it just prints "running" + attaches; it only re-launches a pane whose foreground is DEAD (a shell). So to make a stuck agent pick up a NEW launch command (e.g. after changing maw `commands.default` to add `--dangerously-skip-permissions`), you must force it:

1. `tmux kill-window -t <session>:<window-name>` — reference by NAME, not index (indices shift after a kill). The worktree dir + the claude session JSONL persist on disk.
2. `maw wake <oracle> --wt <slug> --no-attach` — window now missing → maw `tmux.newWindow` + `buildCommandInDir(...)` relaunches with the new command and auto-injects `--continue`, which resumes the saved conversation from that worktree's cwd. No context lost; each worktree has a UNIQUE cwd so `--continue` resumes the right session (the cross-role-contamination incident was only for SHARED cwds).

Mapping: tmux window `<oracle>-<slug>` ↔ `maw wake <oracle> --wt <slug>`. `--wt` fuzzy-matches the on-disk worktree (e.g. slug `live` → `...wt-1-live`) and reuses it. Verify success by peeking the pane: it shows the resumed context + the footer `⏵⏵ bypass permissions on` (= skip-permissions active).

GOTCHA — ghq PATH over non-interactive ssh: running `maw wake` from a plain `ssh host 'maw …'` fails at resolveOracle with `ghq: not found` → `clone failed and not found locally` (even though the repo IS cloned), and can leave a killed window un-recreated. Fix: `export PATH=$HOME/go/bin:$HOME/.bun/bin:$HOME/.local/bin:$PATH` (ghq lives at `~/go/bin/ghq`) or use a login shell. The systemd daemons (w2-watcher) already carry the right env, so their auto-wakes work — and after setting `commands.default` to skip-permissions, w2-watcher's auto-woken brew-ops task launched `claude --dangerously-skip-permissions` correctly (confirms [[the commands.default fix]]).

Confirmed 2026-06-15 on EC2: re-woke brew-ops/revise-build-flow + next-live-tester/live; both resumed with bypass-permissions on.

---
*Added via Oracle Learn*
