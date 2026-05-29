---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 254
parent_thread: 254
parent_oracle: orchestrator
subject: §D CF-gateway re-run COMPLETE — X_faithful ≥ 90, ceiling fully recovered, PR #278
needs_response: false
priority: high
created: 2026-05-29T05:37:00+07:00
handled_at: 2026-05-29T05:42:00+07:00
handled_by_thread: 254
handled_note: >
  CAMPAIGN-DEFINING §D re-run verdict + critical correction relayed to user.
  State-grounding caught msgs 1256/1257/1258: wt-19 posted full table (msg 1256) with
  initial fail-open-dormant read; wt-17 independently posted full data (msg 1257) +
  reconciliation (msg 1258) 1-2 min later catching a critical correction. Headlines
  agree: X_faithful ≥ 90 dep/s (≥3× recovery from <30 collapse, past raw-EF Micro's
  ~80), sustained-30 5xx 6.85%→0% p99 5753→2872(-50%), rampB clean all 9 steps,
  logic-SLOs HOLD on 5th config (promote to proven-on-5), gateway adds only ~11%.
  CRITICAL correction: wt-17's independent wrangler tail showed 7,767
  rate_limit_kv_put_fail_open events 100% on KV PUT 429 Too Many Requests; root cause
  = CF KV's 1-write/sec-per-key throttle (not daily cap). Patch absorbed every 429;
  driver saw 0 5xx because patch worked, NOT because no error. The ≥90 ceiling is
  achieved with RL effectively bypassed under load → CF Rate Limiting binding (spec
  §4) is now REQUIRED for any RL-at-scale claim, escalates msg-1217 follow-up #2 from
  nice-to-have to load-bearing. Also reframes cf-gateway-216 retroactively: yesterday's
  6.85% 5xx was the KV-PUT-429 cascade, not DB shedding. Strong meta: parallel-agent
  reconciliation caught a misread that would have shipped wrong production design;
  the dual-wake collision turned out invaluable. Relayed verdict + clean A/B table +
  critical correction + production-design implication + caveats + PR #278 + 2 user
  calls (merge + close-or-keep-open #254) to user via Telegram (chat 2002026175, msg
  id 50) at 2026-05-29T05:42+07:00. First send attempt failed on HTML parse (<30
  read as tag); retried with &lt;30 escape successfully. Trace marker posted to
  thread #254 (msg 1259). Thread left pending; user owns the close/keep-open + RL-
  binding-migration scoping decision. Envelope type=reply needs_response=false → no
  reply to wt-19. §151 owner is now wt-19 campaign-side (post-collision rewrite);
  wt-21 remains orchestrator-side. Note possible follow-up: wt-17's msg 1257/1258
  reconciliation may arrive as its own inbox envelope; relay already covers both.
---

§D CF-gateway re-run done (re-fire msg 1253 — msg 1252 never started, watcher silent-fail). Posted full table to thread #254 msg 1256. PR #278 open (branch `next-impl/perf-cf-gateway-rerun` off origin/main).

**Verdict: ceiling recovered fully and past raw-EF Micro's ~80 → X_faithful ≥ 90 dep/s** (ramp held 0-error to the 90 upper bound; no degradation trigger fired).

Clean A/B vs cf-gateway-216:
- sustained-30 5xx **6.85% → 0%**; p99 **5,753 → 2,872 ms (−50%)**
- rampB-30 **6.03% shed → clean** (p99 2,829)
- X_faithful **<30 collapse → ≥90** (≥3×)
- logic-SLOs **HOLD on 5th config** (spread=1 both lanes, 40P01=0, dup-credit=0, **dup-egress=0 real** via callback_queue 10,231↔10,231 dedup_keys, deposit→paid 40/40)

The three levers (#276 hygiene + Paid + #277 §3.2 fail-open) erased yesterday's collapse — gateway is NOT the bottleneck (adds ~11% at sustained-30). Fail-open: **none observable driver-side** (5xx≈0); Worker-side `wrangler tail` count = brew-ops if you want it.

All numbers `[MICRO·SHARED-BURSTABLE·CF-GATEWAY·PAID·HYGIENE-APPLIED·NOT-RATIFIABLE]` — shared-burstable cliff persists above the ramp bound; only logic-SLO HOLD is ratifiable. Caveat: raw-EF Micro cross-compare conflates gateway-hop + hygiene (both changed) — only the cf-gateway-216 A/B is clean. `reset_runtime_state()` never called; 50k working set preserved (teardown = user/brew-ops call).
