---
title: §D CF-gateway re-run (thread #254) — the Cloudflare gateway-in-front tier is NOT
tags: [implementation-architect, repo:mb-next-payment-gateway, next, poc, load-test, cf-gateway, client-api-gateway, perf, poc-ready, gotcha, fixture-source:integration-test, thread-254]
created: 2026-05-28
source: poc/integration/evidence/cf-gateway-254/SUMMARY.md@45708a3 + PR #278
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# §D CF-gateway re-run (thread #254) — the Cloudflare gateway-in-front tier is NOT

§D CF-gateway re-run (thread #254) — the Cloudflare gateway-in-front tier is NOT a throughput bottleneck; yesterday's `cf-gateway-216` collapse was 100% measurement contamination, not architecture.

Context: §ADR-2 §Amendment 2026-05-28 relocated client-API HMAC + rate-limit OUT of EF middleware INTO a dedicated CF Worker tier. The first load run through that stack (`cf-gateway-216`) collapsed at step 1 (<30 dep/s, 6.85% 5xx, sustained-30 p99 5,753ms) — which looked like the gateway was the bottleneck. It was not. Three independent contaminants were stacked: (1) un-hygiene'd substrate, (2) CF Workers FREE plan KV write-cap exhaustion → 503s, (3) a spec-§3.2 bug (rate-limit did not fail-open on KV exception → propagated 500s).

Finding: after removing all three (PR #276 hygiene + CF Paid plan + PR #277 §3.2 fail-open patch, Worker version 1a8c9ab8) and re-running the IDENTICAL profile, the ceiling recovered to **X_faithful ≥ 90 dep/s** — the FT ramp held 0-error to its 90 upper bound with NO degradation trigger (rampB-90 p99 8,009ms < 3×baseline 8,616ms). That EXCEEDS raw-EF Micro's ~80 (micro-216), because the substrate-hygiene lever (#276) lowered DB work per request enough to offset the gateway's added hop. At the production-target sustained-30, the gateway hop adds only ~11% (+286ms: 2,586→2,872ms p99) vs raw-EF Micro — negligible.

Per-tier (CF-gw p99): sustained-30 2872 · rampB 30:2829 40:2912 50:3253 60:3533 70:3887(1×504) 80:6636 90:8009. Comfortable tail (p99≲4s) to ~70; queue-not-shed mode above (same family as Micro). Peak DB backends 14→45/60 → CPU/burst-credit bound, not connections (§D.7 again).

Methodology gotchas (re-confirmed, NOT new): (a) the lifecycle probe's `dup_egress` is a proxy artifact — it sampled `delivered=0` mid-dispatch; the callback_queue GROUND TRUTH = 10,231 delivered ↔ 10,231 distinct dedup_keys, 0 multi-delivered, 0 dead-letter, 0 non-2xx → dup-egress=0 real. ALWAYS read the queue, not the probe. (b) "fail-open" warnings are CF Worker-side logs (wrangler tail), invisible driver-side; absence of 5xx-storm is the driver-side proxy.

Ratifiability: all capacity/latency numbers `[MICRO·SHARED-BURSTABLE·CF-GATEWAY·PAID·HYGIENE-APPLIED·NOT-RATIFIABLE]` — Micro is still shared-burstable (cliff persists ABOVE the ramp bound; not measured this run), and the ramp hit its upper bound not a degradation point. Only the logic-SLO HOLD crosses into ratifiable: SLO-14/15 spread=1, 40P01=0, dup-credit=0, dup-egress=0, deposit→paid 40/40 — now proven on the **5th substrate-config** (Medium-mislabel #235 · free/micro · Micro · cf-gateway/Micro). No FLIP.

Caveat on attribution: the cross-comparison to raw-EF Micro is NOT a clean gateway-overhead isolation (hygiene changed too); the only clean A/B is vs cf-gateway-216 (same gateway, 3 contaminants removed). Durable lesson: when a new tier "looks slow," isolate measurement contaminants (plan caps, spec bugs, substrate hygiene) before blaming the architecture — a 3× recovery came purely from removing contaminants.

Evidence: poc/integration/evidence/cf-gateway-254/ (SUMMARY.md + run-summary.jsonl + 13 driver reports + logic-slo.txt + lifecycle.jsonl). PR #278. Runner change: run-freetier-feasibility.sh now honors a pre-set GATEWAY_URL to target the CF Worker.

---
*Added via Oracle Learn*
