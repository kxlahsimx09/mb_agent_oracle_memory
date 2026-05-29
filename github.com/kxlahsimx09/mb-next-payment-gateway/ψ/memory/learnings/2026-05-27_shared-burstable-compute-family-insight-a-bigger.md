---
title: Shared-burstable compute-family insight — a bigger shared-burstable Supabase ins
tags: [system-architect, repo:mb-next-payment-gateway, next, scale, load-harness, perf-slo, reliability, supabase, shared-burstable, burst-credit, compute-sizing, decision, thread-216]
created: 2026-05-27
source: docs/design/load-harness/perf-slos-and-ef-concurrency.md §D.9 (PR #267); next-impl run PR #266; thread #216 msg 1193/1196
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Shared-burstable compute-family insight — a bigger shared-burstable Supabase ins

Shared-burstable compute-family insight — a bigger shared-burstable Supabase instance MOVES the burst-credit cliff but never REMOVES it; only dedicated CPU does.

Context (thread #216, parent #201, 2026-05-27): after the §D free-tier feasibility run (free/micro degrades AT ~30 dep/s on burst-credit depletion — see learning `2026-05-26_d-free-tier-feasibility-run-result-freemicro-s`), a Micro comparative run (next-impl PR #266) re-ran the SAME project `swqosfqrpmrhnebhksgd` upgraded to `ci_micro` (`cpu_dedicated=FALSE` → 2-vCPU shared-burstable, 1GB RAM, shared_buffers 256MB, max_connections=60 UNCHANGED — the upgrade is RAM+CPU, not connection caps, ~$10/mo). next-architect folded it into the design note → §D.9 / PR #267. All capacity/latency [MICRO · SHARED-BURSTABLE · NOT-RATIFIABLE]; Seoul vantage (free↔Micro directly comparable, same project).

RESULT — Micro makes sustained ~30 dep/s (the production target) VIABLE:
- sustained-30 (5 min) p99 2586ms 0-err (vs free's blow-out to 4707ms); rampB-30 0-err CLEAN (vs free's 48.5% shed as 503).
- X_micro ≈ 80 dep/s (0-error throughput holds to ~77 rps; collapse at 90 → p99 22.8s, achieved 76<90) — ~2.7× free's ~30. Comfortable latency (p99 ≲4s) extends to ~50 dep/s.
- Phase-B ramp (achieved·5xx·p99·backends): 30:29.85·0·2678·27 / 40:39.83·0.02%·2825·33 / 50:49.76·0·3847·31 / 60:59.29·0·5182·33 / 70:67.89·0·5460·27 / 80:77.09·0.01%·6829·31 (last clean) / 90:76.39·0·22844·33 (COLLAPSE).

THE INSIGHT (the headline that grounds §C.7):
- free and Micro are the SAME shared-burstable family (`cpu_dedicated=FALSE` on both). Micro buys 2× RAM + a higher baseline CPU allocation + a larger burst budget → the sustainable ceiling moves 30 → 80 dep/s (~2.7×).
- BUT the burst-credit cliff does NOT disappear — it moves UP and CHANGES SHAPE: free degrades by 503-shedding (statement starvation, xact_rollback storm ≈1867); Micro degrades by latency-COLLAPSE/queue (xact_rollback ≈45, near-zero — the queue grows and achieved RPS drops below target). More RAM/CPU shifts the failure from "shed" to "queue-and-slow."
- With 2 points now on the shared-burstable curve, the conclusion is firm: a bigger SHARED-BURSTABLE instance only RELOCATES the cliff, it never REMOVES it — a finite CPU burst budget is intrinsic to the family.
- → Removing the cliff requires LEAVING the family: a dedicated-CPU instance (Medium+, `cpu_dedicated=TRUE`) has no shared burst budget to deplete. That is the ONLY configuration that can yield a RATIFIABLE, no-cliff sustained-capacity number. Concrete check the dedicated-Medium §C.7 run must add: confirm dedicated CPU sustains ≥30 dep/s WITHOUT a burst-credit latency tail (the §D/§D.9 tail blow-out should simply not appear).

§D.7 corroboration: DB backends stayed 8–33/60 (max 55%) the entire Micro run INCLUDING the 90-dep/s collapse — never near the 60 cap; pooler ~200 never approached → still CPU/burst-credit bound, not connections (same mechanism as free, larger budget).

§D.5 logic-SLOs HELD on a 3rd substrate-config (SLO-15 spread=1 over ~61,460 deposits, SLO-14 spread=1, 40P01=0, dup-credit=0, dup-egress=0 by callback_queue ground truth — probe's dup_egress=1 = same eager-dispatch proxy artifact as free) — no flip → mechanism-bound correctness now proven on 3 hosted configs (free-equiv #235 + free/micro #256 + Micro #266), this time through a latency-collapse (not shed) degradation episode.

Practical: Micro (~$10/mo) is a viable cheap option for sustained ~30 dep/s (headroom to ~50 comfortable / ~80 throughput) — but non-ratifiable (shared/noisy-neighbour) and cliff-bound. Durable: when sizing shared-burstable compute, expect the burst-credit cliff at SOME sustained RPS — a bigger shared instance buys headroom, not cliff-removal. Read the cap utilization (backends vs max_connections) to confirm CPU-not-conns bound. Companion to [[2026-05-26_d-free-tier-feasibility-run-result-freemicro-s]] and the mislabel learning [[2026-05-26_hosted-load-test-medium-compute-was-a-mislabel]]. Runner now parameterized (FT_COMPUTE_LABEL/FT_RAMP), reusable for the dedicated-Medium run.

---
*Added via Oracle Learn*
