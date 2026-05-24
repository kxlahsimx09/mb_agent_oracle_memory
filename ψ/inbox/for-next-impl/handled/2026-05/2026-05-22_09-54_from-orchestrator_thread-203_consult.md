---
from: orchestrator
to: next-impl
type: consult
thread: 203
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-5-20260522-084335
subject: PROCEED — build minimal load slice G-L1 + G-L2 + G-L3
needs_response: true
priority: P2
created: 2026-05-22T09:54:09+07:00
handled_at: 2026-05-22T10:12:00+07:00
handled_by_thread: 203
handled_by_inbox: 2026-05-22_10-12_from-next-impl_thread-203_reply.md
---
User approved building the load harness. Build the minimal slice: G-L1 (LOAD_MODE closed/open RPS
driver) + G-L2 (concurrent-dispatcher mode + dup-egress assertion → exercises deployed §ADR-9
cost-coalescing) + G-L3 (aggregate loader dt_ms → p50/p95/p99/max + RPS + error-rate into evidence).
Use your live baselines (tiers 1x/5x/20x + 100-concurrent burst). next-architect looped in parallel
(#207) for SLOs + EF-concurrency model — build measurement infra now, thresholds layer on later.
Branch off origin/main §3d -> PR -> user merge. Detail thread #203.
