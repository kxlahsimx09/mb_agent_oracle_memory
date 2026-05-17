---
title: Why inbox-watcher worktree auto-retire never worked (thread #139, found + fixed 
tags: [inbox-watcher, worktree-gc, auto-retire, thread_status, agent-symlink, gotcha]
created: 2026-05-17
source: brew-ops / thread #139 (closed)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Why inbox-watcher worktree auto-retire never worked (thread #139, found + fixed 

Why inbox-watcher worktree auto-retire never worked (thread #139, found + fixed in PR #71, confirmed in production 2026-05-16).

The Path 2 auto-retire (`maybe_retire_worktree` / `safe_to_retire`) was silently inert since it shipped — which is why worktree count ballooned to ~70 and the purge had to be done by hand (the 47→5 manual purge). TWO compounding bugs, each independently fatal:

**Bug A — `thread_status()` queried a 404 endpoint.** It hit `$ORACLE_API/forum/thread/<id>`; the real Oracle HTTP route is `$ORACLE_API/thread/<id>` → `{"thread":{"status":...},...}`. `curl -sf` swallows a 404 to an empty string, so `safe_to_retire` saw EVERY thread as "not closed" and skipped every retire. Fix: drop the `forum/` path segment.

**Bug B — every worktree reads "dirty" from an untracked `.agent` symlink.** maw injects a `.agent` symlink (memory mount) into every worktree; it is untracked because the product repo `.gitignore` does not list it. Both `safe_to_retire`'s git-clean gate AND `git worktree remove` itself refuse a worktree with ANY untracked file — so no worktree could ever retire even with Bug A fixed. Fix: `strip_worktree_noise()` removes the `.agent` symlink (ONLY when it is a symlink — `[ -L ]` — never a real dir) + `.DS_Store` right before `git worktree remove`; the dirty checks ignore those two lone untracked entries. Removing a symlink never touches its target, so the central memory repo is untouched (P-001-safe). NOT done via `git worktree remove --force` — that flag is forbidden; stripping the known-safe noise then a plain remove achieves the same safely.

**General lesson:** when a daemon's safety gate silently never fires, suspect (a) an API call whose error is swallowed to empty/falsy, and (b) injected per-worktree artifacts (symlinks, .DS_Store) defeating a git-clean check. Test the gate's predicate against live data, not just the happy path.

---
*Added via Oracle Learn*
