---
title: §D free-tier feasibility run RESULT — free/micro Supabase = transient-YES / sust
tags: [system-architect, repo:mb-next-payment-gateway, next, scale, load-harness, perf-slo, reliability, free-tier, decision, thread-216]
created: 2026-05-26
source: docs/design/load-harness/perf-slos-and-ef-concurrency.md §D.6 (PR #258); next-impl run PR #256; thread #216 msg 1085/1088
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# §D free-tier feasibility run RESULT — free/micro Supabase = transient-YES / sust

§D free-tier feasibility run RESULT — free/micro Supabase = transient-YES / sustained-NO for the prod-target deposit load; ceiling is shared-CPU/burst-credit, NOT connections (now MEASURED).

Context (thread #216, parent #201, 2026-05-26): the §D free-tier feasibility profile (PR #252 §D) was executed by next-impl → PR #256, on free/micro project swqosfqrpmrhnebhksgd (Seoul ap-northeast-2, live max_connections=60, 50k bank_statements working set). next-architect formalized the D.6 verdict → PR #258. All capacity/latency [FREE-TIER · SHARED-CPU · NOT-RATIFIABLE]; Seoul vantage (NOT comparable to #235 Singapore).

VERDICT — "ไหวไหม?" → transient YES, sustained NO:
- Free/micro handles the ~30 dep/s production target (20× = ~19× current peak) TRANSIENTLY: the 45s 20× tier (p99 954ms) AND the 5-min sustained-30 both held 0 errors on throughput.
- But the latency TAIL blows out once shared-CPU burst credits deplete: sustained-30 (5 min, 8999 req) = p50 612 / p95 3497 / p99 4707 ms (vs ~783/954 at the 45s tier). This is the sustained-minutes signal the 45s tiers structurally HID — a short tier rides burst credits and looks artificially clean. (This validated the new §D.2 sustained-minutes step.)
- Phase-B rampB-30 (held AFTER burst-credit exhaustion) shed 48.5% as 503 (1746/3599), p99 4281ms, xact_rollback≈1867 correlating with the 503s (shared-CPU statement starvation).
- Sustainable steady-state < 30 dep/s; degradation ceiling X ≈ 30 dep/s (single-sample lower bound; noisy-neighbour pushes lower).

HEADLINE — ceiling is CPU/burst-credit, NOT connections (the §D.0 prediction, now MEASURED): DB backends stayed 14–19/60 (≤32%) the ENTIRE run INCLUDING during the 48% shed; the pooler ~200 side was never approached (in-flight ≈30–150). The instance shed ~half its load with the connection caps two-thirds idle → binding constraint = shared CPU / burst-credit / RAM.

LOGIC-SLOs HELD on the 2nd hosted substrate (ratifiable regardless of compute → promotes §C.5 to proven-on-2-substrates): SLO-15 deposit-LRU spread=0 (130 concurrent uncapped → exact 10/bank×13), SLO-14 withdraw spread=1, 40P01=0, dup-credit=0, dup-egress=0, deposit→paid 40/40. No flip vs #235.

G-L7 (§D.4): match_deposits_cascade @50k = 114–315ms vs #235 ~38ms@40 — SHAPE only (disk-IO-bound). Precision caveat: the 50k backfill was status=unmatched/terminal and the cascade scans only `pending`, so this is a PASSIVE table-size/IO working-set cost, NOT a per-deposit candidate-scan over 50k LIVE candidates. A real candidate-scan-cost-vs-size curve needs `pending`+amount-overlapping rows (a separate pass; do not fold into the logic-SLO phase or it pollutes matching).

§C.7 sharpened: §D answered "is free/micro enough for sustained prod load?" → NO (burst-credit ceiling AT the target). It did NOT answer "what compute IS sufficient" — that still needs a dedicated Medium-compute run (add-on selected per-project, verify max_connections~120 live). New check the Medium run must add: confirm dedicated (non-shared) CPU sustains ≥30 dep/s WITHOUT a burst-credit latency tail (dedicated compute has no shared burst-credit budget to deplete — the §D tail blow-out should simply not appear).

TWO durable reusable gotchas:
1. dup-egress measurement: the lifecycle probe reported dup_egress=4, but callback_queue ground truth = 1 row/deposit ×40, 40/40 delivered, 0 dup-delivered → the 4 was an eager-dispatcher-race artifact in the probe's in-flight PROXY metric, not real duplicate egress. RULE: read dup-egress off the queue/delivery ground truth, never the probe's in-flight proxy count.
2. harness daily-cap exhaustion: the 13-bank fleet has 999/bank daily cap → 12,987 deposits/day total. A sustained run > ~7 min @30 dep/s exhausts the pool (this run hit exactly 12,987), starving the lifecycle probe. RULE: a longer/larger sustained run needs more banks / higher per-bank caps / a periodic surgical `UPDATE daily_deposit_count=0` — and NEVER `reset_runtime_state()` post-handover (it DELETEs bank_statements → wipes the G-L7 50k working set; brew-ops backfills AFTER its final reset for this reason).

Companion to [[the mislabel learning]] (2026-05-26_hosted-load-test-medium-compute-was-a-mislabel) and the free-tier-feasibility binding-constraint learning. Correctness is mechanism-bound (proven on 2 substrates); capacity is load-bound + shared-CPU-bound (non-reproducible, NOT ratifiable).

---
*Added via Oracle Learn*
