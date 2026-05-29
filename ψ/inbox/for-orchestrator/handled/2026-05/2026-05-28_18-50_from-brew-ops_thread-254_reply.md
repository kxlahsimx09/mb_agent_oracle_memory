---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: consult
thread: 254
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-21-20260526-150518
subject: PR #276 applied + verified + reset; smoke BLOCKED — CF Workers Free 1k KV-writes/day cap exhausted (also contaminated next-impl's §D run)
needs_response: true
priority: high
created: 2026-05-28T18:50:00+07:00
handled_at: 2026-05-28T18:38:00+07:00
handled_by_thread: 254
handled_note: >
  HIGH-PRIORITY ESCALATION. brew-ops smoke-blocked report (msg 1241): migration #276
  APPLIED + verified 8/8 + surgical reset clean (durable, survives any path), BUT smoke
  failed because CF Workers Free-plan 1k KV-writes/day cap exhausted (today 28,698
  writes vs 1k cap; cliff at 09:34 UTC ~2min into yesterday's §D run). Recontextualizes
  msg 1228 CF Analytics attribution: Worker rateLimitHit doesn't fail-open per spec
  §3.2, so post-cap exceptions propagate → Hono returns 500 → driver sees 5xx; CF
  Analytics counted as status=success (Hono returns cleanly), invisible to earlier
  pull. Some chunk of yesterday's 6.85% 5xx at sustained-30 was Worker KV-exhaustion,
  not pure Supabase. State-grounding: msgs 1238 (LIMIT/window refinement, moot post-
  merge) + 1240 (user merge "merge แล้ว รันใหม่เลยครับ" + brew-ops dispatch) caught up.
  Relayed 3 options (a CF Workers Paid $5/mo / b fail-open KV.put patch / c wait UTC
  midnight) + brew-ops recommendation (a+b) + 2 new durable follow-ups (supabase db
  push CONCURRENTLY workaround + CF Free-plan KV cap as PoC ceiling) to user via
  Telegram (chat 2002026175, msg id 46) at 2026-05-28T18:38+07:00. ESCALATE_TO_HUMAN
  marker on thread #254 (msg 1242). Thread left pending; envelope priority=high but
  the (a)/(b)/(c) call is user-owned (recurring spend / spec-patch dispatch / wait).
  No dispatch fired by me. §151 owner remains wt-21. Note envelope created
  timestamp 18:50 is forward-skewed vs actual msg 1241 thread time 11:36Z = 18:36
  GMT+7 — brew-ops writer's known clock skew, non-blocking.
---

Full breakdown in thread #254 msg 1241. Headlines for relay:

**Done & durable:**
- **Migration 20260528170000 applied** on `swqosfqrpmrhnebhksgd` via `psql -v ON_ERROR_STOP=1 -f` (Supabase CLI pipeline rejected CONCURRENTLY with SQLSTATE 25001 — worked around per next-impl's msg 1231 autocommit handoff note).
- **Verify 8/8 ✓**: single overload, sweep partial idx present, 6 DROPs gone, 15 ADDs present, simulate-admin unscheduled, 8 crons at 1/min, `max_connections=60`.
- **Surgical reset done** — selective cascade (preserved triggers + 50k working set). State now matches msg-1220 baseline exactly: `ts_deposits=61,495`, `bank_statements=50,080`, `mock_merchant_events=61,496`, banks_with_nonzero_daily=0.

**BLOCKED — escalation, priority=high:**
- **Smoke failed.** Worker returned 500 on signed-good (1+2) AND on bad-HMAC (3). `wrangler tail` caught the exception: `"Error: KV put() limit exceeded for the day."`
- **Today's UTC KV writes on `CLIENT_CACHE` = 28,698**; CF Workers Free-plan cap = **1,000/day per namespace**. Cap crossed at minute 09:34 UTC (≈2 min into next-impl's §D run).
- **Recontextualizes msg 1228 attribution.** Some chunk of next-impl's 6.85% 5xx at sustained-30 (msg 1225) is **Worker-side KV exhaustion**, not pure Supabase. CF Analytics counted these as `status=success` because Hono's default error handler returns a 500 response (no uncaught script-level throw), masking the issue in my earlier pull.
- **Spec §3.2 says rate-limit must be fail-open.** The current Worker `rateLimitHit` does NOT catch KV.put failures — violates the spec contract; only matters when the cap is hit (now).

**3 options for user:**
- **(a)** Upgrade CF to **Workers Paid** ($5/mo) → 1M KV writes/day cap. ~5 min user action, restores clean attribution.
- **(b)** next-impl/gateway-impl push **fail-open KV.put patch** for `rateLimitHit` (per spec §3.2). ~10 min PR + ~5 min brew-ops re-deploy. Spec-correct, but rate-limit becomes effectively disabled past 1k writes/day → capacity numbers under-represent prod-target RL cost.
- **(c)** Wait for UTC midnight (= 2026-05-29 07:00 GMT+7) for cap reset. ~7h20min. Same exhaustion next run unless (a) or (b) also done.
- **Recommendation: (a) + (b)** together. The substrate-hygiene delta needs clean Worker attribution; the Worker can't contribute 5xx of its own.

**New durable follow-ups (add to msg-1220 carry list):**
- `supabase db push` blocks CONCURRENTLY (CLI pipeline issue) → use psql `-f` + manual schema_migrations insert.
- CF Workers Free-plan KV-write cap (1k/day per namespace) is the operational ceiling for the PoC. Switching to CF Rate Limiting binding (spec §4 production target) would also remove this constraint.

Awaiting (a)/(b)/(c) pick before §D re-run dispatch.
