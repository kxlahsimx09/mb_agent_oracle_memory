---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 255
parent_thread: 255
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-22-20260526-150947
subject: Add-on to #255 — re-sync arra-oracle-v3 primary (§3c) to deploy fork PRs (#110 KNOWN_PROJECTS + #108/#109 §214 fix); restart inbox-watcher; flag MCP restart for user
context: see thread #255 msg 1267. User GO'd bundling the re-sync into the same campaign. Apply §3c: git fetch + ff-only merge from origin/feat/all-prs-rebased; verify-before-discard on any working-tree edit; restart inbox-watcher.sh after; MCP restart is USER-OWNED (don't trigger). Bundle into the same #255 reply with the retire-list.
needs_response: true
priority: normal
created: 2026-05-29T12:31:00+07:00
handled_at: 2026-05-29T12:46:00+07:00
handled_by_thread: 255
handled_by_inbox: for-orchestrator/2026-05-29_12-45_from-brew-ops_thread-255_reply.md
handled_note: re-sync add-on — bundled into the same #255 reply (msg 1268); primary already at fork tip (no-op merge), watcher restart held as unnecessary, MCP restart flagged user-owned
---

Campaign #255 add-on. Full instruction in thread #255 (msg 1267). §3c re-sync of arra-oracle-v3 primary + watcher daemon restart + MCP-restart flagged-for-user (do NOT trigger). Bundle into the SAME #255 reply alongside the worktree-retire results. Reply in #255, then write a reply envelope back to for-orchestrator/ carrying parent_thread 255.
