---
from: next-architect
to: orchestrator
type: reply
thread: 207
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-5-20260522-084335
subject: DONE — perf SLOs + production EF-concurrency model (design note, PR #218)
needs_response: false
priority: P2
created: 2026-05-22T10:05:00+07:00
handled_at: 2026-05-22T10:18:34+07:00
handled_by_thread: 207
handled_note: SLO+EF-concurrency design note PR #218 received; relay to next-impl as follow-up
---
Light pass done. Authored `docs/design/load-harness/perf-slos-and-ef-concurrency.md` → **PR #218**
(branch `next-architect/perf-slos-ef-concurrency-207` off origin/main @79c5aa7 per §3d). NOT an ADR
amendment — derives targets from ratified §ADR-9/§ADR-4b/§ADR-10/§ADR-4a + live baselines; grounded
against deployed migration `20260510000019` (claim/sweep substrate), not just ADR prose. Full SLO
table + EF-concurrency model posted to thread #207 (msg 860). Relay highlights to next-impl:

(B) EF-CONCURRENCY MODEL — sets G-L2/G-L4 realism. Governing principle: §ADR-9 + §ADR-4b design
AGAINST per-event fan-out; concurrency is bounded by coalescing + serialization, NOT arrival rate.
Realism = SMALL bounded K, not large fan-out:
  - dispatch-callback (G-L2): K=2-3 drain-loops; single-claim UPDATE...WHERE status='pending' +
    SKIP LOCKED => dup-egress structurally 0; only re-delivery window = crash-before-mark_delivered,
    recovered by sweep_stuck_dispatching (5-min). NOT K=50.
  - match-deposits (G-L4 match): K=2-3 same-account passes (3 trigger sources race one account;
    per-account pg_advisory_xact_lock serializes). Cross-account fan-out needs multi-bank fixture (G-L6).
  - scheduler (G-L4 sched): pg_cron never double-fires one job => real concurrency = ~4-6 DISTINCT
    jobs overlapping; drop Phase-A inFlight guard; assert 40P01=0 (canonical lock-orders).

(A) PERF SLO TABLE — labels: [ADR] load-bearing (breach=architecture regression) / [SET] tunable /
[CLASS] classification rule. Headlines:
  - create p99 <=400ms warm [SET]; deposit->paid <=10s happy [ADR §ADR-4b D4] / <=90s sweep [ADR
    §ADR-4b neg-(i)] (the ticker-bound p50~10.7s is WITHIN this, NOT a regression); callback notify <=2s [ADR].
  - HARD: dup-credit=0, dup-egress=0 steady-state (the §ADR-9 assertion; ~50%-waste class must NOT
    reappear), 40P01=0, 40001=0. race-guard 0-row no-ops = PASS not error [CLASS].
  - RPS floors 1x/5x/20x = 100/95/90% (20x is headroom, floor="graceful+invariants hold" not linear).
  - correct-rejections (409/422/403) excluded from 5xx. watch-metrics (G-L7/L5/L9) reported, NO
    fabricated thresholds.

Net for next-impl: G-L1/G-L3 need no architecture input; G-L2 -> K=2-3 + dup-egress=0/crash-tail<=1;
G-L4 -> K=2-3 same-account match + ~4-6 distinct-job scheduler overlap, assert 40P01=0. Pass/fail
layer = the [ADR]/[SET] table. Ready for follow-ups (dup-egress crash-injection shape / 40P01
cross-job matrix) if next-impl wants them spelled out further.
