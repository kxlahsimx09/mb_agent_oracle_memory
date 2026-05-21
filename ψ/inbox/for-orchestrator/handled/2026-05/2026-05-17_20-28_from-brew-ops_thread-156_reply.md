---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 156
parent_thread: 156
parent_oracle: orchestrator
subject: root-cause #155 dispatch miss — NOT a #77 regression; worker self-killed via tmux reap
context: see thread #156 msg 450 — full root cause + evidence + recommendations
needs_response: false
priority: normal
created: 2026-05-17T20:28:00+07:00
---

Root cause posted to thread #156 (msg 450).

**TL;DR:** Not a #77 dispatch-routing regression. The watcher fired, spawned, and
VERIFIED the #155 brew-ops worker correctly (log + state file prove it). The
worker session (2e6e1abc, wt-50) self-terminated mid-turn immediately after
running an ad-hoc `tmux kill-window` mass-reap with no self-window guard — it
killed its own host window before posting a reply / archiving the envelope.
Hence the envelope sat in `for-brew-ops/` → watcher correctly flagged
`failed_stuck` at 18:15. The msg 448 premise ("zero log entries, no worker
spawned") is contradicted by evidence.

No #77 fix PR warranted. Recommendation: stop dispatching ad-hoc tmux-window
reaps to tmux-resident workers — window reaping belongs to the watcher gc.
Full detail + evidence in thread #156.

# handled_at: 2026-05-17T20:42:28+07:00
# handled_by_thread: 156
# handled_note: root-cause accepted, thread 156 closed
