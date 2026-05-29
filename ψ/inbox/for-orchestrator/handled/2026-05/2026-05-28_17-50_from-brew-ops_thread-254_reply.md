---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 254
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-21-20260526-150518
subject: CF Workers Analytics — Supabase confirmed (Worker = 0.15% of e2e p99; EF+PG = ~99.5%)
needs_response: false
priority: normal
created: 2026-05-28T17:50:00+07:00
handled_at: 2026-05-28T17:09:00+07:00
handled_by_thread: 254
handled_note: >
  brew-ops CF Workers Analytics result (msg 1228) relayed to user — answers their Thai
  verification question "ชัวร์ใช่ไหมว่าเป็นที่ Supabase ไม่ใช่ Cloudflare?" (msg 1227
  prompted wt-21's dispatch). Verdict: Supabase confirmed. Hard attribution at
  sustained-30 (driver e2e p99 = 5753 ms): Worker CPU p99 = 8.8 ms (0.15%), Worker→EF
  subrequest ≈5723 ms (≈99.5%). Worker errors=0 across 14,691 invocations. KV HIT
  rate ≈98.7%. The 6.85% 5xx the driver saw = EF-origin 500s the Worker faithfully
  proxied (CF Analytics classes as status=success because Worker itself ran fine).
  No CF-side material to investigate. Corroborates option (a) Medium leg from msg 1226
  verdict. Relayed to user via Telegram (chat 2002026175, msg id 42) at
  2026-05-28T17:09+07:00. Trace marker posted to thread #254 (msg 1229). Thread left
  pending; user's (a)/(b)/(c) call still stands. envelope type=notify needs_response=false
  → nothing to answer brew-ops. §151 owner remains wt-21. Note: envelope created
  timestamp 17:50 is forward-dated relative to handled_at 17:09 — brew-ops appears to
  use a slightly skewed clock or wrote ahead; non-blocking.
---

Verdict in thread #254 msg 1228. Headlines for relay:

- **Worker CPU p99 = 8.8 ms** (out of **wall p99 = 5,737 ms**) — Worker contribution to driver e2e p99 (5,753 ms) is **0.15%**.
- **Worker→EF subrequest p99 ≈ 5,723 ms** (= wall − cpu − tiny KV I/O) — **99.5% of e2e p99 is downstream of the Worker (= Supabase EF + PG)**.
- **Worker errors = 0** across all 14,691 invocations (zero scriptThrew / exceededCpu / canceled). The 6.85% 5xx the driver saw at sustained-30 is **EF-origin 500s the Worker proxied through** — CF Analytics still classes those as `status=success` because the Worker itself ran fine.
- **KV HIT rate ≈ 98.7%** on the client cache (150 Hyperdrive queries against 11,990 deposit/payout-create requests). KV is healthy; Hyperdrive is healthy.
- **No CF-side material to investigate.** Worker + KV + Hyperdrive all in their healthy range.

**Verdict: Supabase confirmed.** The Micro shared-burstable substrate IS the bottleneck. Medium dedicated compute (next-impl msg 1225 option (a)) is the right next leg.

Observability only — no deploy, no spend, ~5 min, ~10 GraphQL calls.

Carry-forward updates (no new infra follow-ups; the 4 from msg 1220 still stand):
1. `client.role` absent on prod substrate — unchanged.
2. PoC rate-limit uses KV counters; CF Rate Limiting binding **confirmed not used** in this run (analytics shows zero RL binding traffic) — consistent with msg 1217 follow-up #2. Production target = native RL binding per spec §4.
3. `wrangler.toml` truncated IDs fix still local to deploy worktree — optional small PR.
4. Wrangler/Supabase secret-push-via-stdin gotcha — captured as a learning.

Awaiting next-leg decision (Medium leg / feeder route fix first / close).
