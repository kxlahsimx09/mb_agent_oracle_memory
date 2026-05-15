---
title: 
tags: [per-client-config, server-derived-ttl, drift-fix, deposit-001-ac1, multi-tier-fixture-seeding]
created: 2026-05-14
source: next-impl session 2026-05-13/14 retro
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# 


# Per-client TTL config — DEPOSIT-001 AC #1 drift fix + multi-tier fixture seeding

## The drift
Spec DEPOSIT-001 AC #1: `expires_at = createdAt + the calling client's configured expiry duration` (server-derived; **request body cannot override**). PoC drift since 2026-05-10: fixture-loader sent `expires_in_seconds` per-deposit; `deposits-create` EF + `create_deposit` RPC silently accepted the body override. That removed all server-side TTL discipline.

## Where 1800 came from
The PoC default `expires_in_seconds: 1800` (30 min) was author-chosen at first integration-PoC commit (f7d3dad 2026-05-10) under "won't expire in normal happy-path" reasoning, tuned for SPEED=10x → 3-min wall TTL. NOT from spec, NOT from #current production data.

## Production reality
#current `clients.expired_deposit_time` audit (94 clients with non-null config):
  10 min × 54 clients (57.4% — median)
  15 min × 36 clients (38.3%)
  45 min ×  3 clients ( 3.2%)
   5 min ×  1 client  ( 1.1%)
Range 5-45 min. **No production client uses 30 min.** PoC default was outside production range.

## Fix (migrations 026 + 027)
- ADD COLUMN `client.expired_deposit_seconds INT NOT NULL`
- `create_deposit` RPC: read from `v_client.expired_deposit_seconds`; reject `p_expires_in_seconds IS NOT NULL` with ERRCODE 22023.
- EF `deposits-create`: HTTP 400 on body `expires_in_seconds`.

## Multi-tier client seeding (the orthogonal win)
Five PoC clients, each with a TTL appropriate for the scenarios it hosts:
- client-a (10 min) — production median (QRH / SLIPH / V1 / V1TWIN)
- client-b (15 min) — production high-end
- client-c ( 5 min) — production low-end
- client-d (30 sec) — test FAST_EXPIRE (A3LATE / EXP — stmt arrives at +90s lag must miss the pending window)
- client-e ( 3 min) — test MEDIUM_EXPIRE (RACE / CLUSTER-FA2 — must expire AFTER cascade-temporal-guard fires)

Fixture seeds pick the appropriate `client_id`:
- `pickProductionClient()` (round-robin a/b/c) → happy paths
- `CLIENT_FAST_EXPIRE` → A3LATE/EXP
- `CLIENT_MEDIUM_EXPIRE` → RACE/CLUSTER-FA2

## SPEED scaling for per-client TTL
RPC `apply_test_speed_to_client_ttl(p_speed)` re-seeds each client's `expired_deposit_seconds` from a canonical fixture-time value divided by SPEED (floored at 1s). Called by orchestrator RIGHT AFTER `reset_runtime`. Idempotent — re-callable with different SPEED.

This decouples: cascade RPC stays naive (treats value as wall-clock seconds); loader pre-scales at orchestration time using its SPEED knowledge.

## Side benefit: SPEED-invariance
With per-client TTL pre-scaled by SPEED, all fixture-time TTLs map cleanly to wall-time at any SPEED. Combined with auto-scaled QUIESCE_MS + BOT_AUTO_EXIT (separate pattern), smoke is now logically identical at SPEED=1x / 10x / 60x — only wall-clock differs.

## Anti-pattern killed
Per-deposit `expires_in_seconds` override in fixture is no longer needed — every deposit's TTL flows from per-client config. The fixture decoupling is cleaner (scenarios attach to client tiers, not opaque seconds-counts).


---
*Added via Oracle Learn*
