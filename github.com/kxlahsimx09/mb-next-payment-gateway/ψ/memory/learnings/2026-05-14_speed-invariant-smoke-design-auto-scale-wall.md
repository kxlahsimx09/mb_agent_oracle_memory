---
title: 
tags: [speed-scaling, smoke-test, wall-clock-budgets, auto-tune, production-replay]
created: 2026-05-14
source: next-impl session 2026-05-13/14 retro
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# 


# SPEED-invariant smoke design — auto-scale wall-clock budgets from SPEED

PoC integration smoke supports `SPEED` env (1x = production-realtime, 60x = fast iteration). All fixture-time offsets and TTLs scale uniformly at the loader boundary; cascade engine is wall-clock-naive (works on row state). BUT three categories of wall-clock budgets must also auto-scale or smoke breaks at non-default SPEED:

## 1. Quiescence wait (orchestrator)
QUIESCE_AFTER_LOADER_MS auto-derives from longest fixture-time TTL:
  `QUIESCE_MS = max(120s, (MAX_FIXTURE_TTL_SECONDS / SPEED) + 60s_buffer)`
At SPEED=60x with TTL=900 fixture-sec → 15s + 60s = 75s (floored to 120s).
At SPEED=1x  with TTL=900 fixture-sec → 900s + 60s = 16 min.

## 2. Bot auto-exit idle (subprocess)
BOT_AUTO_EXIT_AFTER_IDLE_MS scales with `FIXTURE_DURATION_MS`:
  `BOT_AUTO_EXIT = max(120s, FIXTURE_DURATION_MS + 60s_buffer)`
At SPEED=1x deposits arrive minutes apart via poisson; a 2-min wall idle window kills bot mid-loader.

## 3. Fixture event spread (fixture-gen)
Hardcoded fixture offsets must scale with durationMs. RACE-TEMPORAL was bitten:
  `schedule_offset_ms: 900_000` → 15s wall at SPEED=60x, 15 min wall at SPEED=1x. With FIXTURE_DURATION_MIN=2 (loader 2 wall-min), the deposit POST landed AFTER loader exit.
  Fix: `schedule_offset_ms: Math.round(durationMs * 0.25) + jitter`.

## Anti-pattern surfaced
**Subprocess env hardcoded override**. `run-hosted.ts:248` set `FIXTURE_DURATION_MIN: "60"` in the fixture-gen subprocess env, silently overriding user's env. Caller couldn't make SPEED=1x finish quickly because the hardcode ignored their FIXTURE_DURATION_MIN=2.
Lesson: prefer `...process.env` first; never re-set what's already in process.env.

## Verification matrix
After auto-scale: 63/63 PASS at SPEED=1x / 10x / 60x with IDENTICAL totals (deposits_paid=8, expired=8, rejected=2, matched=7, review=2, unmatched_with_xref=3). Logical outcomes are SPEED-invariant; only wall-clock duration differs.


---
*Added via Oracle Learn*
