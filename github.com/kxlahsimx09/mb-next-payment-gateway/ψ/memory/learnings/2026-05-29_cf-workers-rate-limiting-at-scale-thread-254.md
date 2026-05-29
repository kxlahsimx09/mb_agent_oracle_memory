---
title: CF Workers rate-limiting at scale (thread #254) — KV-counter rate-limiters FAIL-
tags: [implementation-architect, repo:mb-next-payment-gateway, next, cf-gateway, rate-limit, client-api-gateway, gotcha, decision, cloudflare-workers, thread-254, poc]
created: 2026-05-29
source: gateway/cf-worker/src/index.ts@55218fd + PR #279
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# CF Workers rate-limiting at scale (thread #254) — KV-counter rate-limiters FAIL-

CF Workers rate-limiting at scale (thread #254) — KV-counter rate-limiters FAIL-OPEN under load; use the CF Rate Limiting binding. Plus two binding constraints that shape the design.

Context: the gateway PoC (§ADR-2 §Amendment 2026-05-28, client-API CF Worker in front of Supabase EFs) first implemented per-client rate-limiting as a KV counter: `KV.get(rl:<client>:<scope>:m:<minute>)` → increment → `KV.put`. Under the §D load run (30-90 dep/s across 5 clients) `wrangler tail` showed **7,767 `rate_limit_kv_put_fail_open` events, 100% `KV PUT failed: 429 Too Many Requests`**. 

Root cause: **CF Workers KV enforces a ~1-write/sec-per-KEY throttle.** A per-minute counter key for one client is written on EVERY request → at >1 req/s/client the PUT 429s → the spec-§3.2 fail-open path allows the request → the rate limiter never actually enforces. The KV-counter substrate is fundamentally unsuited to high-RPS rate-limiting (the hot key is the bottleneck). This ALSO retroactively explained an earlier 6.85% sustained-30 5xx storm (before the fail-open patch, those KV-PUT 429s propagated as Hono 500s — NOT DB shedding; the DB/EF handled the load fine).

Fix (PR #279): migrate to the **CF Workers Rate Limiting binding** (`[[unsafe.bindings]] type="ratelimit"`, `.limit({key})` → `{success}`). It increments atomically edge-side with NO per-key write throttle. Key by `<client_id>:<scope>` for independent per-client+per-scope counters.

TWO BINDING CONSTRAINTS that shape any design using it:
1. **`period` accepts only 10 or 60 seconds.** A day/hour budget window is NOT expressible → needs a separate budget-accounting substrate (Durable Object counter, or a DB rollup). For the gateway PoC the minute window is the real-time enforcement gate; the day cap was deferred.
2. **`simple.limit` is STATIC per namespace** (cannot vary per request). So per-client *variable* caps (e.g. a jsonb `rate_limit_overrides` column) can't be honored by one binding — you need either one namespace per cap-tier, or a Durable Object. The PoC enforces the system-default tier per client and logs when a client's resolved cap differs from the binding default (`rate_limit_override_not_binding_enforced`).

VERIFY GOTCHA (useful): the CF Rate Limiting binding **IS emulated + enforced in `wrangler dev` local** (workerd), even though `wrangler dev` prints it as `Unsafe Metadata → remote` in the bindings table. A low-cap `[env.verify]` (limit=5/period=60) makes 429-above-cap, per-client independence, and (via an env that omits the binding) the fail-open path all locally verifiable in seconds. Don't assume "remote"-labelled = not-locally-testable.

Meta (process): this was caught by a parallel sibling session (wt-17) running `wrangler tail` while wt-19 (me) reported "fail-open dormant / KV had headroom" from driver-side data alone — wt-17's Worker-side evidence corrected the misread before it shipped into the production-design conclusion. P-004 (code/evidence is truth) + multi-observer reconciliation caught what a single driver-side observer missed.

Evidence: PR #279; gateway/cf-worker/src/index.ts rateLimitHit + scripts/verify-rl.sh. Supersedes the KV-counter approach in the same file.

---
*Added via Oracle Learn*
