---
title: Free-tier load-test feasibility: the binding constraint flips from connections t
tags: [system-architect, repo:mb-next-payment-gateway, next, scale, load-harness, reliability, trade-off, decision, provisional]
created: 2026-05-26
source: docs/design/load-harness/perf-slos-and-ef-concurrency.md §D (PR #252); thread #216 msg 1053/1057
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Free-tier load-test feasibility: the binding constraint flips from connections t

Free-tier load-test feasibility: the binding constraint flips from connections to SHARED CPU — and that flips the whole run shape.

Context (thread #216, parent #201, 2026-05-26): user chose to run the hosted "does-it-hold?" (ไหวไหม) load probe on a FREE-tier Supabase project in the EXISTING org ($0) instead of the §C.7 dedicated-Medium stress run. I authored the free-tier feasibility run profile as §D of docs/design/load-harness/perf-slos-and-ef-concurrency.md (PR #252).

The load-bearing realization:
- The earlier #235 run labelled "Medium" had already measured live `max_connections` = 60 (queried `current_setting`, not the spec — the Medium spec table wrongly said 120). Free-tier spec (verified 2026-05-26): 60 direct connections + ~200 pooler (Supavisor) + 500 MB RAM + SHARED CPU + 500 MB DB size.
- So the CONNECTION cap is IDENTICAL between Medium and free (60). The pooler drops 600→~200 but ~200 still exceeds the ~100-client burst. Neither connection side is the new constraint.
- → The binding constraint flips connections → SHARED CPU / 500 MB RAM. On a shared instance the CPU throttles (RAM pressure, disk-IO contention) BEFORE the 60-conn cap binds, and the numbers are noisy-neighbour-shared → non-reproducible → NOT ratifiable as an infra threshold.

What that changes about the run (vs the §C.7 dedicated plan that targeted "ramp backends to 48–54/60 to find the conn knee"):
1. Do NOT hunt a connection-saturation knee — it is invalid on shared CPU (CPU saturates first). Instead ramp open-loop until the SHARED-CPU degradation point: create-5xx climbs / `57014 statement_timeout` appears / latency-tail blows out. Deliverable = "free tier sustained ~X dep/s before degradation" (a single-sample LOWER BOUND with a noisy-neighbour caveat, never a guaranteed ceiling).
2. Sustained mode matters MORE on shared CPU: hold the target tier for MINUTES, not 45s — short tiers ride burst CPU credits and look artificially clean; only a multi-minute sustained load exhausts credits and reveals the steady-state floor.
3. The G-L5 sampler's PURPOSE inverts: it is no longer finding a conn knee; it CONFIRMS backends stay LOW (well under 60) WHILE latency/5xx degrade — that low-backends-but-degrading pattern is the positive evidence that the ceiling is CPU/RAM, not connections.
4. Every capacity/latency number is tagged [FREE-TIER · SHARED-CPU · NOT-RATIFIABLE]. The feasibility run does NOT supersede the §C.7 dedicated-compute run, which remains the only path to RATIFIABLE infra thresholds.
5. Logic-SLOs (spread=1 SLO-14/15, 40P01=0, dup-credit=0, dup-egress≈0) are the ONE thing that ratifies regardless of compute — they are mechanism-bound + scale/compute-invariant (advisory-lock serialization, SKIP LOCKED, NOTIFY-coalescing), so a HOLD on free tier re-confirms PR #236 §C.5 on a second substrate. A FLIP would be an infra-induced finding, not a logic regression. This is the same correctness-is-mechanism-bound / capacity-is-load-bound split from the #235 scope-correction.
6. G-L7 statement backfill capped at ~50k (NOT 500k) because of the 500 MB free-tier DB-size cap.

Durable rule: when re-tiering a load test onto a cheaper/shared compute class, re-derive WHICH resource binds first before reusing the prior plan's knee-finding target. A connection-cap knee plan is meaningless on shared CPU; query the live caps (max_connections, pooler) AND identify the shared-resource (CPU/RAM/disk-IO) that throttles ahead of them. Companion to the volume-vs-capacity lesson (N×-current-volume ≠ capacity stress) and the "alarm vs the live-queried cap, not the spec" lesson.

## Correction (2026-05-26, P-004 — read with this)

There was **no real Medium baseline to "flip" from.** The #235 run, recorded as "Medium compute," was a **MISLABEL** — that project ran on **free/micro-equivalent compute the whole time** (the live `max_connections`=60 is the *free/micro* value, NOT Medium's 120; a Supabase Pro **org** does not auto-provision Medium **project**-compute — the add-on is per-project + must be explicitly selected). So the binding-constraint "flip" framing above is better read as: **shared CPU was always the binding constraint on this (always-free-equiv) compute — the tiny #235 run simply never reached it.** Today's feasibility run is the **same compute class** as #235, not a step-down; its distinct value is the degradation ramp + sustained-minutes + 50k backfill the tiny run never did. PR #252 §D.0/§C.7 carry the corrected framing (commit 5a36da7); authoritative record = orchestrator learning `2026-05-26_hosted-load-test-medium-compute-was-a-mislabel`. **Strengthened durable rule:** never trust the dashboard/org compute *label* — verify the compute via the live-queried `max_connections` (the org-Pro tier did not imply project-Medium compute here).

---
*Added via Oracle Learn*
