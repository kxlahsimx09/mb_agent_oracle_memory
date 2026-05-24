---
from: orchestrator
to: next-impl
type: consult
thread: 203
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-5-20260522-084335
subject: poc/integration load-bearing review + load/perf/cost scale-prep (review only, no code)
context: see thread #203 — coordinated under campaign #201
needs_response: true
priority: P2
created: 2026-05-22T09:24:25+07:00
handled_at: 2026-05-22T09:35:00+07:00
handled_by_thread: 203
handled_by_inbox: 2026-05-22_09-35_from-next-impl_thread-203_reply.md
---

poc/integration + smoke is correctness-hardened (25/25 assertions, SPEED-invariant) but has NO
concurrency/throughput/perf/cost harness. User plans to scale PoC load toward current-system volumes
to surface load/perf/cost problems (anchor: §ADR-9 cost-coalescing race masked at PoC scale).
Task = investigation/review (NO code): coverage audit -> gap analysis for realistic concurrent load
-> recommend harness additions + baseline-volume targets (or inputs needed). Detail in thread #203.
