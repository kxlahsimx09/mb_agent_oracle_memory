---
title: ## CF Workers Free-plan KV cap (1k writes/day per namespace) is the operational 
tags: [brew-ops, cf-gateway, cloudflare, kv, rate-limit, workers-free, attribution, gotcha, thread-254]
created: 2026-05-28
source: brew-ops PR #276 apply session, thread #254 msg 1241, 2026-05-28 GMT+7
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# ## CF Workers Free-plan KV cap (1k writes/day per namespace) is the operational 

## CF Workers Free-plan KV cap (1k writes/day per namespace) is the operational ceiling for any per-request KV-counter design

**Context:** CF gateway-in-front PoC (thread #254 msg 1241). Discovered while smoking PR #276 substrate hygiene. The §D feasibility run (msg 1225) had silently exhausted the cap and propagated 5xx that next-impl + msg-1228 attribution misread as Supabase-origin.

**Mechanism:** Workers Free plan = **1,000 KV writes/day per namespace**, hard rejected past the cap with: `Error: KV put() limit exceeded for the day.` (literal). On Paid plan ($5/mo, "Standard") the cap is 1M/day (effectively non-binding for PoC traffic).

**Smoking-gun in CF Analytics:** plot cumulative writes per minute over the run window; if the curve breaks 1,000 within the run, every subsequent signed request that does ≥1 `KV.put` returns 500 (assuming the code path is `await KV.put(...)` with no try/catch).

**Why the §D run masked it from CF Analytics:** the failures threw inside Hono route handlers; Hono's default `onError` returns 500 + "Internal Server Error" → from CF's POV the **Worker script completed normally** (no uncaught throw) → `workersInvocationsAdaptive.status = "success"` and `sum.errors = 0`. A later attribution pull sees zero Worker-side errors and misattributes the 500s to whatever is downstream. The `wrangler tail --format json` capture exposes the actual exception text in `logs[].message`.

**How to detect early in the next pull:**
1. Query `kvOperationsAdaptiveGroups` cumulative WRITE count for the run window. If it crosses 1,000 within the window AND the account is Workers Free → cap is implicated.
2. `wrangler tail --format json` during a smoke; grep for `"limit exceeded"`.
3. Counter-corroboration: `sum.subrequests` to EF stays high but downstream EF metrics don't match (because some 500s never made it to the EF — they 500'd at the Worker before the fetch).

**Mitigations (ranked):**
- **(a) Upgrade to Workers Paid** ($5/mo, 1M writes/day) — cleanest; restores attribution rigor.
- **(b) Fail-open the KV.put inside `rateLimitHit`** (spec §3.2 already requires fail-open; current PoC violates the contract). Code change is small but lives in gateway-impl lane. After the patch, RL becomes effectively disabled past 1k writes/day, so capacity numbers under-represent prod-target RL cost.
- **(c) Switch from KV-counter rate-limit to the actual CF Workers Rate Limiting binding** (spec §4's named production target). Doesn't count against KV writes. Bigger code change.

**The §D-run blast radius (#254 msg 1225):** every signed request makes 2 `KV.put` calls (minute-bucket + day-bucket RL counters) + an occasional positive-cache PUT on `loadClient` MISS. At 30 dep/s sustained, ~60 writes/sec → 1k cap is exhausted in ~17 sec of sustained activity. The 7.3% 5xx at 20× / 6.85% at sustained-30 in next-impl's table is at least partly KV exhaustion, not all Supabase EF/PG.

**Reusable recipe for future Worker-on-Free perf runs:**
- Budget per run: max ~500 signed requests / day if RL writes 2 keys each (1k cap / 2).
- If you need more: upgrade plan FIRST, or move RL to the binding.
- Always probe `KV.put` cap state before claiming an attribution to downstream — `wrangler tail` + cumulative-writes plot is the cheapest disambiguator.

**Tags:** #brew-ops #cf-gateway #cloudflare #kv #rate-limit #workers-free #attribution #thread-254 #next #repo:mb-next-payment-gateway

Related: [[2026-05-28_cf-graphql-analytics-usable-field-set-for-wor]] (the analytics fields used to detect this), [[2026-05-28_secret-push-via-stdin-from-shell-variable-mangl]] (sibling deploy gotcha).

---
*Added via Oracle Learn*
