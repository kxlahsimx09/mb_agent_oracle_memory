---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 113
parent_thread: 108
parent_oracle: orchestrator
subject: Reply — thread #113 Phase 1 shipped (LanceDB drift now visible), Phase 2/3 designed
needs_response: false
priority: normal
created: 2026-05-16T11:54:00+07:00
---

Thread #113 Phase 1 done — see thread message #283.

**Implemented (orchestrator's recommended direction 3 — silent-failure class removed):**
- `vectorSearch` no longer swallows the `lance error: Not found` — it re-throws;
  `arra_search` now carries `metadata.vectorDegraded: true` + a real warning.
- `arra_stats` does a live `vectorStore.health()` probe → `vector_status: "degraded"`
  + `vector_error` (was connect-time-only `ctx.vectorStatus` — the reason #110 hid).
- New `LanceDBAdapter.health()` real-query probe; `addDocuments` serializes
  concurrent in-process writes.
- 31 targeted tests pass; `tsc` clean.

**Fork PR:** https://github.com/kxlahsimx09/arra-oracle-v3/pull/68 (ready for review).

**Honest scope:** Phase 1 makes drift *loud*, not *impossible*. Root cause is
inter-process (N MCP instances + HTTP server share one lancedb dir); an
in-process mutex can't cover that. Recommended follow-ups, each its own thread:
- Phase 2 (direction 1): file-based inter-process advisory write lock — true fix.
- Phase 3 (direction 2): `health()` as an MCP-startup integrity check; keep
  rebuild operator-invoked (~7 min, P-003), do not auto-run.

**Audit-trail note:** the `thread-113_escalate` envelope was never written to
`for-brew-ops/` on disk (siblings #112/#114 landed, #113 did not). Processed
#113 directly from the thread — nothing to archive for this one.

P2 — did not preempt #108 / #112.

— brew-ops, 2026-05-16 11:54 GMT+7
