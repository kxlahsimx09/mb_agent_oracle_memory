---
title: Pause/resume in distributed-time test systems — architectural limitation
tags: [poc-implement, pause-resume, distributed-time, clock-skew, architectural-limitation, virtual-clock, admin-web, session-2026-05-12-to-13]
created: 2026-05-13
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Pause/resume in distributed-time test systems — architectural limitation

Pause/resume in distributed-time test systems — architectural limitation

Built + removed pause/resume capability in admin-web (PR #79 follow-on commits). Worked at loader+bot layer via virtual-clock + isPaused gate; BROKE invariants because 3rd time layer (server clock + pg_cron) couldn't be paused.

# What was built

Frontend: Pause/Resume button in RunProgress + supabase.from("test_run").update({paused, paused_at, paused_accum_ms}). Subscribed to test_run via Realtime to react to state changes.

Loader (poc/integration/src/fixture-loader.ts): Refactored from setTimeout-based dispatch to virtual-clock pattern. setInterval(100ms) advances virtual_time by (delta × SPEED) only when not paused. Events fire when their fixture-timeline offset <= virtual_time. Polls test_run.paused via REST every 1s, caches.

Bot-sim (poc/integration/src/bot-simulator/main-hosted.ts): Added isPaused() check at start of each tick. SELECT test_run.paused via Supabase client; skip tick if paused.

# Why it broke the cluster (Q4c) test

User paused 56s mid-fixture during SPEED=5x run. Observed:
- Loader virtual-clock froze ✓ (no new deposit POSTs)
- Bot-sim skipped scans ✓ (no new stmt pushes)
- BUT pg_cron `sweep_expired_deposits` ran every 1m server-side regardless
- During 56s pause, cluster deposits (expires_in_seconds=60) reached expires_at <= now() → flipped to status='expired'
- After resume, bot pushed 5 cluster stmts → cascade Step 1 found 0 pending → fell through to Step 2b → linked to expired deposits via terminal cross-reference
- Result: bank_statements_review_required=0 (expected 5), bank_statements_matched=14 (expected 9). 2/53 assertions failed. paused_accum_ms=56110 confirmed pause executed.

# Architectural truth

Time layers in distributed system:
1. Client-side schedule (loader virtual-clock, bot-sim tick) — pause-aware
2. Wire/network latency — independent
3. Server-side execution time (RPC duration) — independent
4. Database wall-clock (now(), expires_at evaluation) — independent
5. Pg_cron tick (1m fixed, Supabase-managed) — independent

Pause hits only layer 1. Layers 2-5 cannot be paused without server-side state mutation. Compensating layer 4 (UPDATE expires_at += pause_duration) is possible but increases test fragility, requires resume to be a transaction. Layer 5 (cron) cannot be paused at all.

# Decision

Removed pause feature entirely. Reverted:
- Frontend: Pause/Resume button removed; RunProgress now displays progress only
- Bot-sim: isPaused() removed; tick reverted to direct dispatch
- Loader: virtual-clock reverted to setTimeout pattern (original)
- run-hosted.ts: KEEP test_run INSERT + phase UPDATE (useful for progress bar)
- Migration test_run table: KEEP (paused/paused_accum_ms fields unused; not migrated out to preserve schema compatibility)

# Pattern learnings

1. When considering pause in time-sensitive systems, identify ALL time layers up front. If any layer cannot be paused, document the inconsistency.
2. Virtual-clock pattern is GOOD for speed-scaling (replaces fragile setTimeout) but NOT sufficient for pause unless complementary server-side time compensation.
3. Server-managed cron (pg_cron in Supabase, etc) is opaque — cannot be paused/throttled from client. Plan invariants accordingly.
4. Pause/resume in dev observation contexts (read state) is different from pause/resume as test preservation (correct invariants). PoC needed the latter; only the former was achievable.

# Alternative architecture if pause was load-bearing

(a) Pre-INSERT mock_bank_feed.available_at as VIRTUAL fixture-timestamps, not real wall-clock. Bot scan uses test_run.virtual_now (computed in DB from started_at + accumulated tick × speed - paused_accum_ms). Requires bot to UPDATE virtual_now periodically OR DB-side function to compute.
(b) Don't pre-INSERT mock_bank_feed — emit each row in real-time as loader fires its event. Production-realistic (bank feed appears live). Biggest refactor.
(c) On pause: UPDATE all pending ts_deposits SET expires_at = expires_at + EXTRACT(EPOCH FROM (now() - paused_at)). Fragile (race during pause-update). Doesn't help callback retry attempts or other pg_cron-driven state.

None of these were worth the complexity for a dev observation tool.

# Outcome

Pause feature removed cleanly. Test reproducibility restored. Lesson preserved.

---
*Added via Oracle Learn*
