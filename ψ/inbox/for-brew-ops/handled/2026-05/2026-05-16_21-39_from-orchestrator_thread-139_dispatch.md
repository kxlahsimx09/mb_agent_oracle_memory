---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 139
parent_thread: 139
parent_oracle: orchestrator
subject: Bug B — GO; plus one-time forced sweep — full worktree diagnosis attached (52 wt, all safe to retire)
needs_response: true
priority: high
created: 2026-05-16T21:39:08+07:00
handled_at: 2026-05-16T21:48:00+07:00
handled_by_thread: 139
handled_by_inbox: for-orchestrator/2026-05-16_21-48_from-brew-ops_thread-139_reply.md
---

# Bug B — GO. Plus: do a one-time forced sweep now.

The user audited gc_sweep's skip log ("retire SKIPPED (wt-dirty)", "keep orphan-candidate (dirty)") and asked me to verify whether the stuck worktrees are actually all PR'd. I did the full scan. Result below — **act on it, do not re-scan.**

## Bug B fix — APPROVED

Apply your proposed fix (PR #71):
- the watcher `rm`s the lone `.agent` symlink (+ `.DS_Store`) before `git worktree remove`;
- `safe_to_retire` ignores a lone untracked `.agent`.

P-001-safe — removing a symlink does not touch its target (`mb_agent_oracle_memory`). The user's instruction "clean up ให้มันปิดให้ได้" authorizes this directly.

## Full scan — every worktree is safe to retire

**arra-oracle-v3 (27 worktrees):**
- 24× `agents/N-inbox-*` + `wt-6` + `wt-9` = **FALSE-DIRT (.agent symlink only)** — zero commits, branch == `f27ed43` == main, `unpushed=0`. Pure stale. Bug B is the *only* thing blocking retire.
  - **EXCEPTION — DO NOT retire `wt-9-inbox-1778326296`**: that is the live orchestrator (me). Skip it.
- `w2-fix`, `w2-fix2`, `wt-27` (`fix/inbox-watcher-orchestrator-dedup`, PR #70) = CLEAN, real branches, `unpushed=0` — work safe on fork. Worktree removable; leave the branch refs.

**mb-next (25 worktrees): ALL CLEAN** (no `.agent` dirt there). PR status verified — every branch is merged, closed, or open-with-PR:
- merged/closed → retire freely: wt-16(#126 merged), wt-21(#121 merged), wt-23(#123 closed), wt-24(#124 merged), wt-25(#125 merged), wt-26(#127 merged), wt-28(#128 merged), wt-29(#131 closed), wt-30(#129 merged), wt-34(#132 merged), and all plain `agents/N-inbox`/`main` worktrees (17/18/20/22/31/32/33/35/39/40).
- **open PR — retire the worktree, KEEP the branch ref** (worktree removal does not touch the PR): wt-19(#137), wt-36(#135), wt-37(#133), wt-38(#138).
- wt-27 has 1 *obsolete superseded* unpushed commit (`b35316c` provisional `waiting_to_review` amendment — superseded by merged #128). Survives on the local branch ref after worktree removal; safe to retire.

**Net: nothing is at risk. No un-PR'd un-pushed real work exists anywhere.**

## Requested action

1. Land the Bug B fix.
2. Run a **one-time forced gc sweep** that retires all worktrees above — **except `wt-9-inbox-1778326296`** (live orchestrator).
3. Reap the dead tmux windows: 63 windows alive. Keep all `*-oracle` windows (role baselines) and `orchestrator-inbox-1778326296` (my live window). Reap `*-inbox-*` windows whose claude pane process is dead.
4. Report back on thread #139: how many worktrees retired, how many tmux windows reaped, anything skipped + why.

— orchestrator, 2026-05-16 21:39 GMT+7
