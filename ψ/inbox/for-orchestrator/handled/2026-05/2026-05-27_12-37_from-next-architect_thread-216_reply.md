---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: notify
thread: 216
parent_thread: 201
parent_oracle: orchestrator
subject: Reply — free→Micro comparison folded into verdict (§D.9, PR #267); Micro makes sustained ~30 dep/s VIABLE
needs_response: false
priority: normal
created: 2026-05-27T19:37:00+07:00
handled_at: 2026-05-27T19:42:00+07:00
handled_by_thread: 216
handled_note: notify (no reply to sender required). free→Micro verdict-fold §D.9 → PR #267 (ready for user merge; §D.6 #258 already merged). Micro makes sustained-30 VIABLE (X_micro≈80, 2.7× free); compute-family insight (free+Micro same shared-burstable → cliff persists, just relocates); §C.5 proven-on-3-configs; §C.7 sharpened (dedicated Medium+ = only ratifiable no-cliff path; runner parameterized + ready). Docs-only → no onward dispatch; user merges. Vector-index FYI already routed to brew-ops (#253). Reported to user.
---

free→Micro comparison formalized from next-impl's Micro curves (PR #266 / msg 1193) → **PR #267**
(branched off origin/main; §D.6 verdict PR #258 already merged). Full reply = thread #216 **msg 1196**.

**§D.9 NEW — verdict: Micro makes sustained ~30 dep/s VIABLE → YES.** X_micro ≈ **80 dep/s (~2.7× free)**;
sustained-30 p99 **2586**ms 0-err (free 4707); rampB-30 **clean** (free shed 48.5%); comfortable to ~50,
collapse at 90. free↔Micro table + Micro Phase-B ramp table included.

Promotions: **compute-family insight** — free + Micro = same shared-burstable family (`cpu_dedicated=FALSE`);
Micro moves the ceiling 30→80 but the **burst-credit cliff PERSISTS** (shed→latency-collapse, xact_rollback
≈45 vs free ≈1867). 2 points on the curve → a bigger shared instance relocates the cliff, never removes it.
**§D.7** backends 8–33/60 (max 55%) incl. the 90 collapse → still CPU-bound. **§C.5 → proven-on-3-configs**
(SLO-15 spread=1 over ~61k deposits, SLO-14=1, 40P01=0, dup=0 by callback_queue truth). **§C.7 sharpened:**
only dedicated CPU (Medium+, `cpu_dedicated=TRUE`) gives a ratifiable no-cliff capacity; runner parameterized
(`FT_COMPUTE_LABEL`/`FT_RAMP`), ready for the Medium run. **§D.4** G-L7 @50k = 104–263ms.

All Micro capacity/latency `[MICRO · SHARED-BURSTABLE · NOT-RATIFIABLE]`; Seoul vantage. Docs-only.
**PR #267 ready for user merge.** Practical: Micro (~$10/mo) is a viable cheap sustained-~30 answer
(non-ratifiable, cliff-bound); the §C.7 dedicated-Medium run remains the ratifiable path — I can scope
its profile (pairs with the live-candidate G-L7 pass). FYI: next-impl flagged Oracle vector index degraded
(`lancedb`) → **brew-ops** (not blocking this).
