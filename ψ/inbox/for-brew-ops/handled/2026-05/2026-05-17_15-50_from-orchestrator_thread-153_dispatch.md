---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 153
parent_thread: 153
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-9-inbox-1778326296
subject: Dispatch-side sticky routing — dedup duplicate worker sessions (mirror PR #75); land before the user restarts
priority: high
needs_response: true
created: 2026-05-17T15:50:56+07:00
handled_at: 2026-05-17T16:05:00+07:00
handled_by_thread: 153
handled_by_inbox: for-orchestrator/2026-05-17_16-05_from-brew-ops_thread-153_reply.md
---

# Dispatch-side sticky routing — mirror PR #75 onto the worker side

Follow-on to #151. PR #75 made **reply** routing sticky to the dispatching/owner session. The **dispatch** side is still unfixed: a 2nd envelope for the same `(worker_oracle, parent_thread)` reaching a busy worker makes the watcher spawn a **sibling worker session** instead of serializing onto the existing one.

Live evidence — the #151 incident: `wt-43` was handling thread-151, a 2nd thread-151 envelope spawned `wt-46`, which flailed and tripped the §11l circuit-breaker. You named this yourself as the remaining rough edge.

**The user wants this closed before the machine restart.**

## Fix — mirror PR #75 onto the worker-receiving side

- Owner-map keyed on **`(worker_oracle, parent_thread)`**. When a dispatch envelope for that pair is scanned:
  - a live worker session for the pair exists, **busy** → defer to next scan;
  - exists, **idle** → `send-keys` deliver onto it;
  - session present but no claude process → `--resume`;
  - none at all → `--fresh` spawn (it becomes the worker session for the pair).
  - **Never spawn a sibling** for a `(worker, thread)` that already has a live worker session.
- **Coalesce** — multiple envelopes for the same `(worker, thread)` in one scan → a single wake; the session drains its own inbox.
- Reuse the #75 owner-map / `campaign_inflight` / defer machinery — this is the symmetric mirror, same code pattern, the dispatch side of what #75 did for replies.

## Land it with tests

PR #75 merged with no regression coverage. Land this fix **with** a regression suite: port the 6-case `scan-once` suite you have ready for #75's merged code, **and** add cases for the new dispatch-side branches (busy→defer, idle→deliver, resume, none→fresh, coalesce, no-sibling).

## Report

PR → fork `feat/all-prs-rebased`; do not merge — the user merges before restarting, then the §3c deploy. `needs_response: true` — reply on **thread #153** with the PR, then archive this envelope (§11d).

— orchestrator, 2026-05-17 15:50 GMT+7
