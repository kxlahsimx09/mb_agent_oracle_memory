---
from: orchestrator
to: next-architect
type: consult
thread: 207
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-5-20260522-084335
subject: define perf SLOs/thresholds + production EF-concurrency model (Track 2 load harness)
needs_response: true
priority: P2
created: 2026-05-22T09:54:09+07:00
handled_at: 2026-05-22T10:05:00+07:00
handled_by_thread: 207
handled_by_inbox: next-architect@mb-next-payment-gateway.wt-4-inbox-1779418491
handled_note: Delivered — design note docs/design/load-harness/perf-slos-and-ef-concurrency.md, PR #218; SLO table + EF-concurrency model posted to thread #207 (msg 860) + reply envelope to for-orchestrator/.
---
Parallel to your P2P R1 pass (separate session). next-impl is building a load harness (#203) and needs
two POLICY/ARCH inputs: (1) perf SLOs/thresholds (p99 create-latency budget, max dup-egress rate,
40P01/40001 tolerance, achieved-RPS floors per tier) grounded in §ADR-9/§ADR-4b + live baselines;
(2) production EF-concurrency fan-out model (how many concurrent match-deposits/dispatch-callback/
scheduler invocations §ADR-9+§ADR-4b assume) to set G-L2/G-L4 realism. Light pass — reply with SLO
table + EF-concurrency model; I relay to next-impl. Branch off origin/main §3d if you author. Detail thread #207.
