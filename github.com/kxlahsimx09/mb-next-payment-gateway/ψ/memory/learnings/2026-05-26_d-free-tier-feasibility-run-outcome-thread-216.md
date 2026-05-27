---
title: §D free-tier feasibility run outcome (thread #216) — free/micro does NOT sustain
tags: [implementation-architect, repo:mb-next-payment-gateway, next, poc, load-harness, perf-slo, free-tier, shared-cpu, scale, decision, thread-216, parent-201]
created: 2026-05-26
source: poc/integration/evidence/freetier-216/SUMMARY.md@6b7466b; thread #216 msg 1085; PR #256
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# §D free-tier feasibility run outcome (thread #216) — free/micro does NOT sustain

§D free-tier feasibility run outcome (thread #216) — free/micro does NOT sustain the ~30 dep/s production target.

Ran PR #252 §D.2 on a free/micro Supabase project (`swqosfqrpmrhnebhksgd`, Seoul `ap-northeast-2`, live `max_connections`=60, 50k unmatched bank_statements working set). All capacity/latency `[FREE-TIER · SHARED-CPU · NOT-RATIFIABLE]`; Seoul vantage — NOT comparable to #235's Singapore.

**Verdict — "ไหวไหม?" → marginal/transient YES, sustained NO.** Free/micro handles ~30 dep/s transiently and absorbs one-shot spikes, but **degrades AT the production target once shared-CPU burst credits deplete.** Sustainable steady-state < 30 dep/s.

Evidence:
- Phase A 20× (45s, ~30 dep/s): clean — 0 errors, create p99 954ms, backends 15/60. A 5-min sustained-30 (8999 req) also held 0 errors on throughput BUT the latency tail blew out (p95 783→3497ms, p99 954→4707ms) as burst credits depleted — the 45s tiers hid this (the new §D.2 signal: sustained-minutes, not 45s spikes).
- Phase B step-30 (post-credit-exhaustion): **48.5% shed as HTTP 503** (1746/3599); xact_rollback≈1867 correlates (shared-CPU statement starvation). → degradation ceiling X ≈ 30 dep/s, single-sample lower bound (noisy neighbour pushes lower).
- **§D.7 corroboration:** DB backends stayed 14–19/60 (≤32%) the ENTIRE run, incl. during the 48% shed → the ceiling is **shared CPU / burst-credit, NOT connections** (and not the ~200 pooler side). Exactly the §D.0 prediction — connection-knee never arrives on shared CPU.
- **Logic-SLOs HOLD (ratifiable regardless of compute, §D.5):** SLO-15 deposit-LRU spread=0 (130 concurrent uncapped → 10/bank ×13), SLO-14 withdraw spread=1 (60 payouts [5×8,4×5]), 40P01=0, dup-credit=0, dup-egress=0. Re-confirms PR #236 §C.5 on a second substrate — no FLIP.
- §D.4 G-L7 cascade scan @50k = 114–315ms (vs #235 ~38ms@40) — shape, not a threshold.

Deliverables: PR #256 (runner `poc/integration/src/load/run-freetier-feasibility.sh` + evidence `poc/integration/evidence/freetier-216/`). next-architect writes the formal D.6 verdict from these curves. Does NOT supersede §C.7 (ratifiable infra still needs a genuine per-project Medium add-on + live max_connections verify). Companion: [[2026-05-26_hosted-load-test-medium-compute-was-a-mislabel]], [[2026-05-26_free-tier-load-test-feasibility-the-binding-const]], [[feedback_load_test_volume_vs_capacity]].

---
*Added via Oracle Learn*
