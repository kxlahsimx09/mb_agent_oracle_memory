---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 254
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-21-20260526-150518
subject: migrate rate-limiter KV-counter → CF Workers Rate Limiting binding (spec §4) — load-bearing carry-forward #2
context: see thread #254 msg 1260. User ratified: keep-open + dispatch RL-binding migration (load-bearing carry-forward #2, escalated from optional → required after msg 1258 wt-17 wrangler tail evidence: 7,767 rate_limit_kv_put_fail_open events on per-key 1-write/sec throttle). Scope: add CF Rate Limiting binding(s) to gateway/cf-worker/wrangler.toml (deposit/payout scopes, capacity per spec §3.2 RL2 + GW_RL_DEFAULTS env tunable, rate_limit_overrides override per §ADR-11-A3 RL4); rewrite rate-limit.ts to use binding.limit() w/ same fail-open semantic (spec §3.2/§GW7) — wrap in try/catch, log rate_limit_binding_fail_open on infra error, return {allowed:true}; keep CLIENT_CACHE KV unchanged (only RL substrate moves); local-verify wrangler dev — 429 above cap + fail-open on disabled binding + per-client independent limits. Cross-lane authorized for THIS PoC (next-dev promotion later, P-001). Branch off main → PR (Worker code + wrangler.toml only, no Supabase migration). Reply with PR + cap config + verify result + recommendation on whether to re-run §D for actual-RL-enforcement measurement vs close campaign on current ≥90 verdict with documented RL-substrate caveat.
needs_response: true
priority: normal
created: 2026-05-29T05:50:00+07:00
---

Full brief in thread #254 (msg 1260). Migrate RL substrate KV-counter → CF Workers Rate Limiting binding per spec §4 (the production-target substrate, now empirically required after the per-key throttle finding). Local-verify + readiness for brew-ops redeploy. Recommend on whether the next §D re-run is meaningful (measure actual RL enforcement) or campaign closes on ≥90 verdict with RL-substrate caveat documented.

<!-- handled_at: 2026-05-29T07:56:00+07:00 -->
<!-- handled_by_thread: 254 (reply msg 1261) -->
<!-- handled_by_inbox: for-orchestrator/2026-05-29_07-56_from-next-impl_thread-254_reply.md -->
