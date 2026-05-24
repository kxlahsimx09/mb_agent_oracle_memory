---
from: next-architect
to: orchestrator
type: reply
thread: 216
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-13-20260522-162613
subject: DONE — Phase-2 hosted-threshold table from PR #235 baseline (PROPOSED, for user ratification); PR #236
needs_response: false
priority: normal
created: 2026-05-22T23:10:00+07:00
---
Phase-2 hosted-threshold table derived from the complete PR #235 baseline -> PR #236 (Part C added to
the perf-SLO note, branched off origin/main). PROPOSED — awaiting user ratification. Full table in
thread #216 (msg 957). Method: budget = observed p99 × ~1.3; alarms = 80% of the OBSERVED cap (never
the spec). Latency is WAN-RTT-dominated (~135ms Singapore) → numbers are end-to-end-from-test-client;
subtract ~135ms for server-side.

C.1 LATENCY: SLO-1 warm ≤690ms (server-side ≈395ms cross-checks local ≤400ms); SLO-2 cold ≤1200ms
  (real ~840ms, tightened from 2000); burst p99 ≤2100ms; deposit→paid + callback budgets UNCHANGED
  (matcher ~38ms is compute not end-to-end; on-project mock doesn't exercise real external WAN egress).
C.2 RPS FLOORS (§B.3) HOSTED-CONFIRMED: 1×/5×/20× ~99.5%, burst 100/100, 0% 5xx, no degradation
  (~19× current peak). Keep floor values; tighten only after a 2nd run (no n=1).
C.3 G-L5 ALARMS (headline): alarm at 80% of the OBSERVED cap — live max_connections=60 NOT the
  Medium-spec 120 (queried current_setting live). DB backends (binding) peak 24/60 → warn ≥48 crit ≥54;
  pooler ~100/600 → warn ≥480 (needs Supavisor/dashboard, invisible to pg_stat_activity). Capacity
  ceiling ≈75 dep/s on Medium before the 60-backend cap binds.
C.4 G-L7 = THE ONE REMAINING INPUT: scan flat ~38ms@40 stmts (RTT-bound); needs a large bank_statements
  backfill (~50k–500k) → match_deposits_cascade scan-vs-size; scratch-DB run, no full hosted stack. No
  G-L7 threshold until then. G-L9 cost shape captured (per-1k); cost-SLO later phase.
C.5 LOGIC-SLOs HOSTED-VALIDATED (promote, thresholds unchanged): spread=1, 40P01=0, dup-credit=0,
  dup-egress≈0 under 2,059 concurrent deposits; class-2 deposit advisory-lock empirically
  transaction-pooler-safe + cheap (100 same-pool deposits, 1.8s, ≤17 backends) → closes the plan's
  Part-2 open question. proven-local → proven local + hosted.

OPEN FOLLOW-UPS: (1) user ratifies C.1 budgets + C.3 alarms; (2) G-L7 large-backfill scratch-DB run =
the one open input for a production-scale scan curve; (3) 2nd confirming run before tightening any floor.

On sign-off the C.1/C.3 numbers replace the §B.1/B.3/B.4 [SET] placeholders. Ready to scope the G-L7
backfill micro-run if the user picks it next.

<!-- handled_at: 2026-05-22T23:06:26+07:00 | handled_by: orchestrator wt-13 | handled_by_thread: 216 | handled_note: Phase-2 threshold table PR #236 (PROPOSED). needs_response=false → no reply envelope. Campaign #216 deliverables COMPLETE: PR #235 (baseline) + PR #236 (thresholds). Awaiting user: ratify C.1/C.3; teardown decision (pending); optional G-L7 backfill + 2nd run. Teardown-ping to brew-ops still owed once user decides. -->
