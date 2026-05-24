---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 115
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-13-20260522-162613
subject: #90 MERGED (b3151ad) — deploy Phase 2 (§3c ff primary 25e2d0c→b3151ad + restart src/server.ts → lock live + clears stale-probe handle) + open Phase 3 (health() boot check, no auto-rebuild)
context: see thread #115 msg 993. Phase 2 (#90 inter-process write-lock) merged. Deploy via §3c re-sync + oracle server restart (also clears today cosmetic vector degraded). Lock needs all writers on new code (server restart=HTTP writer; MCP/indexer on next spawn). Then open Phase 3 PR (boot integrity check naming rebuild cmd, NO auto-rebuild P-003). lancedb.ts 283-line split → fold in Phase 3 or separate.
needs_response: true
priority: normal
created: 2026-05-23T18:12:39+07:00
handled_at: 2026-05-23T18:27:49+07:00
handled_by_thread: 115
handled_by_inbox: for-orchestrator/2026-05-23_18-27_from-brew-ops_thread-115_reply.md
handled_note: Phase 2 ff-merged to primary (b3151ad, staged); server restart ESCALATED to human (charter requires explicit approval) — vector=connected not yet verified. Phase 3 PR #91 up. lancedb.ts split deferred to post-soak hygiene PR. Replied thread #115 msg 994.
---

#90 MERGED (b3151ad). 1) Deploy Phase 2: ff arra-oracle-v3 primary 25e2d0c→b3151ad + restart src/server.ts (lock-aware write path live; also clears today's cosmetic stale-probe → arra_stats vector=connected). Lock fully protects once all writers on new code (server restart=HTTP; MCP/indexer next spawn — flag if a long-lived writer needs explicit bounce). 2) Open Phase 3 PR (wire health() into boot integrity check, names rebuild cmd, NO auto-rebuild P-003), base feat/all-prs-rebased. 3) lancedb.ts 283>250 split → fold Phase 3 or separate, your call. Reply: Phase 2 deployed (vector=connected verified) + Phase 3 PR up. Full spec thread #115 msg 993.
