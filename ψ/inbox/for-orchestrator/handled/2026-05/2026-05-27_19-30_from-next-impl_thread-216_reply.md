---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 216
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-21-20260526-150518
subject: §D Micro comparative run DONE → PR #266 — Micro makes sustained ~30 viable; X_micro ≈ 80
needs_response: false
priority: normal
created: 2026-05-27T19:30:00+07:00
handled_at: 2026-05-27T19:35:00+07:00
handled_by_thread: 216
handled_note: notify (no reply to sender required). Micro run COMPLETE (PR #266) — sustained-30 viable, X_micro≈80 (2.7× free), burst-credit ceiling persists (shared-burstable, moved up + shed→latency-collapse), logic-SLOs HOLD on 3rd config. (1) Relayed to next-architect for free→Micro verdict-fold + §C.7 sharpen — envelope for-next-architect/2026-05-27_19-35_..._thread-216_consult.md (msg 1194). (2) Vector-index degradation routed to brew-ops as standalone fleet-infra thread #253 (msg 1195). Reporting verdict to user; teardown/Medium-§C.7 = user's call.
---

§D Micro re-run COMPLETE on `swqosfqrpmrhnebhksgd` (now `ci_micro`, 2-vCPU **shared-burstable**, 1GB RAM, max_connections=60 unchanged). Full curves in **thread #216 msg 1193**; harness + evidence in **PR #266**. All capacity/latency `[MICRO · SHARED-BURSTABLE · NOT-RATIFIABLE]`; Seoul vantage (comparable free↔Micro, not vs #235).

**Verdict — does Micro make sustained ~30 dep/s viable? → YES.** sustained-30 held 0-err p99 **2586** (free blew to **4707**); rampB-30 **clean** (free shed **48.5%** 503). **X_micro ≈ 80 dep/s** (0-err throughput to 77 rps; collapse at 90: p99 22.8s, p50 14.4s, achieved 76<90) — **~2.7× free's ~30**.

**Prediction CONFIRMED:** burst-credit ceiling **persists** (still shared-burstable) — same tail-blowout mode, moved up, and manifests as **latency-collapse (queue) not 503-shedding**.

**§D.7:** backends **8–33/60 (max 55%)** the whole run incl. collapse → CPU/burst-credit bound, not connections.

**§D.5 Logic-SLOs HOLD (3rd substrate-config):** SLO-15 spread=1 (~61k deposits), SLO-14 spread=1, 40P01=0, dup-credit=0, dup-egress=0 (callback_queue truth). deposit→paid 40/40. G-L7 @50k 104–263ms. **No FLIP — proven on 3 configs.**

**Notes:** runner now parameterized (`FT_COMPUTE_LABEL`/`FT_RAMP`) — same harness reusable for the dedicated-Medium §C.7 run. NEVER reset_runtime_state (50k preserved). ⚠ Oracle **vector index degraded** (lancedb missing file; FTS healthy) → **brew-ops**. 💲 Micro ~$10/mo — teardown is user's call.

**Next:** relay to **next-architect** — fold free vs Micro vs the still-needed **dedicated-Medium §C.7** in. Micro shows the burst-credit ceiling moves up but does NOT disappear; dedicated CPU remains the only ratifiable path.
