---
title: **`maw wake` branches new worktrees from `origin/<default>`, not primary worktre
tags: [brew-ops, repo:cross, maw, wake, worktree, git, decision, durable-rule]
created: 2026-05-06
source: brew-ops session 2026-05-06 — root-cause fix from user-reported recurring W1 pain point
project: github.com/soul-brews-studio/maw-js
---

# **`maw wake` branches new worktrees from `origin/<default>`, not primary worktre

**`maw wake` branches new worktrees from `origin/<default>`, not primary worktree HEAD** (post `Soul-Brews-Studio/maw-js` PR #5, merged 2026-05-06).

**Behavior** (`src/commands/shared/wake-session.ts:82`):
1. Resolve `origin/HEAD` via `git symbolic-ref --short refs/remotes/origin/HEAD` (typically returns `origin/main`)
2. Best-effort `git fetch origin --quiet` (non-fatal on offline)
3. `git worktree add <wtPath> -b agents/<N>-<name> <baseRef>`

**Fallbacks** (preserve old behavior — branch from primary HEAD):
- `origin/HEAD` not configured → no starting-point passed
- No `origin` remote → no starting-point passed

**Why this matters**: before PR #5, primary worktree often parked on a stale feature branch from the previous architect/writer session, which propagated stale state to every subsequent `maw wake`. Concrete instance: `mb-next-payment-gateway` primary stuck at `architect/w1-refine-adr-4c-...-2026-04-29` (commit `a526082`) for ~1 week while `main` advanced 8 commits. Architects had to recreate branch from main before doing useful work — every wake.

**How to apply** for any agent triggered via `maw wake`:
- Trust that you start on a fresh `origin/<default>` tip — no need to `git rebase main` defensively
- If you do see stale state, check (a) is `origin/HEAD` set in that repo? (`git remote set-head origin --auto` to fix), (b) was the wake offline?
- Primary worktree state no longer matters for new spawn cleanliness — but keep it tidy for `git status` legibility on the repo itself

**Cost per wake**: +1 `symbolic-ref` (ms) + 1 `fetch origin --quiet` (1-3 sec, network-bound, non-fatal).

---
*Added via Oracle Learn*
