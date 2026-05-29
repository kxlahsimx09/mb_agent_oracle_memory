---
title: ## CF GraphQL Analytics — usable field set for Worker/KV/Hyperdrive attribution 
tags: [brew-ops, cf-gateway, cloudflare, analytics, graphql, observability, attribution, recipe, thread-254]
created: 2026-05-28
source: brew-ops Analytics pull, thread #254 msg 1228, 2026-05-28 GMT+7
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# ## CF GraphQL Analytics — usable field set for Worker/KV/Hyperdrive attribution 

## CF GraphQL Analytics — usable field set for Worker/KV/Hyperdrive attribution (and what it can't tell you)

Pulled the gateway-in-front feasibility run window (thread #254 msg 1228). Distilled field map for the next attribution pull:

**Endpoint:** `POST https://api.cloudflare.com/client/v4/graphql`
**Auth:** any Worker-scoped token with Account-Analytics:Read (the existing `~/.arra-oracle-v2/fleet-secrets/mb-next-loadtest/cloudflare.env` token works).
**Schema introspection:** disabled (`__type` returns null). Probe by trial, save the recipes below.

### `workersInvocationsAdaptive` — Worker timing + status
- `sum { requests, subrequests, errors }` ✓
- `quantiles { cpuTimeP50, cpuTimeP95, cpuTimeP99 }` — Worker CPU only, **microseconds**.
- `quantiles { wallTimeP50, wallTimeP95, wallTimeP99 }` — **microseconds** (Worker total incl. subrequest wait — matches the driver-side e2e p99 to within network RTT).
- `quantiles { durationP50 ... durationP99 }` — seconds, billable duration (NOT the same as wall-time). Avoid for latency reasoning.
- `quantiles { responseBodySizeP50 }` — bytes.
- `dimensions { datetimeMinute, status, scriptName }` — only `success` shows up if the Worker itself never throws; the `status` here is the **Worker outcome**, NOT the HTTP response status code. 5xx the Worker proxies through are still `status=success`.

### `kvOperationsAdaptiveGroups` — KV
- `sum { requests }` ✓
- `dimensions { actionType, namespaceId }` — `actionType ∈ {read, write}`. `namespaceTitle` doesn't exist; use `namespaceId`.
- Latency / HIT-MISS NOT directly exposed. Infer KV HIT rate as `1 − (hyperdrive_count / cache_lookup_requests)` when the Worker's design is cache-then-Hyperdrive.

### `hyperdriveQueriesAdaptiveGroups` — Hyperdrive
- `count` ✓ — only useful aggregate exposed.
- `sum { ... }` / `quantiles { ... }` / `dimensions { ... }` — **none** of the latency-ish field names accepted (probed: `queryBatchResponseTime[Ms]`, `queryDuration[Ms]`, `latencyMs[P50|P99]`, `connectionTime[Ms|P99]`, `numQueries`, `rowsReturned`, `eventCount`, `events`, `bytesIngested` — all rejected as "unknown field"). For Hyperdrive timing you'd need wrangler tail or external instrumentation.

### What's NOT in the API
- **Subrequest-level p99** as its own field. No dataset by these names: `workersFetchSubrequestsAdaptive`, `workerToOriginRequestsAdaptive`, `workersOutboundSubrequestsAdaptive`, `workersSubrequestsAdaptive`, `workersOutboundFetchAdaptive`. Subrequest latency must be computed as `wallTimeP99 − cpuTimeP99 − tiny_kv_overhead`.
- HTTP response status code dimension on Worker invocations (Worker `status` = outcome, not HTTP code).
- Rate Limiting binding dataset (probed: `rateLimitingRulesAdaptiveGroups`, `workersBindingsAdaptiveGroups` — both don't exist by those names; the PoC's KV-counter rate-limit shows up in `kvOperationsAdaptiveGroups` as writes).

### Pitfall: `orderBy` arg
- `orderBy: [count_DESC]` is rejected (`unknown enum value count_DESC`).
- Working forms: `orderBy: [datetimeMinute_ASC]`, `orderBy: [sum_requests_DESC]`.

### Attribution recipe used (thread #254 msg 1228)
```
worker_cpu_p99 = cpuTimeP99 / 1000          # ms
worker_wall_p99 = wallTimeP99 / 1000        # ms (≈ driver e2e p99 minus network RTT)
subrequest_p99 ≈ wall_p99 − cpu_p99 − ~5ms  # the dominant non-CPU wait — fetch to origin
kv_hit_rate ≈ 1 − (hyperdrive_count / client_lookup_count)
```
Match the wall_p99 vs driver_p99 — agreement within network RTT validates the substitution.

**Tags:** #brew-ops #cf-gateway #cloudflare #analytics #observability #attribution #recipe #thread-254 #next #repo:mb-next-payment-gateway

---
*Added via Oracle Learn*
