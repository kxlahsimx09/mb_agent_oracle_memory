---
title: Manual fleet worktree-retire (the #237 pattern, executed by brew-ops): how to cl
tags: [brew-ops, repo:cross, fleet, tmux, worktree-retire, inbox-watcher, gotcha, decision]
created: 2026-05-27
source: thread #252 cleanup run, 2026-05-27 GMT+7; inbox-watcher.sh safe_to_retire/maybe_retire_worktree lines ~1500-1614
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Manual fleet worktree-retire (the #237 pattern, executed by brew-ops): how to cl

Manual fleet worktree-retire (the #237 pattern, executed by brew-ops): how to clear an orchestrator's closed-campaign footprint safely.

Context: orchestrator dispatched brew-ops (thread #252) to retire the worker footprint of its closed campaigns #238–#249 (spanning next-writer/next-architect/pg-writer/brew-ops workers across arra-oracle-v3 + mb-next-payment-gateway + mobiz-payment-gateway). Retired 11 worktrees + 11 tmux windows + 11 merged branches + 33 worker-side session-cache files, with zero `--force`.

Reusable mechanics (mirror `inbox-watcher.sh` `safe_to_retire` + `maybe_retire_worktree`, lines ~1500-1614):
1. ATTRIBUTION is via the watcher session cache, not branch names. `~/.cache/inbox-watcher/sessions/<oracle>/thread-<wake_key>.owner` holds the worktree path; `.session-id`/`.session-engine` pair with it. The owner file is authoritative for (oracle, wake_key). Branch-name slugs can carry a DIFFERENT thread number than the wake_key (e.g. branch `next-writer/settle-batch-243` lived under wake_key 242; `architect/adr12-...-thread244` under wake_key 242) — the slug only corroborates; never attribute by slug alone. Sub-threads (#240/#241/#244 here) often have NO own worktree — they ran under a parent campaign's wake_key and retire with that parent's worktree.
2. The git-clean gate EXCLUDES the maw-injected `.agent` symlink (and `.DS_Store`): `git status --short | grep -vE '^\?\? \.(agent|DS_Store)/?$'`. A worktree showing ONLY `?? .agent` is gate-CLEAN and retire-safe (the symlink is injected, not work). `strip_worktree_noise` removes it (symlink-only — `[ -L ... ] && rm -f`; the central mb_agent_oracle_memory target is untouched = P-001-safe) so the otherwise-clean worktree isn't rejected. Whether `.agent` shows as `??` (untracked) vs ignored depends on the .gitignore at that worktree's HEAD commit — base merge commits in arra-oracle-v3 don't ignore it, feature branches do.
3. No-unpushed check: `git log '@{u}..' --oneline` empty AND HEAD reachable from a remote ref (`git branch -r --contains HEAD`). All campaign PRs merged ⇒ branches clean.
4. Remove with `git -C <MAIN_REPO> worktree remove <wt>` (NO --force — refuses real dirt). repo_path = wt_path with `.wt-*` tail stripped; a linked worktree cannot remove itself and the shared parent dir is not a repo.
5. Branch delete is `git branch -d` (merged-only, never -D). Kill the tmux window by resolving window-id from its unique name then `tmux kill-window`.

LEAVE rules that bit here:
- Orchestrator-side session cache for the closed threads pointing to a LIVE session (wt-25, the dispatcher itself) must be LEFT — §11f evicts it only when that owning session itself retires; mutating a live session's routing cache mid-campaign is unsafe and pointless. Worker-side cache (paired with the retired worktrees) IS evicted.
- An orchestrator worktree that is not a worker and not on the retire-list (here wt-28, owning #243 orchestrator-side) is ambiguous → LEAVE + flag, never retire a worktree you can't positively attribute to a listed thread.
- `state/*.state` files are kept as §11i 7-day audit (not deleted) — they're ephemeral cache, not vault, and auto-expire; the canonical retire sets `retired_at` and keeps them.
- Campaign-scope the Step 0.5 inbox sweep: a sibling session's envelope (here a #216 load-test consult in for-brew-ops/) is left untouched — handle only your own wake_key (§214).

---
*Added via Oracle Learn*
