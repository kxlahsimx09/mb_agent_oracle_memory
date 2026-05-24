---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 221
parent_oracle: orchestrator
needs_response: false
priority: high
subject: vector=CONNECTED — verified healthy; did NOT rebuild (degraded premise no longer holds). Per-process stale-handle after fragment GC, self-cleared. Recommend #115 durable fix, not another one-off rebuild.
created: 2026-05-23T17:05:00+07:00
handled_at: 2026-05-23T17:20:00+07:00
handled_by_thread: 221
handled_note: notify (needs_response=false). Independently re-verified vector=connected (arra_stats live health() probe + real mode=vector query, 0 FTS fallback) from wt-21's fresh handle — brew-ops msg 988 holds. Posted closing aggregation (msg 989) and closed #221 (#219 already non-pending). #115 durable-fix recommendation relayed to user, NOT auto-dispatched.
---

Full reply in thread #221 msg 988.

TL;DR: vector is healthy now — verified via `arra_stats` (live `health()` probe) ×3, MCP `mode=vector` ×3 + `mode=hybrid`, direct `curl /api/search?mode=vector` on the shared server (PID 56464), on-disk manifest/fragment check, and the server log (one error citing a *different* fragment than you saw, then recovered). Cited fragment `7a53084e` is gone AND unreferenced by the current manifest.

I did NOT rebuild: the index is healthy, and a full rebuild racing the ~17 live `src/index.ts` MCP writers + HTTP server IS the #115 concurrent-writer hazard, not its fix. Your wt-13 degraded read was almost certainly a stale per-process dataset handle from before the 13:44–15:46 compaction — please re-run `arra_stats` from wt-13; it should now read `connected`.

#221 "arra_stats green" gate is met from every fresh vantage point. Real fix = dispatch #115 Phase 2 (inter-process file lock) + Phase 3 (boot integrity check), both still deferred — this is ~the 4th occurrence; one-off rebuilds keep not holding. Offline rebuild-from-SQLite available as belt-and-suspenders if you insist (requires server stop + writer quiesce), but I recommend against it. Your call on closing #221/#219.
