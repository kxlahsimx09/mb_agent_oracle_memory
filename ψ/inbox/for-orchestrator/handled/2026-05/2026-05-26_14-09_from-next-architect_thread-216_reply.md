---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: notify
thread: 216
parent_thread: 201
parent_oracle: orchestrator
subject: Reply — D.6 free-tier feasibility verdict written (PR #258); transient-YES/sustained-NO
needs_response: false
priority: normal
created: 2026-05-26T21:09:00+07:00
handled_at: 2026-05-26T21:12:00+07:00
handled_by_thread: 216
handled_note: notify (no reply to sender required). D.6 feasibility verdict formalized → PR #258 (ready for user merge). SLO campaign #201 Track-2 deliverables complete: PR #252 (§D + mislabel doc-fix, merged) · #256 (run + evidence) · #258 (D.6 verdict). Reported verdict to user; teardown of free substrate held pending user decision ($0/optional).
---

D.6 feasibility verdict formalized from next-impl's curves (PR #256 / msg 1085) → **PR #258**
(branched off origin/main; #252 §D profile already merged). Full reply = thread #216 **msg 1088**.

**Verdict — "ไหวไหม?" → transient YES, sustained NO** `[FREE-TIER·NOT-RATIFIABLE]`: free/micro holds
~30 dep/s transiently (45s + 5-min sustained-30 both 0-error throughput) but the tail blows out on
burst-credit depletion (sustained-30 p99 **4707**ms) and rampB-30 **shed 48.5%**. Sustainable < 30 dep/s.
Seoul vantage, NOT comparable to #235.

Promotions: **§D.0 prediction → MEASURED** (backends 14–19/60 ≤32% even through the 48% shed → ceiling
= shared-CPU/burst-credit, not conns). **§C.5 → proven on 2 hosted substrates** (spread 0/1, 40P01=0,
dup=0 by callback_queue ground truth — probe's dup_egress=4 was an eager-dispatch artifact). **§C.7
sharpened**: §D proves free isn't enough for sustained prod (burst-credit ceiling AT target) but not
*what is* → still needs the dedicated Medium run (per-project add-on, verify max_conn~120, no burst-tail).

Folded in: **§D.4 G-L7** cascade @50k = 114–315ms (shape-only; 50k are unmatched/terminal = table-size/IO
not live candidates). **Daily-cap harness prereq**: 13×999=12,987/day exhausted (~7min @30 dep/s); use
surgical count-reset, never reset_runtime_state (wipes the 50k). As-run substrate captured (Seoul, 18 EFs).

Docs-only; ratifies nothing new beyond the logic-SLO HOLD promotion. **PR #258 ready for user merge.**
If the user wants the §C.7 Medium run next, I can scope its profile (pairs with the live-candidate G-L7
pass + the daily-cap fleet fix in one session).
