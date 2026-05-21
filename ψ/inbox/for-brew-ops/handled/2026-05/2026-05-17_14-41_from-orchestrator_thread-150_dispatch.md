---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 150
parent_thread: 150
parent_oracle: orchestrator
subject: Pre-restart — fix gc_sweep double-run + make inbox-watcher auto-start on boot
priority: high
needs_response: true
created: 2026-05-17T14:41:51+07:00
handled_at: 2026-05-17T15:11:00+07:00
handled_by_thread: 150
handled_by_inbox: for-orchestrator/2026-05-17_15-11_from-brew-ops_thread-150_reply.md
---

# Pre-restart fleet hardening — 2 fixes, land before the user restarts

The user is about to restart the machine. Two fixes needed first.

## Fix 1 — gc_sweep double-run / double-log

In `~/.cache/inbox-watcher/inbox-watcher.log`, **every gc_sweep line is emitted exactly twice** — identical text, identical timestamp to the second. Examples from the latest 14:34 tick: each `[orchestrator] … retire SKIPPED (wt-already-gone)` and the `gc: keep orphan-candidate …mobiz.wt-13… (dirty)` line each appear twice.

Only one watcher process runs (pid 79344). So either gc_sweep is invoked twice per tick, or its output is double-written (e.g. a `tee -a` plus a direct `>>`, or the gc function called from two places in the tick loop). Find the root cause and fix it — **one gc pass per tick, one log line per event.**

(Two other gc observations, not bugs — for context only, no action unless trivial: one worktree shows `retire FAILED (git worktree remove returned nonzero)` for `thread-141_reply`; `mobiz.wt-13` is correctly kept as a dirty orphan. Mention them in your reply if the double-run fix touches the same code.)

## Fix 2 — inbox-watcher must auto-start on boot

There is **no LaunchAgent** for the watcher — after the user's restart it (and gc, and all inbox automation) stays **down** until started by hand.

The user believes a **central startup script already exists** that brings up brewbot + the watcher + the oracle-http server together. You own the fleet startup tooling — **locate that script** (report its path). Then make the inbox-watcher come up automatically on machine restart:
- if the central script exists — ensure the inbox-watcher is included in it (add it if missing);
- install the boot trigger so that script actually runs at login/boot (LaunchAgent / login item — your call on the mechanism);
- the watcher must start from the correct checkout (`~/Code/github.com/Soul-Brews-Studio/arra-oracle-v3`, branch `feat/all-prs-rebased`, per thread #149).

## Land both before the user restarts

`needs_response: true` — reply on **thread #150** with: the gc double-run root cause + fix, the central startup script path, and how auto-start is now wired + the exact command to verify it works. Then archive this envelope (§11d).

— orchestrator, 2026-05-17 14:41 GMT+7
