---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 254
parent_thread: 254
parent_oracle: orchestrator
subject: INTERIM — gateway-in-front run LAUNCHED on Micro; partial data; full delta + X_faithful follows
needs_response: true
priority: normal
created: 2026-05-28T09:35:00+07:00
handled_at: 2026-05-28T16:39:00+07:00
handled_by_thread: 254
handled_note: >
  next-impl interim status on the gateway-in-front feasibility run (msg 1223) relayed to
  user. State-grounding caught: envelope frontmatter `09:35+07:00` is mislabeled UTC
  (next-impl writer uses UTC in filename/created; brew-ops uses GMT+7 — minor tooling
  inconsistency, non-blocking). Actual time per thread API: 2026-05-28T16:35 GMT+7
  (msg 1223 `timestamp = 09:35:37Z`). §151 owner remains wt-21 (msg 1222 dispatch).
  Relayed: setup confirmed; honest deviation (LOAD_CLOSE_LOOP=1 no-op vs hosted because
  feeder hosted-routes don't match deployed EFs → run = gateway-overhead delta only,
  not full money-path); partial Phase-A data (warm p99 3.23×#266, 1x p99 5.09×#266,
  Worker backends 22/60 at 2rps); continuity flag (bg script alive at session-stop,
  substrate untouched); pending tiers + full delta + X_faithful + logic-SLOs + verdict
  on next-session resume. Telegram chat 2002026175, msg id 40 at 2026-05-28T16:39+07:00.
  Trace marker posted to thread #254 (msg 1224). Thread left pending; no dispatch fired
  (`needs_response: true` is inbox-loop-closure per protocol, not a new ask). Two small
  follow-up dispatches surfaced for future consideration (feeder hosted-routes fix;
  optional inbox-writer TZ-format cleanup) — both deferred until user signals.
---

Closing the 15:05 consult inbox loop per protocol while the §D run is in flight (session about to stop on inbox gate; thread #254 msg 1223 has the full status).

**Setup confirmed:** same Micro project as #266 (Seoul, max_conn=60), Worker `https://mb-next-cf-gateway.midasgoteam.workers.dev` pre-flight smoke green (signed→201 real deposit, unsigned→401), runner patched to respect pre-set `GATEWAY_URL`, toggles `GATEWAY_URL=<worker> + LOAD_SIGN_REQUESTS=1 + FT_COMPUTE_LABEL=MICRO·SHARED-BURSTABLE·CF-GATEWAY·NOT-RATIFIABLE + FT_RAMP="30 40 50 60 70 80 100"` (default; #266 used 90 final).

**⚠ Honest deviation:** `LOAD_CLOSE_LOOP=1` was a no-op against hosted because the money-path-feeder's hosted route names (`submit-statements`, `bot-claim`, `bot-mark-{path}`) don't match deployed EFs (`bot-statements`, `bot-queue-mark`; no `bot-claim` EF exists). I dropped the feeder for this run → matches #266 deposit-create-only shape exactly (cleaner apples-to-apples for **gateway-overhead delta**: HMAC + KV + GW4 mint/verify + EF re-hash + jose.verify). Finalize/MDR/callback@volume needs the feeder hosted-routes fix as a follow-up.

**Partial data (Phase A in progress):**
- warm: ach 1.7 / p99 **5994ms** vs #266 1855 (3.23×)
- 1x: ach 1.9 / p99 **5553ms** vs #266 1090 (5.09×)
- Worker backends 22/60 (vs #266 12) — Hyperdrive holds connections.

5x / 20x / sustained30 / burst + Phase-B ramp still to come.

**Run continuity:** bg script + bun driver alive at session-stop. If harness SIGTERMs on stop the run is partial; I re-launch from the next session. Substrate untouched (no reset_runtime_state). **Full delta table + X_faithful + logic-SLO re-verify + verdict come in a follow-up reply on next-session resume.**
