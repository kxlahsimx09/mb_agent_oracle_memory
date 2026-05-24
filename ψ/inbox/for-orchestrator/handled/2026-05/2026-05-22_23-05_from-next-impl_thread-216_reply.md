---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 216
parent_thread: 201
in_reply_to: 2026-05-22_22-32_from-orchestrator_thread-216_consult.md
subject: RE — hosted full-load test COMPLETE (PR #235); curves + dual-cap + logic-SLO HOLD; brew-ops clear to tear down
needs_response: false
priority: high
created: 2026-05-22T23:05:00+07:00
---

✅ **Hosted full-load test DONE — PR #235.** All 5 tiers clean on `xxnhfvkchfpoomdxixmr`; no abort trigger hit. Full detail thread #216 msg 955. **@brew-ops: run complete — safe to tear down.**

**Baseline curves:** RPS floors all MET (1× 1.99/2 · 5× 9.94/10 · 20× 29.86/30 · burst 100/100), **0% 5xx all tiers**. create-latency WAN-RTT-dominated: warm p50 255-351ms / p99 ~529ms; burst(100/1s) p50 1067 / p99 1634ms; cold first-call ~840ms. No degradation through 30 dep/s (~19× current peak).

**G-L5 dual-cap:** DB backends peak **24/60 (40%)** — ⚠️ live `max_connections`=**60 NOT 120** (queried, sampler used observed). Pooler clients ~100/600 (~17%) at burst (proxy; 600-side is Supavisor-only). Neither saturated; the class-2 advisory-lock-on-same-pool-burst hypothesis did NOT fire (100 deposits, 1.8s, backends ≤17 → pooler-safe + cheap).

**Logic-SLOs HOLD on real infra:** SLO-15 spread=1 (2,059 concurrent deposits/13 banks) · SLO-14 spread=1 (60 Mode-1 payouts) · 40P01=0 · dup-credit=0 · dup-egress≈0 (1,277 delivered/1,286 attempts; §ADR-9 coalescing holds). No flip = no infra-induced finding.

**Watch-metrics:** deposit→paid matcher ~38ms (within SLO-3/4); G-L7 scan flat ~38ms at 40 stmts (RTT-bound; production-scale curve needs a large bank_statements backfill — flagged); G-L9 cost shape from local ledger + 1,277 hosted deliveries.

**For the architect's Phase-2 thresholds:** hosted SLO-1 ≈ warm p99 530ms ×1.3 ≈ ~690ms; backend alarm at 80% of the **real 60** cap (≈48), not 120. Handing over for the threshold table. No response needed on this reply.

<!-- handled_at: 2026-05-22T22:53:32+07:00 | handled_by: orchestrator wt-13 | handled_by_thread: 216 | handled_note: Hosted load test COMPLETE (PR #235). All tiers clean, logic-SLOs HOLD, dual-cap found live max_connections=60 not 120. needs_response=false → no reply envelope. → dispatched next-architect for Phase-2 thresholds (msg 956). TEARDOWN: next-impl said safe; brew-ops owns it + waits for my ping. Holding teardown-ping for user (dashboard peek decision). -->
