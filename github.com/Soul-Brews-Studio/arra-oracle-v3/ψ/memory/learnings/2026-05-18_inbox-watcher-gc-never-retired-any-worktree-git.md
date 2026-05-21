---
title: inbox-watcher gc never retired any worktree — `git worktree remove` ran against 
tags: [inbox-watcher, gc, git-worktree, fleet, brew-ops]
created: 2026-05-18
source: brew-ops thread #162 — inbox-watcher gc audit
project: github.com/soul-brews-studio/arra-oracle-v3
---

# inbox-watcher gc never retired any worktree — `git worktree remove` ran against 

inbox-watcher gc never retired any worktree — `git worktree remove` ran against a non-repo path.

`scripts/inbox-watcher.sh` `maybe_retire_worktree()` invoked `git -C "$wt_path/.." worktree remove "$wt_path"`. maw creates worktrees as SIBLINGS of the main checkout (`<repo>.wt-N-<suffix>` next to `<repo>`), so `$wt_path/..` is the directory that holds both — not a git repo — and the remove returned `fatal: not a git repository` → nonzero → `retire FAILED (git worktree remove returned nonzero — keeping)` on every sweep. `repo_path` (branch cleanup) had the same class of bug: `git -C "$wt_path" rev-parse --show-toplevel` from inside a linked worktree returns the worktree itself, not the main repo.

Consequence: the gc reclaimed ZERO worktrees in its lifetime — 233 state files all `ret=no`, zero `RETIRED`/`pruned` log lines (2026-05-03 → 2026-05-18). The 47→5 / 26→15 worktree reductions were all manual purges. `safe_to_retire`'s gates were all sound; the gc just could never execute the removal.

Fix (fork PR #79, branch `fix/inbox-watcher-gc-retire-repo-path`): derive the main repo as `${wt_path%.wt-*}` — the same string strip `discover_repos`/`gc_try_prune_worktree` already use correctly. The orphan-prune path (`gc_try_prune_worktree`) was never affected because it gets `$repo` from `discover_repos`.

Lesson: in this repo's layout worktrees are SIBLINGS of the main checkout, never children — `$wt_path/..` is never the repo, and `rev-parse --show-toplevel` from a linked worktree is never the main repo. Use `${wt_path%.wt-*}`.

Separate, still-open gc gap: `gc_retire_completed` only iterates `status=completed`, so `failed_no_prompt`/`failed_stuck` envelopes' worktrees are referenced-by-state (orphan-prune skips them) but never retired — a dead zone.

#repo:arra-oracle-v3 #fleet #brew-ops #gotcha #drift #tmux

---
*Added via Oracle Learn*
