---
title: Runtime-checkout deploy discipline: `feat/all-prs-rebased` is the deploy source-
tags: [brew-ops, repo:cross, fleet, decision, gotcha, deploy, git, feat/all-prs-rebased, inbox-watcher]
created: 2026-05-17
source: thread #149 fleet runtime re-sync, 2026-05-17 GMT+7
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Runtime-checkout deploy discipline: `feat/all-prs-rebased` is the deploy source-

Runtime-checkout deploy discipline: `feat/all-prs-rebased` is the deploy source-of-truth for the Soul-Brews fleet.

Two PRIMARY checkouts are live runtimes, not scratch space:
- `~/Code/github.com/Soul-Brews-Studio/arra-oracle-v3` — cwd of the `inbox-watcher.sh` daemon (the fleet wake mechanism).
- `~/Code/github.com/Soul-Brews-Studio/maw-js` — what `~/.local/bin/maw` execs (`bun src/cli.ts`) on every invocation.

Rules (binding; codified in AGENTS.md §3c + brew-ops SKILL.md "Runtime checkout re-sync"):
1. Both primary checkouts stay on `feat/all-prs-rebased`. Never park a primary on a feature branch.
2. New code lands by MERGE-THEN-PULL: branch → PR into `feat/all-prs-rebased` → merge → `git fetch` + `git merge --ff-only` the primary. Never live-edit a file in a running checkout; never `git checkout <feature-branch>` inside a primary.
3. A live hotfix is a debt: it is unmerged work until PR'd, merged, and the checkout re-synced. Close the loop promptly.
4. A running bash daemon re-reads its own file — after re-syncing the arra-oracle-v3 primary, restart `inbox-watcher.sh` (`stop` → `start`, no `restart` subcommand). `maw` re-execs `src/cli.ts` per call so the maw-js primary needs no restart.

Re-sync procedure (the recurring brew-ops task — thread #149, 2026-05-17): VERIFY BEFORE DISCARDING. If the working tree carries an uncommitted edit, `git diff fork/feat/all-prs-rebased -- <file>` first — empty diff means the edit is contained in the merged PRs (safe to `git restore` + ff); non-empty means unmerged work, stop and flag it. The branch lives on the FORK (`kxlahsimx09`), not `origin` — fetch from `fork`.

Precedent: 2026-05-17 thread #149 re-sync cleaned exactly this drift — a #71/#72 hotfix had been live-edited into `scripts/inbox-watcher.sh`, and the maw-js primary was parked on `feat/worktree-secrets-injection`. Verified the inbox-watcher.sh edit was byte-identical to merged tip → discarded + ff'd arra-oracle-v3 to b9fdb15db, ff'd maw-js to 5a209f224, restarted the watcher (pid 90720 → 79344).

Tags: #brew-ops #repo:cross #fleet #decision #gotcha

---
*Added via Oracle Learn*
