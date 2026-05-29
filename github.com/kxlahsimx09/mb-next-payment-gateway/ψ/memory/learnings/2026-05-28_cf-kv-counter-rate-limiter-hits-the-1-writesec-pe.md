---
title: CF KV-counter rate-limiter hits the 1-write/sec-per-key throttle (HTTP 429) unde
tags: [implementation-architect, repo:mb-next-payment-gateway, next, decision, gotcha, load-test, cf-gateway, rate-limit, cloudflare-kv, fail-open, thread-254, poc]
created: 2026-05-28
source: thread #254 §D re-run 2026-05-29; wrangler tail evidence poc/integration/evidence/cf-gateway-254-rerun/
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# CF KV-counter rate-limiter hits the 1-write/sec-per-key throttle (HTTP 429) unde

CF KV-counter rate-limiter hits the 1-write/sec-per-key throttle (HTTP 429) under production RPS — fail-open absorbs it → rate-limiting silently stops enforcing. Empirical, thread #254 §D re-run (CF Worker gateway in front of Supabase EFs), captured via `wrangler tail`.

EVIDENCE: at 30–90 dep/s across 5 seeded clients, the Worker logged **7,767 `rate_limit_kv_put_fail_open` events, 100% `KV PUT failed: 429 Too Many Requests`** on the rate-limit counter keys `rl:<client>:deposit:m:<minute-bucket>` (and `:d:<day>`). 0 GET-side fail-opens. The 429 is CF KV's documented **1 write/sec to the same key** limit — NOT the Workers-Paid daily cap (only ~3% of 1M used). Each client's per-minute counter key is written on every allowed request → many writes/sec/key → 429.

KEY INFERENCE TRAP: driver-side saw 0 5xx, which a session WITHOUT a Worker-side tail mis-read as "Paid KV had headroom, §3.2 fail-open patch never exercised." The opposite is true — the patch (PR #277, wrap KV.get/.put in try/catch, return {allowed:true} on infra error) fired on ~every counter write and absorbed the 429s. Absence of 5xx is the patch WORKING, not KV being healthy. Always confirm fail-open with Worker-side `wrangler tail`, never infer from driver-side 5xx absence.

CONSEQUENCE FOR DESIGN: this reframes the prior cf-gateway-216 run — its 6.85% sustained-30 5xx was these same KV-PUT 429s propagating as 500s (pre-patch), NOT the DB shedding; the DB/EF handled the load all along. AND the recovered ceiling (X_faithful ≥90 dep/s, 5xx 0) is achieved with RL EFFECTIVELY BYPASSED under load (fail-open on every throttled write). A KV-counter rate-limiter is therefore not viable at production RPS for low-cardinality client keys. Production target must use the **CF Rate Limiting binding (spec §4)** for real enforcement at scale — escalates the prior "nice-to-have" follow-up to required-for-any-RL-at-scale claim.

Two perf levers must not be conflated: substrate hygiene (PR #276) cut latency ~50% (sustained-30 p99 5753→2872); the fail-open patch (PR #277) eliminated the 5xx storm. The A/B vs cf-gateway-216 isolates them; cross-comparison to raw-EF Micro conflates gateway-hop cost with hygiene gain.

---
*Added via Oracle Learn*
