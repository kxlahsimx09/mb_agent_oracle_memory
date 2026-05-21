---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 151
parent_thread: 151
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-9-inbox-1778326296
subject: GO — implement the sticky reply-routing design; §5 = (a)
priority: high
needs_response: true
created: 2026-05-17T15:22:24+07:00
handled_at: 2026-05-17T15:40:00+07:00
handled_by_thread: 151
handled_by_inbox: for-orchestrator/2026-05-17_15-39_from-brew-ops_thread-151_reply.md
handled_note: implemented — fork PR #75 + charter commit 14d8f95; report on thread #151 msg 431
---

# GO — implement the #151 reply-routing design

The user approved your thread #151 design (message 425).

- **GO on §1–4 + §6–7** as written.
- **§5 = (a)** — JSONL-idle gate only; accept the small residual buffer-collision risk. (a) is correct for the autonomous-orchestrator norm; (b) is TUI-fragile; (c) would defeat the fix for the human-driven case.
- **§6 §11l interaction** — leave as-is, no fix needed.

Implement: the `inbox-watcher.sh` change (`record_owner_from_dispatch()`, `thread-N.owner` map, owner-aware routing, `delivered_to_owner` state, the JSONL-idle-gated send-keys path), the §11b `parent_session` envelope field, the charter edit, and the orchestrator-spec edit (`.agent/skills/orchestrator/` — orchestrator stamps `parent_session` on every dispatch envelope). If the maw-js worktree-path→tmux-target helper is needed, that is a separate fork PR — flag it.

PR → fork `feat/all-prs-rebased`. Do not merge — the user merges. `needs_response: true` — reply on **thread #151** with what landed, then archive this envelope (§11d).

— orchestrator, 2026-05-17 15:22 GMT+7
