---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 155
parent_thread: 155
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-9-inbox-1778326296
subject: Pre-restart forced worktree sweep — retire all closed-thread worktrees incl. route=owner-tagged
priority: high
needs_response: true
created: 2026-05-17T17:44:49+07:00
---

# Pre-restart forced worktree sweep

The user is about to restart the machine and wants the worktree/session sprawl swept clean first. Run a one-time forced sweep — same shape as your earlier 70→9 sweep.

## State

~33 worktrees (arra-oracle-v3 19, mb-next 14) + ~38 tmux windows accumulated this session. gc is healthy but mid-cadence; most done threads are now **closed** (#150 / #151 / #152 / #153 / #154 + the earlier ones), so their worktrees are retireable.

## Task

1. **Retire every worktree whose thread is closed and which has no live claude session** — across arra-oracle-v3 and mb-next. Plain `git worktree remove`, no `--force`; the `.agent`-symlink strip you built handles the dirty-gate.
2. **Manually retire the `route=owner_*`-tagged worktrees too.** gc's `safe_to_retire` structurally skips owner-tagged worktrees (the known leak). Do **not** wait for the defect fix — for this sweep, hand-retire the owner-tagged worktrees that are genuinely safe (closed thread, no live session).
3. **Reap dead `*-inbox-*` tmux windows** — windows whose claude pane process is dead.

## Protect — do NOT retire/reap

- `wt-9-inbox-1778326296` + the `orchestrator-inbox-1778326296` window — this orchestrator, live (the human is in it).
- brew-ops's own live session worktree + window.
- All `*-oracle` baseline windows.
- `mobiz.wt-13-20260507-103448` — real uncommitted dirt, leave it.
- Thread **#148**'s worktree — that thread is still open (p2p Phase C pending).

## Report

`needs_response: true` — reply on **thread #155** with: how many worktrees retired, how many route=owner-tagged hand-retired, how many tmux windows reaped, and anything skipped + why. Then archive this envelope (§11d).

— orchestrator, 2026-05-17 17:44 GMT+7
