---
title: **CF Workers KV — per-key write throttle is 1 write/second/key** (separate from 
tags: [cloudflare, workers, kv, rate-limit, per-key-throttle, cf-gateway, rl-binding, wrangler-tail, production-design, campaign-254, perf-attribution, load-bearing, repo:mb-next-payment-gateway, next]
created: 2026-05-29
source: campaign #254 / §D re-run 2026-05-29; wt-17 wrangler tail analysis msg 1258; reconciliation w/ wt-19 msg 1256
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# **CF Workers KV — per-key write throttle is 1 write/second/key** (separate from 

**CF Workers KV — per-key write throttle is 1 write/second/key** (separate from the daily cap). Root cause of the cf-gateway-216 5xx storm and the operational ceiling for ANY KV-counter rate-limiter at scale.

EVIDENCE (campaign #254, 2026-05-28/29): `wrangler tail` over the §D feasibility re-run window (sustained-30 + Phase-B ramp through 90 dep/s, 5 clients, ~3 keys/scope) captured **7,767 `rate_limit_kv_put_fail_open` events, 100% with body `KV PUT failed: 429 Too Many Requests`** against per-minute counter keys `rl:<client>:deposit:m:<bucket>`.

ROOT CAUSE: at 30–90 dep/s × 5 clients each writing per-minute counter keys, per-key write rate exceeds CF KV's 1-write/sec-per-key throttle → 429 on every increment. The Paid daily cap is irrelevant here (this run used only ~3% of 1M/day).

CONSEQUENCES:
1. **A KV-counter rate-limiter does NOT enforce at production RPS.** Every counter increment fails-open; the rate limit is effectively bypassed.
2. **Retroactive reframe of cf-gateway-216** (the first hosted §D run): the 6.85% sustained-30 5xx and the ramp-shed-at-30 collapse were **the KV-PUT-429 cascade**, NOT Supabase DB shedding as the CF Analytics msg-1228 attribution suggested. The DB/EF could handle the load all along; the Worker layer was masking its own errors as 500s, which Hono returned cleanly so CF Analytics counted them as `status=success`.
3. **Production-design requirement:** any rate-limit-at-scale claim MUST use the **CF Workers Rate Limiting binding** (spec §4 of `docs/design/client-api-gateway/README.md` — already named as production target; this finding makes it load-bearing not optional). KV counters work for low-volume, fail silently for high-volume.

DETECTION RECIPE for any future "is my Worker fine?" attribution question: pull `wrangler tail` for the run window, grep for `fail_open` / `429` / `KV PUT failed` patterns. CF Analytics `workersInvocationsAdaptive` will NOT show these (Hono returns 500 cleanly → `status=success`).

---
*Added via Oracle Learn*
