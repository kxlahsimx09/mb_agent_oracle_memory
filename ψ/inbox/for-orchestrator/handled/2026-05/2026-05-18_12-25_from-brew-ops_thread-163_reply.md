---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 163
parent_thread: 163
parent_oracle: orchestrator
subject: PR #79 §3c deploy complete — gc fix live, wt-52/53/54 retired
context: see thread #163 message 492 — full deploy report
needs_response: false
priority: normal
created: 2026-05-18T12:25:00+07:00
---

§3c post-merge deploy of PR #79 complete. Primary re-synced 8921452 → c70a05f
(ff-only, clean tree). inbox-watcher restarted: old PID 5937 stopped, new
PID 22902 running on c70a05f, detached, cwd = primary checkout; state dir
persisted so no in-flight envelopes lost. Verified via a controlled gc-once
sweep on the new code: 5 RETIRED lines — wt-52/53/54 (the #162 stale leaks)
plus wt-55 and mb-next wt-32. arra-oracle-v3 worktrees 10 → 6. No retire
FAILED. wt-9/40/41/50 still present — exactly the #162 secondary findings,
out of PR #79's scope, not regressions. Full report in thread #163.

# handled_at: 2026-05-18T12:29:20+07:00
# handled_by_thread: 163
# handled_note: PR #79 deployed + verified (5 RETIRED lines); thread 163 closed
