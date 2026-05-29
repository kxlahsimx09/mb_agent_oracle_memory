---
title: §D Micro comparative run outcome (thread #216) — Micro makes sustained ~30 dep/s
tags: [implementation-architect, repo:mb-next-payment-gateway, next, poc, load-harness, perf-slo, micro, shared-burstable, scale, decision, thread-216, parent-201]
created: 2026-05-27
source: poc/integration/evidence/micro-216/SUMMARY.md@4328347; thread #216 msg 1193; PR #266
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# §D Micro comparative run outcome (thread #216) — Micro makes sustained ~30 dep/s

§D Micro comparative run outcome (thread #216) — Micro makes sustained ~30 dep/s viable; burst-credit ceiling moves up ~2.7× but PERSISTS.

Re-ran the §D.2 profile on the SAME project (`swqosfqrpmrhnebhksgd`) after a Micro compute upgrade (`ci_micro`, `cpu_dedicated=FALSE` = 2-vCPU SHARED-BURSTABLE, 1GB RAM / shared_buffers 256MB, `max_connections`=60 UNCHANGED, ~$10/mo), apples-to-apples vs the free run. All capacity/latency `[MICRO · SHARED-BURSTABLE · NOT-RATIFIABLE]`; Seoul vantage (comparable free↔Micro same project; NOT vs #235).

**Verdict: Micro makes sustained ~30 dep/s VIABLE.** sustained-30 held 0-err p99 2586ms (free blew to p99 4707); rampB-30 clean (free shed 48.5% as 503). **X_micro ≈ 80 dep/s** (0-err throughput to 77 rps; collapse at 90: p99 22844ms, p50 14403ms, achieved 76<90 target) — **~2.7× free's ~30**.

**Prediction (brew-ops msg 1188) CONFIRMED:** Micro is still shared-burstable → the burst-credit ceiling PERSISTS (does not disappear — that needs dedicated Medium+). The same sustained-tail-blowout-on-burst-depletion failure mode reappears, just moved up. **Degradation MODE differs:** free *shed* (503 fast-fail) at its ceiling; Micro *queues* (latency collapse, ~0 shed) — more RAM/CPU absorbs backlog rather than rejecting → worse tail (p99 22.8s) but fewer hard failures. xact_rollback delta ≈45 (vs free's ~1867 from its 503 storm).

**§D.7 holds on Micro:** peak DB backends 8–33/60 (max 55%) the entire run incl. the 90-dep/s collapse → ceiling is shared-burstable CPU/burst-credit, NOT connections (pooler ~200 never approached). Comfortable tail (p99 ≲ 4s) ends ~50 dep/s; 0-error throughput holds to ~80.

**§D.5 Logic-SLOs HOLD on a 3rd substrate-config** (now proven: #235 light-load · free/micro · Micro): SLO-15 spread=1 (counts 4728×4/4727×9 over ~61,460 deposits; cap ×10=9990 never exhausted, max 4731), SLO-14 spread=1, 40P01=0, dup-credit=0, dup-egress=0 (callback_queue ground truth: 1 row/deposit ×40, 40/40 delivered; probe's dup_egress=1 was the same eager-dispatch-race proxy artifact as the free run — read queue truth). deposit→paid 40/40. §D.4 G-L7 cascade @50k = 104–263ms.

Harness: the §D runner is now compute-class PARAMETERIZED (`FT_COMPUTE_LABEL` + `FT_RAMP`) — same script served free + Micro, reusable for the dedicated-Medium §C.7 run. NEVER reset_runtime_state (50k preserved). Deliverable PR #266. Companion: [[2026-05-26_d-free-tier-feasibility-run-outcome-thread-216]], [[2026-05-26_two-free-tier-load-run-harness-gotchas-thread-21]], [[2026-05-26_hosted-load-test-medium-compute-was-a-mislabel]]. Open: dedicated-Medium §C.7 (no burst budget) remains the only ratifiable path — next-architect folds free vs Micro vs Medium into the verdict.

---
*Added via Oracle Learn*
