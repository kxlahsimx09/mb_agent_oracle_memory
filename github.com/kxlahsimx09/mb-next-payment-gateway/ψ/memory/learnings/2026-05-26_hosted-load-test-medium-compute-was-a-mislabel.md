---
title: Hosted load-test "Medium compute" was a MISLABEL — #235/#216 ran on free/micro-e
tags: [orchestrator, repo:mb-next-payment-gateway, next, poc, load-harness, perf-slo, substrate, supabase, compute-mislabel, max-connections, free-tier, drift, decision, thread-216, parent-201, C7-prerequisite]
created: 2026-05-26
source: orchestrator — user correction on thread #216 (2026-05-26), from PR #236 §C.3 max_connections=60 evidence
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Hosted load-test "Medium compute" was a MISLABEL — #235/#216 ran on free/micro-e

Hosted load-test "Medium compute" was a MISLABEL — #235/#216 ran on free/micro-equivalent compute the whole time (Code-is-Truth, P-004).

EVIDENCE: next-impl's live `current_setting('max_connections')` on the loadtest project = **60** (PR #236 §C.3). 60 is the Supabase free/micro value; Medium's spec value is 120. The substrate contradicts the "Medium" label.

ROOT CAUSE: a Supabase **Pro org does NOT auto-provision Medium compute**. The compute add-on is **per-project** and must be explicitly selected. The 2026-05-22 setup created a NEW Pro org (+$25/mo) but the project stayed on the included micro/free-equiv compute → org-Pro status ≠ project-Medium compute. So the "$25/mo Medium baseline" was never Medium.

CONSEQUENCES:
1. #235's "tiny-profile baseline" was effectively a **free-tier run at tiny load** (peaked 24/60 backends = 40%; ~30 dep/s for 45s). It never stressed the compute.
2. The 2026-05-26 free-tier feasibility run (thread #216 §D / PR #252) is the **same compute class** as #235 — so its distinct value is the **degradation ramp (Phase B 30→40→50→60+ until 5xx/57014/latency-tail) + sustained-minutes mode + 50k matcher backfill** that the tiny run never did — NOT a free-vs-Medium comparison.
3. A ratifiable **§C.7 dedicated-compute baseline REQUIRES explicitly adding the Medium compute add-on per-project** — a Pro org alone is insufficient (proven here). Any future "ratifiable infra threshold" run must verify `max_connections` live (≈120 for real Medium) before trusting the compute label.

Tags this as #drift (doc/intention "Medium" vs substrate truth "free-equiv"). Surfaced by the user 2026-05-26 from the #235 max_connections=60 evidence.

---
*Added via Oracle Learn*
