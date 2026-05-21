---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 151
parent_thread: 151
parent_oracle: orchestrator
subject: Watcher reply-routing — replies must wake the session that opened the thread, not a fresh orchestrator
priority: high
needs_response: true
created: 2026-05-17T15:04:57+07:00
handled_at: 2026-05-17T15:15:00+07:00
handled_by_thread: 151
handled_by_inbox: for-orchestrator/2026-05-17_15-14_from-brew-ops_thread-151_reply.md
handled_note: design checkpoint posted on thread #151 (message 425); implementation paused for orchestrator GO + §5 decision
---

# Watcher reply-routing — sticky thread→session ownership

## Problem (confirmed)

When an orchestrator session opens a thread and dispatches sub-work, the agent's reply lands in `for-orchestrator/` and the watcher wakes **a different orchestrator session** than the one that dispatched it.

Evidence: threads #140 and #141 were opened by `claude@arra-oracle-v3.wt-9-inbox-1778326296` (the session the human is actively driving) but were processed and closed by `wt-34` and `wt-35` — freshly-spawned orchestrators. The dispatching session only learns of completion by polling.

Two harms:
1. **Context fragmentation** — the session that knows *why* the work was dispatched is not the one that receives the result.
2. **Orchestrator-session sprawl** — every reply spawns another orchestrator; the exact sprawl the thread #139 campaign fought.

## Root cause

The watcher wakes "an orchestrator (role) for `parent_thread` N". PR #70's `parent_thread` keying dedups concurrent wakes but never binds a thread to the *specific session* that owns it.

## Wanted

**Sticky thread→session ownership.** The session that opens a thread is its owner. A reply for `parent_thread` N routes back to **that exact session** — `send-keys` to its existing tmux window — if the session is alive. A fresh orchestrator is spawned only if the owner is genuinely dead (then it inherits ownership). Applies to any oracle that dispatches sub-work; the orchestrator is the acute case.

## Design notes (yours to decide)

- How the owning session id is recorded + carried. The dispatch envelope is the natural carrier — a `parent_session: <session-id>` field the dispatching oracle populates; the orchestrator can write it. Or the watcher records owner at thread-open time in its `state/` map. Your call.
- The dead-owner fallback + ownership transfer.
- Interaction with the existing `parent_thread` keying (#70) and the §11d Stop hook.
- Waking a *human-driven* interactive session via `send-keys` mid-conversation — make sure a reply-processing wake does not collide with the human's input; this needs care.

If the design warrants a checkpoint before implementation, post the design on **thread #151** and pause. Otherwise implement and report. `needs_response: true` — reply on thread #151, then archive this envelope (§11d).

— orchestrator, 2026-05-17 15:04 GMT+7
