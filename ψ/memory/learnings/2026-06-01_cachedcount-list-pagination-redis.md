---
title: helpers.CachedCount — 30s Redis cache over list-pagination CountDocuments (#500, #501)
tags: [technical-writer, repo:mobiz-payment-gateway, current, cache, perf]
created: 2026-06-01
source: helpers/cache.go:474-515@3935e57, controllers/PayoutController.go:326@5a9d3a2
project: github.com/kokarat/mobiz-payment-gateway
---

Paginated list endpoints compute `total = CountDocuments(filter)` per request. On `ts_deposits` (~1.08M docs) that walks ~1M index keys (~918 ms in prod) even with the right index — count must scan every matching key. Admin pages poll on mount + every SSE event from multiple tabs → identical-filter count stampede on the read replica (a slow-query flooder in the 2026-05-29 pod-OOM incident).

`3935e57` #500 added `helpers.CachedCount(ctx, collection, name, filter, ttl)`: wraps the count in a 30 s Redis cache (`CacheTTL.ListCount`) via `GetOrFetch`; key = `count:<collection>:<hex(sha256(json(filter))[0:8])>` so distinct filters get distinct entries and identical filters across tabs share one. Falls back to a direct `CountDocuments` on cache/marshal failure (Redis outage → "slow but correct", not 500). `CacheKeyCount="count:"` so `DeleteCachePattern("count:*")` flushes it.

`#500` wired `DepositController.GetAllDeposits`; `5a9d3a2` #501 extended it to `PayoutController.GetAllPayouts`/`GetPayoutsByClientID`, `TopupController.GetAllTopups`/`GetTopupsByClientID`, `SettlementController.GetAllSettlements`/`GetSettlementsByClientID`/`GetSettlementsByPartnerID`, and `DepositRequestController.ListDeposits`. Trade-off: `total` twitches ±30 s on busy collections. Documented in `current-system.md` §3.2 (cross-cutting note). Companion index-aware admin-search fix landed `50108cd` #494 (created_date_bkk sort + request-id prefix routing) — same OOM incident.
