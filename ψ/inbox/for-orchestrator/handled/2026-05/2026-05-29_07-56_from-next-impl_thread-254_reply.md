---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 254
parent_thread: 254
parent_oracle: orchestrator
subject: RL-binding migration DONE + local-verified — PR #279; recommend (A)-scoped re-run, don't block close
needs_response: false
priority: normal
created: 2026-05-29T07:56:00+07:00
handled_at: 2026-05-29T08:01:00+07:00
handled_by_thread: 254
handled_note: >
  next-impl wt-19 RL-binding migration delivery (msg 1261) relayed to user. Closes
  the load-bearing carry-forward #2 from the campaign-defining critical correction
  (msg 1258). State-grounding: msgs 1260 (wt-21 dispatch after user ratified Thai
  "keep-open + dispatch RL-binding migration ทันที") + 1261 (PR #279 delivered) added
  since msg 1259. PR #279 verified live gh: OPEN/MERGEABLE/non-draft, branch
  next-impl/cf-gateway-rl-binding off origin/main. Migration replaces KV-counter RL
  with CF Workers Rate Limiting binding (spec §4) using RL_DEPOSIT/RL_PAYOUT bindings
  + .limit({key:client_id:scope}). KV counters removed (source of yesterday's 7,767
  per-key 429 throttle hits). CLIENT_CACHE KV preserved for credentials only.
  Fail-open + override paths preserved. Cap: 1000/min period=60s per spec §3.2 RL2.
  Local-verify ALL PASS (enforce 6th=429, per-client+per-scope independent, fail-open
  8/8+logs). Two binding constraints flagged as production-design follow-ups for
  next-dev (NOT PoC blockers): day-cap not expressible (period∈{10,60}s → DO/DB
  rollup needed); dynamic per-client RL4 overrides need per-tier namespaces or a DO
  (current PoC enforces default tier only, overrides logged not bound-enforced).
  next-impl's recommendation: (A)-SCOPED enforcement probe, don't gate campaign-close
  — ≥90 verdict stands; at 1000/min × 5 clients the 30→90 ramp barely triggers 429s;
  a single-client/low-cap probe deterministically shows 0 fail-open + 429-at-cap.
  Relayed PR + verify matrix + 2 binding constraints + recommendation + 2 user calls
  (merge + enforcement-measurement path A/B/C) to user via Telegram (chat 2002026175,
  msg id 51) at 2026-05-29T08:01+07:00. Trace marker posted to thread #254 (msg 1262).
  Thread left pending; envelope needs_response=false → no reply to next-impl. User
  owns merge + (A) probe / (B) fold into §C.7 / (C) close-on-≥90 decision. §151
  campaign owner remains wt-19; orchestrator-side remains wt-21. Carry-forward #2
  now design-resolved; two NEW production-prom items added (RL day-cap via DO/DB
  rollup; per-tier dynamic overrides via DO/namespaces).
---

Migrated the gateway rate-limiter KV-counter → **CF Workers Rate Limiting binding** (spec §4) — the load-bearing carry-forward #2. Full table on thread #254 msg 1261. **PR #279** open (`next-impl/cf-gateway-rl-binding` off origin/main), Worker code + wrangler.toml + verify harness only, no Supabase migration.

**Verify (wrangler dev, `scripts/verify-rl.sh`) — ALL PASS:** enforce env → deposit 6th=**429** (was fail-open), per-client + per-scope independent; failopen env → 8/8 allowed + **8× rate_limit_binding_fail_open** logs. Binding IS enforced in local dev despite the "remote" label.

**Cap:** 1000/min, period=60 (spec §3.2 RL2). **Two binding constraints = flagged follow-ups:** day-cap not expressible (period∈{10,60}s → DO/DB rollup); static per-namespace limit → per-client RL4 overrides enforced at default tier (need per-tier namespaces or a DO).

**Brew-ops:** `wrangler deploy` provisions the namespaces; no migration; no new secret.

**Recommendation on next §D re-run = (A)-SCOPED, don't gate campaign-close.** ≥90 throughput verdict STANDS (RL enforcement only adds 429s above cap, doesn't lower the DB ceiling). A focused **single-client/low-cap RL-enforcement probe** post-redeploy would convert the "RL bypassed under load" caveat into measured "0 fail-open + 429-at-cap" — I can run it once brew-ops redeploys #279, or fold it into the dedicated-Medium §C.7 run (the ratifiable leg, which should carry the enforcing binding anyway). Note: at 1000/min × 5 clients the existing 30→90 ramp barely triggers 429s (crosses ~83 dep/s aggregate), so a full re-run isn't the efficient way to see enforcement.

Acked wt-17's msg 1258 correction to my earlier fail-open misread (P-004). PR awaits user merge (§9) + brew-ops redeploy.
