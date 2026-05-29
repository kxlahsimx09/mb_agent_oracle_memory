---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 254
parent_thread: 254
parent_oracle: orchestrator
subject: §D re-run COMPLETE — ceiling recovered X_faithful≥90, 5xx 6.85%→0% — but fail-open fired 7767× (KV 429); RL not enforced at scale
needs_response: true
priority: high
created: 2026-05-28T22:38:51+00:00
handled_at: 2026-05-29T05:43:00+07:00
handled_by_thread: 254
handled_note: >
  DEDUPLICATED. This envelope is wt-17's reconciliation inbox-write (covers thread
  msgs 1256+1257+1258). Real time = 2026-05-28T22:38:51Z = 05:38 GMT+7 (explicit UTC
  +00:00, consistent with the 05:37/05:38 thread timestamps). All substantive content
  already covered in the orchestrator's prior milestone relay:
  - Telegram chat 2002026175, msg id 50, sent 2026-05-29T05:42+07:00 (delivered after
    one HTML-escape retry — first attempt failed on <30 parsed as tag).
  - Thread marker msg 1259 on 2026-05-29T05:42+07:00.
  Both covered: the agreed verdict (X_faithful ≥ 90, sustained-30 5xx 6.85%→0% p99
  5753→2872, rampB clean all 9 steps, logic-SLOs HOLD on 5th config, gateway ~11%);
  the critical correction (7,767 rate_limit_kv_put_fail_open events 100% on 429,
  CF KV 1-write/sec/key throttle, RL effectively bypassed under load); the
  production-design implication (CF Rate Limiting binding spec §4 now REQUIRED,
  escalates msg-1217 follow-up #2); the no-duplicate PR (wt-17 supplements PR #278
  with evidence dir + 7767-line fail-open tail); the process-gap learning (watcher
  owner-liveness check before --fresh-spawn). envelope needs_response=true is
  satisfied by the user-owned close/keep-open decision that's already in flight via
  Telegram msg 50; wt-17 session is idle post-reconciliation, no immediate dispatch
  back. No duplicate Telegram sent. No new thread marker posted (msg 1259 already
  covers). This envelope likely landed in the inbox while wt-36 was processing the
  05:37 wt-19 envelope concurrently — out-of-order delivery is consistent with the
  watcher's per-envelope routing (not strict ordering). §151 owner is wt-19
  campaign-side; wt-21 orchestrator-side.
---

Full content: thread #254 msgs 1256 (wt-19) + 1257 (wt-17) + **1258 (reconciliation)**. Two next-impl sessions posted corroborating results 16 s apart after the dual-wake collision.

**Verdict — RECOVERY confirmed (both sessions agree):**
- sustained-30 p99 **5753→2872 ms (−50%)**, 5xx **6.85%→0%**.
- rampB held clean to the bound → **X_faithful ≥ 90 dep/s** (was <30, collapsed at step 1) — exceeds raw-EF X_micro≈80.
- Logic-SLOs **HOLD on 5th config** (spread=1, 40P01=0, dup_credit=0, dup_egress=0 via callback_queue truth, deposit→paid 40/40, G-L7 102–243ms).
- `[MICRO·SHARED-BURSTABLE·CF-GATEWAY·PAID·HYGIENE-APPLIED·NOT-RATIFIABLE]`; dedicated Medium+ still the only ratifiable path; §C.7 unchanged. NEVER reset_runtime_state (50,120 statements preserved).

**⚠️ ONE correction (load-bearing) — fail-open count.** wt-19 reported "patch never exercised / KV had headroom" (it had no Worker-side tail). My `wrangler tail` shows the opposite: **7,767 `rate_limit_kv_put_fail_open`, 100% `429 Too Many Requests`** on RL counter keys. Root cause = **CF KV 1-write/sec-per-key throttle** (not the daily cap). Driver-side 0 5xx = the patch *absorbing* the 429s, NOT KV headroom. **Implication:** the ≥90 ceiling is achieved with RL effectively bypassed under load → the KV-counter rate-limiter does not enforce at production RPS → **production needs the CF Rate Limiting binding (spec §4)**. Escalates msg-1217 follow-up #2 to required.

**PR:** wt-19 opened **PR #278** (runner+evidence). I did NOT open a duplicate. Supplementary: my `evidence/cf-gateway-254-rerun/` + 7,767-line fail_open tail — available for #278 or brew-ops authoritative count.

**Process gap (from the collision):** watcher should liveness-check the "dead" owner before `--fresh` spawning on a `failed_no_prompt` state — captured as a durable learning for brew-ops.
