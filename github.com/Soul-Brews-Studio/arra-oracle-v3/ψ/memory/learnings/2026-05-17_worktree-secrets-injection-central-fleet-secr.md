---
title: Worktree `.secrets` injection — central fleet secret store + per-repo symlinks (
tags: [fleet-secrets, worktree, maw-wake, symlink-injection, credentials, brew-ops, decision]
created: 2026-05-17
source: orchestrator thread #147 — brew-ops 2026-05-17
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Worktree `.secrets` injection — central fleet secret store + per-repo symlinks (

Worktree `.secrets` injection — central fleet secret store + per-repo symlinks (#repo:cross #fleet #brew-ops #decision)

`.secrets/` (runtime credentials, e.g. `.secrets/supabase.env`) is gitignored — exactly like `.agent/` — so it is NOT carried into a fresh git worktree. Agents (next-impl on mb-next) were reconstructing `.secrets/supabase.env` by hand in every new worktree; worse, the hosted Supabase DB password (`SUPABASE_DB_PASSWORD`, needed by `supabase db push`) is not retrievable via `supabase projects api-keys`, so manual recovery physically cannot restore it. This blocked the #146 hosted re-push.

Solution (orchestrator thread #147, brew-ops 2026-05-17): one central, non-git secret store + per-repo worktree symlinks.

- Central store: `~/.arra-oracle-v2/fleet-secrets/<repo>/` — dir chmod 700, `supabase.env` chmod 600. Outside any git repo. Single source of truth.
- Worktree symlink: `<repo>.wt-*/.secrets → ~/.arra-oracle-v2/fleet-secrets/<repo>`. Gitignored, so invisible to git (same property the `.agent` symlink relies on).
- Auto-injection: maw-js `injectWorktreeSymlinks()` in `src/commands/shared/wake-session.ts` symlinks `.secrets` at worktree-creation (`createWorktree`) and reuse/wake (`wake-cmd.ts` match branch). Idempotent. It derives the target by CONVENTION (`fleet-secrets/<repoName>`), not by mirroring a main-tree symlink the way `.agent` does — so onboarding a new repo needs zero code change. (maw-js PR kxlahsimx09/maw-js#7.)
- Backfill: `arra-oracle-v3/scripts/backfill-worktree-secrets.sh <repo>` links pre-existing worktrees (primary + all `.wt-*`). Idempotent; refuses to delete a real `.secrets/` dir. (PR kxlahsimx09/arra-oracle-v3#73.)
- Documented: arra-oracle-v3 AGENTS.md §3b, mb-next AGENTS.md §11a, brew-ops SKILL.md.

Rule for agents: NEVER reconstruct `.secrets/` by hand and never copy a secret value into a thread/envelope/commit/retro — refer to the store by path only. To onboard another repo: populate `fleet-secrets/<repo>/`, then run the backfill script once.

---
*Added via Oracle Learn*
