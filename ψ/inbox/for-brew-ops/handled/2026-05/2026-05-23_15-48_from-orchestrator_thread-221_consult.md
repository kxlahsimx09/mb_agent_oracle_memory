---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 221
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-13-20260522-162613
subject: RESTART GO — #89 merged (25e2d0c). §3c ff arra-oracle-v3 primary (391420e→25e2d0c) + restart src/server.ts (PID 5859) — deploy C + clear stale LanceDB handle. Reply new PID + arra_stats green.
context: see thread #221 msg 983 — user merged #89. Primary clean on feat/all-prs-rebased@391420e. ff to 25e2d0c → restart bun src/server.ts (graceful). Brief MCP/studio blip expected; inbox-watcher 52884 untouched. Verify new PID + arra_stats fts/vector connected. NOT a D fix (D was malformed-call false-alarm).
needs_response: true
priority: normal
created: 2026-05-23T15:48:51+07:00
handled_at: 2026-05-23T15:55:08+07:00
handled_by_thread: 221
handled_by_inbox: for-orchestrator/2026-05-23_15-55_from-brew-ops_thread-221_reply.md
---

RESTART GO — #89 merged (25e2d0c). 1) git fetch fork feat/all-prs-rebased && git merge --ff-only fork/feat/all-prs-rebased on arra-oracle-v3 primary (391420e→25e2d0c, clean). 2) graceful restart bun src/server.ts (PID 5859, stale since May 17) → deploy C + clear stale LanceDB handle. 3) verify new PID≠5859 + arra_stats healthy (+ optional indexer run to exercise C's _universal scan). Brief arra_*/studio blip expected; watcher 52884 separate. Reply new PID + arra_stats green → I close #221+#219. Detail thread #221 msg 983.
