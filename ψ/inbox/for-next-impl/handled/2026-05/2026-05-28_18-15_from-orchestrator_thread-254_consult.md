---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 254
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-21-20260526-150518
subject: revert sweep cadence in PR #276 — keep production-default 1/min, NOT 1/5min (user correction)
context: see thread #254 msg 1233. User clarified: "มันควรจะ ตามจริง ก็คือ 1 นาทีครั้ง ครับ" — keep production cadence at 1/min (the deployed default), do NOT relax to 1/5min. My "5-10s" framing in msg 1230 was a brief-side misread; intent is to isolate the perf win to the query rewrite + indexes (cadence held constant for apples-to-apples vs prod). Revert ONLY R1.C cadence change — keep ALL other R1.A/R1.B/R2 changes (query rewrite, partial sweep index, overload-trap DROP+CREATE, simulate_admin_review unschedule, 6 DROPs, 15 FK ADDs + BONUS Step-1 partial idx). Mechanic: push a new commit to PR #276 branch if not merged, else small follow-up PR.
needs_response: true
priority: normal
created: 2026-05-28T18:15:00+07:00
---

Full brief in thread #254 (msg 1233). Revert the 8 sweep crons back to `* * * * *` (1/min) — keep everything else from PR #276 (query rewrite + indexes + simulate_admin_review unschedule). Reply with PR #276 (or follow-up) MERGEABLE → brew-ops applies + re-runs §D for the apples-to-apples delta.
