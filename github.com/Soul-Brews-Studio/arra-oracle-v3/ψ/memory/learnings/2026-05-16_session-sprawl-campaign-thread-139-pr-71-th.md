---
title: Session-sprawl campaign (thread #139, PR #71) — three durable facts beyond the c
tags: [inbox-watcher, session-sprawl, wake-key, worktree-gc, agent-bak, P-001, gotcha]
created: 2026-05-16
source: brew-ops / thread #139
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Session-sprawl campaign (thread #139, PR #71) — three durable facts beyond the c

Session-sprawl campaign (thread #139, PR #71) — three durable facts beyond the code:

1. **Wake-key keying is now campaign-scoped for ALL oracles.** `inbox-watcher.sh::wake_key()` returns `parent_thread` (if the envelope carries one) for every oracle, not just `orchestrator`. So a worker agent's repeated sub-task envelopes of one campaign `--resume` ONE session (fire_wake Path 1), not one per sub-thread. The orchestrator-only `deferred`/`parent_session_busy` dedup is a *separate* mechanism — kept orchestrator-gated because only the orchestrator re-dispatches; workers don't, so they get session reuse but not deferral. Don't conflate "campaign wake-keying" with "fan-out dedup".

2. **`.agent.bak-*` pruning is deliberately OUT OF SCOPE for any GC routine.** Thread #139 asked to auto-prune stale `.agent.bak` dirs; this was refused. `.agent.bak-*` dirs can hold pre-symlink `.agent/` memory content — auto-deleting them risks a P-001 ("Nothing is Deleted") violation, and AGENTS.md §3a explicitly says to leave them. `#tag:gotcha` — if a future brief asks to "prune backups / clean .agent.bak", escalate to human ratification; do not code a daemon deletion.

3. **Gotcha — worktree reference checks must compare BASENAMES, not full paths.** When the GC sweep checks "is this worktree still referenced by an envelope state file?", git's `worktree list` reports a path that can differ from the maw-captured `wt_path` by a prefix (`/tmp` vs `/private/tmp` symlink resolution). An exact full-path `grep` MISSED the match and pruned a referenced worktree in testing. Fix: `any_state_references_wt()` matches `^wt_path=.*/<basename>$`. Worktree basenames carry a unique timestamp suffix so basename collisions can't happen, and a loose match errs toward "keep" (safe). Same caution applies anywhere maw-captured paths are compared against git-reported paths.

---
*Added via Oracle Learn*
