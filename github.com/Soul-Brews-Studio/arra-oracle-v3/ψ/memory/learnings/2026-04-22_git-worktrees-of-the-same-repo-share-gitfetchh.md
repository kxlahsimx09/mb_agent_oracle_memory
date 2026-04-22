---
title: Git worktrees of the same repo share `.git/FETCH_HEAD` (and most .git/ state). C
tags: [brew-ops, repo:cross, infrastructure, gotcha, git, worktree, race-condition, 2026-04-22]
created: 2026-04-22
source: commit 2769ed8 on arra-oracle-v3 feat/all-prs-rebased-2026-04-20 branch; live observation 2026-04-22 01:27 watcher run
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Git worktrees of the same repo share `.git/FETCH_HEAD` (and most .git/ state). C

Git worktrees of the same repo share `.git/FETCH_HEAD` (and most .git/ state). Concurrent `git fetch` operations from two worktrees write to the same FETCH_HEAD simultaneously — a following `git pull --ff-only origin main` can read contaminated state and fail with:

```
fatal: Cannot fast-forward to multiple branches.
```

Even when the local branch is clean, on main, and straightforwardly fast-forwardable. The pull command resolves the merge target via FETCH_HEAD which now has multiple "for-merge" entries after the race.

**Fix: use `git merge --ff-only origin/main` (or `<remote>/<branch>`) instead of `git pull --ff-only origin main`.**

```bash
# Before (race-prone):
git fetch origin main --quiet
git pull --ff-only origin main --quiet

# After (race-safe):
git fetch origin main --quiet
git merge --ff-only origin/main --quiet
```

`git merge` reads the remote-tracking ref (`refs/remotes/origin/main`) directly, bypassing FETCH_HEAD entirely. The fetch still races on FETCH_HEAD but that's harmless — it just updates `refs/remotes/origin/main` which is atomic per-ref.

**Observed:** 2026-04-22 01:27 in `arra-oracle-v3/scripts/regression-then-investigate.sh`. Timing:
- 01:27:22 pg-tester wake fires → spawns regression script → runs `git fetch origin main` in $MOBIZ
- 01:27:26 pg-writer wake fires (5s later) → claude in wt-15 worktree does its own `git fetch origin` (all branches via default wildcard refspec)
- 01:27:28 regression's `git pull --ff-only origin main` reads contaminated FETCH_HEAD → "Cannot fast-forward to multiple branches" → Telegram "regression skipped" + exit 1

**Applied in:** `arra-oracle-v3/scripts/regression-then-investigate.sh` Step 2 (both $MOBIZ and $MOBIZ/bank-bot syncs), commit `2769ed8`.

**How to apply:** Any automation that pulls in a repo where another process (other worktree, another user, concurrent script) may also be fetching. Use explicit-ref merge, not pull-by-name.

**Note:** This is NOT fixed by `git config pull.ff only` or similar — those affect git's pull behavior but pull still reads FETCH_HEAD. The fix is to not use `pull` for the merge step at all.

---
*Added via Oracle Learn*
