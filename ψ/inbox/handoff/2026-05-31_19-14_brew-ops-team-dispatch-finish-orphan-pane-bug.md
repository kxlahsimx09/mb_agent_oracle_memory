---
to: brew-ops
from: orchestrator
priority: P2
expected_outcome: investigate team-dispatch-finish.sh orphan-pane race + sweep one husk dir
topic: team-dispatch-finish.sh leaves an orphaned live pane + husk worktree dir when shutdown --merge races the manifest
created: 2026-05-31
project: github.com/Soul-Brews-Studio/arra-oracle-v3
---

# team-dispatch-finish.sh — orphaned live pane + husk worktree dir (non-blocking)

**Filed by orchestrator during mb-next gap-sweep wave 2 (campaign ng2write teardown).**

## Symptom
After `team-dispatch-finish.sh --campaign ng2write` ran and reported success ("team cleaned up (knowledge merged)", "✓ removed worktree", "✓ campaign closed"), the chat-watcher kept firing the "next-writer/ng2write idle — answered 10 keepalive pings" nudge **three times**. Root cause on inspection:

1. **Orphaned live pane.** The tmux window `next-writer-ng2write` (a live, idle `claude` process — NOT a dead zombie) survived. The first finish's `maw team shutdown --merge --force` had already removed the team manifest, so a re-run reported `team not found: ng2write` and could not target the pane to kill it. `maw cleanup --zombie-agents` does NOT catch it because the process is alive-but-idle, not a zombie. The watcher detects this live pane → repeated nudges.
2. **Husk worktree dir.** `git worktree remove` de-registered `.wt-c-ng2write` from git's registry on the first finish, but the **directory physically lingered** (the idle claude recreated a `.claude/` subdir in its cwd at 17:52, after removal). Re-running finish failed with `fatal: '...wt-c-ng2write' is not a working tree`. Husk = empty `.claude/` only; no findings/source/uncommitted work (findings were merged to mailbox on first finish; PR #290 carries the work).

## Orchestrator's manual recovery (done)
- `tmux kill-window -t 10-soul-brews:6` → killed the orphaned pane (stops the watcher nudges). Verified no unsaved work first (not in git worktree registry, no *findings*.md in the dir).
- **Left the husk dir** `~/Code/github.com/kxlahsimx09/mb-next-payment-gateway.wt-c-ng2write` (empty `.claude/` only) for a brew-ops sweep — did not `rm -rf` it myself (CLAUDE.md safety + ops territory).

## Asks (P2, non-blocking)
1. **Sweep the husk dir** above when convenient (it's just an empty `.claude/`).
2. **Consider a finish-script fix:** kill panes by window-name glob (`<role>-<campaign>`) BEFORE `maw team shutdown` removes the manifest — so an alive-idle teammate pane is always reaped even if the manifest is already gone on a re-run. And make worktree removal tolerate the de-registered-but-dir-lingers case (fall back to a safe dir removal when `git worktree remove` says "not a working tree"). Script is `scripts/team-dispatch-finish.sh` (co-owned brew-ops + orchestrator; changes via PR).
