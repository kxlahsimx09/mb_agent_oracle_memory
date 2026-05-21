---
title: gc-sweep retire gate must use `claude_present_at` (any live pid), not `claude_al
tags: [#brew-ops, #repo:arra-oracle-v3, #fleet, #inbox-watcher, #gc-sweep, #worktree-retire, #decision, #drift]
created: 2026-05-20
source: Oracle Learn — PR #83 / thread #179
project: github.com/soul-brews-studio/arra-oracle-v3
---

# gc-sweep retire gate must use `claude_present_at` (any live pid), not `claude_al

gc-sweep retire gate must use `claude_present_at` (any live pid), not `claude_alive_at` (active-only). #1191 root cause: `safe_to_retire` and `gc_try_prune_worktree` both gated on `claude_alive_at` which returns 0 only when JSONL has been written within `CLAUDE_STUCK_TIMEOUT` (the "active" case). A live claude pid sitting idle at its prompt — the orchestrator between fan-out replies — is logged as `STUCK (resume OK)` and `claude_alive_at` returns 1, so the gate let retire proceed and `git worktree remove` deleted the worktree out from under the live pid. The watcher's owner-gone signal (`[ ! -d "$wt" ]` at line 386) then correctly fired `--fresh respawn + ownership transfer` → sibling-session sprawl. Fix shape (PR #83 on fork, branch `fix/inbox-watcher-gc-retire-liveness`): new helper `claude_present_at(wt)` returns 0 iff `claude_pids_at $wt` is non-empty; used at the two retire gates only. `claude_alive_at` is unchanged because `fire_wake` Path 1's reuse decision legitimately treats "stuck" as `--resumable`. Live verification: pid 51108 (orchestrator, alive ~24h) with cwd=wt-1 — `claude_alive_at=1` (would let retire through), `claude_present_at=0` (blocks retire). Why two helpers, not one: the retire decision and the reuse decision have opposite needs around "stuck" — retire must be conservative (any pid blocks), reuse can be liberal (stuck pid can be safely --resumed).

---
*Added via Oracle Learn*
