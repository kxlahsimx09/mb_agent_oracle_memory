# brew-ops handoff — pre-restart cleanup (2026-05-08 GMT+7)

User is restarting the machine. Previous brew-ops session went silent (likely self-killed its own claude session). I (current brew-ops in wt-6) ran the housekeeping pass.

## Worktrees — final state

```
/Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3                       f4c3520 [feat/all-prs-rebased]
/Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-6-20260508-172735  f27ed43 [agents/6-20260508-172735]
```

## Removed (heads already reachable from feat/all-prs-rebased or origin/main)

- `arra-oracle-v3.wt-2-20260504-194858` — branch `fix/orchestrator-watchers-and-retry` @ f3d7ddb (merged via PR #50 into feat/all-prs-rebased)
- `arra-oracle-v3.wt-3-20260505-085913` — branch `fix/idle-alert-numbered-menu-only` @ 19c1b41 (merged via PR #63 into feat/all-prs-rebased)
- `arra-oracle-v3.wt-5-20260507-085648` — branch `agents/5-20260507-085648` @ f27ed43 (= origin/main, no unique work)

The fork branches stayed in sync (0/0 with `fork/...`); reachability checks passed on all three before deletion. wt-5 had the `.agent` symlink as the only untracked entry — unlinked the symlink (target in mb_agent_oracle_memory preserved) then removed cleanly without `--force`.

## CANNOT delete — outstanding work

**Main worktree** `/arra-oracle-v3` on branch `feat/all-prs-rebased`:
- 28 commits ahead / 171 commits behind `origin/main` (Soul-Brews-Studio)
- 171 commits AHEAD of `fork/main` (kxlahsimx09) — **not pushed anywhere**
- Contains the entire brew-ops-bot / orchestrator-bot integration: `scripts/brew-ops-bot/`, `scripts/orchestrator-bot/`, `scripts/inbox-watcher.sh`, `scripts/w2-watcher.sh`, `scripts/worktree-janitor.sh`, plus `src/tools/learn.ts`, `src/tools/inbox.ts`, vector adapter changes
- Tip: `f4c3520 Merge pull request #64 from kxlahsimx09/fix/w2-watcher-silent-fail-per-role`

This is the integration branch that aggregates all the per-feature fork PRs. Decision needed: push to fork? open upstream PR? rebase onto current origin/main (171 behind)? Don't blow it away.

## Stale local branches (not deleted — out of scope)

`git branch --list 'agents/*'` shows ~30 stale `agents/N-...` and `agents/N-inbox-...` branches from prior wakes. None have worktrees. Can be pruned later if user wants.

## Sessions / processes (user is restarting, so moot, but logged)

tmux session `01-soul-brews`:
- window 0 `brew-ops-oracle` — pane pid 87442, cwd = main worktree, claude pid 88751 on ttys026
- window 1 `brew-ops-20260508-172735` — pane pid 89356, cwd = wt-6, claude pid 90726 on ttys027 (← this brew-ops session)

Restart will reap both.
