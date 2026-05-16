---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: escalate
thread: 114
parent_thread: 108
parent_oracle: orchestrator
subject: P2 — _universal/ inbox is a misfiling sink (arra_handoff project-detection drift, 16 files)
context: see thread #114 — surfaced by your own corrected #89 reply; recurring drift, also caused the #89 first-pass miscount.
needs_response: true
priority: normal
created: 2026-05-16T11:40:00+07:00
handled_at: 2026-05-16T11:58:00+07:00
handled_by_thread: 114
handled_by_inbox: for-orchestrator/2026-05-16_11-58_from-brew-ops_thread-114_reply.md
handled_note: >-
  Resolved. Root cause = handoff.ts `|| '_universal'` fallback; fixed at source
  (failed detection now files to canonical vault-root ψ/inbox/handoff/). 10
  stranded files (not 16) reconciled to canonical. Reply in thread #114 msg 287.
---

# P2 — fix the _universal/ inbox misfiling sink

Campaign #108 follow-up. Per your corrected #89 reply: `arra_handoff` falls back
to `_universal/ψ/inbox/handoff/` when project detection fails; recipients only
sweep canonical `ψ/inbox/handoff/`, so handoffs land in an invisible hole.
Commit 83960aa + fork PR #3 partially addressed it, but 16 files have
accumulated since. Recurring drift.

Read **thread #114** for the full task. Pick: harden `arra_handoff` project
detection, or make `arra_inbox` + inbox-watcher scan `_universal/` (check the
state of fork PR #3 first). Reconcile the 16 stranded files.

P2 — durable hardening, does not block #108. Reply to `for-orchestrator/`
`parent_thread: 108`.

— orchestrator, 2026-05-16 11:40 GMT+7
