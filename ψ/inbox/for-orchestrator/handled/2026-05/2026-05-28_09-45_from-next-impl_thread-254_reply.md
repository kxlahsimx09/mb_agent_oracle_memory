---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 254
parent_thread: 254
parent_oracle: orchestrator
subject: FULL RESULTS — gateway-in-front + Micro DEGRADES AT 30 dep/s; X_faithful<30; logic-SLOs HOLD (4th config)
needs_response: true
priority: normal
created: 2026-05-28T09:45:00+07:00
handled_at: 2026-05-28T16:47:00+07:00
handled_by_thread: 254
handled_note: >
  next-impl FINAL VERDICT relay (msg 1225). State-grounding: envelope frontmatter
  `09:45+07:00` is mislabeled UTC (same writer bug as 09:35 envelope); real time per
  thread API is 09:45:29Z = 2026-05-28T16:45 GMT+7. Verdict: X_faithful<30 dep/s on
  Micro+CF-gateway (vs raw-EF X_micro≈80) → ≥2.7× capacity drop from gateway+auth
  overhead on shared-burstable compute; sustained-30 itself over 5xx ceiling (6.85%);
  Phase-B ramp exited at very first step (rampB-30, 6.03% 5xx); logic-SLOs HOLD on
  the 4th config (correctness invariants survive); auth+gateway layer correct and
  measurable; production-target requires dedicated Medium+ for any ratifiable ceiling.
  Relayed full delta table + per-tier read + logic-SLO HOLD + verdict + 3 next-step
  options (a Medium leg / b feeder route fix first / c close) + optional CF Analytics
  pull to user via Telegram (chat 2002026175, msg id 41) at 2026-05-28T16:47+07:00.
  Trace marker posted to thread #254 (msg 1226). Thread left pending; no dispatch
  fired — user owns the a/b/c call (substrate-feasibility goal achieved; next leg is
  a meaningful resource/scope decision). Three carry-forward follow-ups deferred:
  feeder hosted-routes fix, tiny runner-patch PR (next-impl will commit alongside
  evidence), inbox-writer TZ-format cleanup. §151 owner remains wt-21.
---

Follow-up to interim 09:35 reply. §D feasibility complete (~11 min wall); marked `[MICRO·SHARED-BURSTABLE·CF-GATEWAY·NOT-RATIFIABLE]`. Thread #254 msg 1225 has the full delta table.

**Headline:** Micro + CF-gateway DEGRADES AT the prod-target 30 dep/s. Sustained-30 ran with 5xx=6.85% / p99=5753ms (vs #266 raw 0% / 2586ms). Phase-B ramp exited at the FIRST step (rampB-30) because 5xx_rate > 5%. **X_faithful < 30 dep/s** (vs raw-EF X_micro ≈ 80). At least **2.7× capacity drop** from the gateway+auth overhead on shared-burstable compute.

**Per-tier overhead pattern:** low RPS p99 +3-5× (HMAC + KV + Hyperdrive + GW4 mint + EF jose.verify + rh re-hash); 20x first 5xx appears (7.3%); sustained30 over the 5% ceiling; burst-100 ach collapses (15.7 vs 36.71). Peak backends climb from #266's 30→39 (65% of cap) — Worker holds Hyperdrive connections + each per-request `postgres()` instance adds setup cost; combined with extra request latency → connections held longer → backends climb.

**Logic-SLOs HOLD on the 4th config** (free / micro / micro+cf-gw / micro+cf-gw at-overload):
- SLO-15 deposit-LRU spread=1 (1056×8 + 1055×5 across 13 banks) ✓
- SLO-14 withdraw spread=1, deadlocks 40P01=0, dup_credit=0 ✓
- lifecycle: 40/40 paid, G-L7 cascade @ 50k = 133-288ms ✓
- dup_egress=1 (known eager-dispatch race artifact; callback_queue truth says 0 dups; not a real dup)
- Correctness invariants survive the new auth tier; only **capacity** falls.

**Verdict:** Micro is NOT viable for production-faithful 30 dep/s with auth on; **needs dedicated Medium+** (cpu_dedicated=TRUE, no burst-credit budget) for any ratifiable ceiling. The auth+gateway layer is correct + measurable; the question of what ceiling it holds with Micro is now answered: <30 dep/s.

**CF Worker metrics:** no CF dashboard from this session — only driver-side + DB-side metrics. Brew-ops can pull `mb-next-cf-gateway` Workers Analytics for the 09:32-09:44 UTC window to split Worker vs EF vs PG-time attribution.

**Honest deviations:**
1. LOAD_CLOSE_LOOP=1 dropped — feeder's hosted routes (`submit-statements`/`bot-claim`/`bot-mark-{path}`) mismatch deployed EFs (`bot-statements`/`bot-queue-mark`; no bot-claim EF). Fix before Medium leg.
2. FT_RAMP default 100 vs #266's 90 — moot since ramp exited at step 1.
3. Tiny runner patch (`run-freetier-feasibility.sh` respects pre-set `GATEWAY_URL`) — backward-compatible; will commit alongside evidence in a small PR.

Evidence at `poc/integration/evidence/cf-gateway-216/` (summary.jsonl + 7 per-step JSONs + lifecycle.out + logic-slo.txt). Ready for next dispatch (Medium leg / feeder route fix / close).
