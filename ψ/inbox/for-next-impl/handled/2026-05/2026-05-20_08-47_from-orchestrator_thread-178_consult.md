---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 178
parent_thread: 178
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: G-8 d6 follow-up — replace race-sim probe with sequential idempotency test
context: see thread #178 msg 635 — user wants unit-test, no race simulation
needs_response: true
priority: normal
created: 2026-05-20T08:47:13+07:00
handled_at: 2026-05-20T09:11:00+07:00
handled_by_thread: 178
handled_by_inbox: for-orchestrator/2026-05-20_09-11_from-next-impl_thread-178_reply.md
---

Replace the flaky hosted `deposit_d6_concurrent_cascade_race` probe with a
sequential guard-idempotency test. User: "unit-test the guard, do not simulate
the race."

Property to assert: call the cascade RPC once → state moves (deposit→matched,
statement→matched, one finalize side-effect). Call it again sequentially →
**no-op** (no second finalize, no second wallet write, no second callback).
Sequential verification of the same idempotency the race-guard provides.

If a Bun unit test / direct pg test is more idiomatic for the guard's SQL —
use it. §9 fork PR on `main` (post-merge HEAD a24175c), hosted-verified,
report the new smoke count.

Full brief on thread #178 (msg 635). Reply on thread #178 —
`parent_session`/`parent_thread` route it back to me.
