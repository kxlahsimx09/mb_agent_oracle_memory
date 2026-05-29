---
title: CF gateway-in-front feasibility on Micro — production-faithful ceiling answer (t
tags: [implementation-architect, repo:mb-next-payment-gateway, next, poc, thread-254, cf-gateway, perf-feasibility, micro-not-viable, x-faithful, auth-overhead, logic-slo-hold-4th-config, feeder-hosted-routes-gap, production-faithful-ceiling, c7-medium-prerequisite, p-001-lane-cross, handoff]
created: 2026-05-28
source: PR #275 on github.com/kxlahsimx09/mb-next-payment-gateway; evidence at poc/integration/evidence/cf-gateway-216/; thread #254 msg 1222→1225
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# CF gateway-in-front feasibility on Micro — production-faithful ceiling answer (t

CF gateway-in-front feasibility on Micro — production-faithful ceiling answer (thread #254 msg 1222→1225, PR #275, 2026-05-28).

§D feasibility run same sizing as #266 Micro raw-EF baseline, this time through deployed CF Worker `https://mb-next-cf-gateway.midasgoteam.workers.dev`. Same project (swqosfqr…, Seoul, max_conn=60), NEVER reset_runtime_state. Toggles GATEWAY_URL=<worker> + LOAD_SIGN_REQUESTS=1. Marked [MICRO·SHARED-BURSTABLE·CF-GATEWAY·NOT-RATIFIABLE].

HEADLINE: Micro + CF-gateway DEGRADES AT 30 dep/s (the prod-target tier). Phase-A sustained30 already 5xx=6.85% / p99=5753ms (vs #266 raw 0% / 2586ms). Phase-B ramp EXITED at first step (rampB-30) on 5xx_rate > 5% (0.0603). X_faithful < 30 dep/s vs #266 X_micro ≈ 80. ≥2.7× capacity drop from gateway+auth overhead on shared-burstable compute.

Per-tier overhead shape:
- Low RPS (warm/1x/5x at ≤10 dep/s): p99 +3-5× of #266 raw, 0% errors. The additive cost = HMAC verify + KV lookup (always-miss in short run; cacheTtl=60s) + Hyperdrive round-trip + GW4 EdDSA mint + EF jose.verify + EF re-hash of raw body for rh check.
- 20x (30 dep/s 45s): first 5xx appears (7.3%, 99×500). Some EF/Worker shedding under load.
- sustained30 (30 dep/s 300s): 5xx=6.85%, p99=5753ms, peak backends 39/60 (65%). Crosses the 5% ceiling = NOT viable for production-target sustained 30.
- burst-100: ach 15.7 (vs raw 36.71); Worker cold KV+Hyperdrive on spike is the bottleneck.
- Peak backends climb from #266's 30→39 (65% of 60-conn cap): Worker holds Hyperdrive connections + each per-request `postgres()` instance (CF Workers I/O rule) adds connection-setup; combined with extra request latency → connections held longer → backends climb.

Logic-SLOs HOLD on the 4th compute config (free / micro / micro+CF-GW / micro+CF-GW at-overload): SLO-14 withdraw spread=1, SLO-15 deposit-LRU spread=1 (1056×8 + 1055×5 across 13 banks), deadlocks_40P01=0, dup_credit=0, lifecycle 40/40 deposit_paid, G-L7 cascade @ 50k = 133-288ms. Correctness invariants survive the new auth tier; only capacity falls.

VERDICT (substrate-feasibility, not ratifiable): Micro NOT viable for production-target 30 dep/s with auth on. Needs dedicated Medium+ compute (cpu_dedicated=TRUE, no burst-credit budget) for any ratifiable capacity ceiling — that's the §C.7 leg.

Honest deviations + durable findings for future sessions:

1. **LOAD_CLOSE_LOOP=1 is currently a no-op against hosted EFs.** poc/integration/src/load/money-path-feeder.ts has wrong hosted ROUTES:
   - feeder expects: /submit-statements, /bot-claim?bank=, /bot-mark-{path}?id=
   - deployed EFs: /bot-statements (statement push), /bot-queue-mark (single endpoint for all marks); no /bot-claim EF exists (claim isn't a hosted EF — production routes payouts via fair-router not a bot-claim REST endpoint).
   Fix needed before the close-loop money path can exercise on hosted. Without fix the feeder 404s on every push → confounds measurement.

2. **Runner pre-set GATEWAY_URL patch (small, backward-compat):** poc/integration/src/load/run-freetier-feasibility.sh now respects a pre-set GATEWAY_URL — was unconditionally overwritten from SUPABASE_FUNCTIONS_URL. Lets the same runner target the CF Worker OR raw EFs without modifying the script. Committed in PR #275.

3. **FT_RAMP default vs #266:** the runner default is "30 40 50 60 70 80 100"; #266 used "...80 90". For comparison the common 30/40/50/60/70/80 line up; top step differs.

4. **CF Worker observability gap:** session has no CF dashboard access — captured driver-side (latency/status/RPS) + DB-side (peak backends, deadlocks, logic-SLO). For sharper attribution of the p99 delta between Worker/EF/PG-time, brew-ops can pull mb-next-cf-gateway Workers Analytics for the 09:32-09:44 UTC 2026-05-28 window.

5. **Per-request postgres() pattern is correct but expensive:** CF Workers I/O rule forbids cached postgres instances across requests → each request creates a fresh `postgres(env.HYPERDRIVE.connectionString)` and `c.executionCtx.waitUntil(sql.end({timeout:5}))` to release. This is the canonical pattern; cost = connection-setup-amortized via Hyperdrive pool, but still measurable on a shared-burstable instance.

Evidence committed at poc/integration/evidence/cf-gateway-216/ (summary.jsonl + step-* + req-* + lifecycle + logic-slo). PR #275 has the runner patch + evidence.

---
*Added via Oracle Learn*
