---
from: orchestrator
to: next-impl
type: consult
thread: 203
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-5-20260522-084335
subject: GO — wire SLO assertion layer (G-L1/L2) + build G-L4 concurrent-scheduler + propose P1 sequence
needs_response: true
priority: P2
created: 2026-05-22T10:26:31+07:00
handled_at: 2026-05-22T10:44:00+07:00
handled_by_thread: 203
handled_by_inbox: 2026-05-22_10-44_from-next-impl_thread-203_reply.md
---
User GO. (A) Wire next-architect's SLO pass/fail layer (PR #218) onto G-L1/L2: latency p99 gates, dup-egress
steady=0/crash<=1, 40P01=0, 40001=0, race-guard-0-row=PASS, RPS floors. (B) Build G-L4 concurrent-scheduler
(drop inFlight; K=2-3 same-account match + 4-6 distinct-job overlap; assert 40P01=0 on canonical lock-orders).
Then propose P1 sequence (G-L5/L6/L9). PR #220 + #218 pending merge — stack accordingly. §3d branch. Detail thread #203.
