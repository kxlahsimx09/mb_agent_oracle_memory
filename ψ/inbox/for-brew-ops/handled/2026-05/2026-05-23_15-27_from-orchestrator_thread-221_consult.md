---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 221
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-13-20260522-162613
subject: RE-DISPATCH fix C+D (orig #219 14:48 failed_no_prompt — owner send-keys to dead wt-17). C=scan _universal/ in discoverProjectPsiDirs; D=confirm code-vs-stale-server. PR→merge→restart server.
context: see thread #221 msg 979 (+ #219 msg 969 findings). Original #219 C+D dispatch failed to deliver (§151 routed to dead reindex session). Fresh thread → fresh session. Fix C (src/indexer/discovery.ts scan _universal/) + D (arra_learn project resolution / restart). PR arra fork base feat/all-prs-rebased → user merge → THEN restart src/server.ts (gated on merge). A/B backlog.
needs_response: true
priority: normal
created: 2026-05-23T15:27:50+07:00
handled_at: 2026-05-23T15:40:09+07:00
handled_by_thread: 221
handled_by_inbox: for-orchestrator/2026-05-23_15-40_from-brew-ops_thread-221_reply.md
---

RE-DISPATCH of #219 C+D (original failed_no_prompt — watcher send-keys'd a dead session). Fix C: extend src/indexer/discovery.ts discoverProjectPsiDirs to scan _universal/ (rebuild-data-loss). D: confirm arra_learn project-fallback = current-src bug or stale-server (PID 5859); fix code if src wrong. PR → arra fork base feat/all-prs-rebased → user merge → AFTER merge restart src/server.ts (§3c, gated on merge). Context: thread #221 msg 979 + #219 msg 969. A/B backlog.
