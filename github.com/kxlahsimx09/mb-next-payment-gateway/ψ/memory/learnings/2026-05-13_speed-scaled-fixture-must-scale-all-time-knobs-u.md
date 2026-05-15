---
title: **SPEED-scaled fixture must scale ALL time knobs uniformly — partial scaling bre
tags: [speed-scaling, fixture-design, poc-substrate, race-conditions, load-test-tunability]
created: 2026-05-13
source: PoC Phase B sprint 2026-05-13
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# **SPEED-scaled fixture must scale ALL time knobs uniformly — partial scaling bre

**SPEED-scaled fixture must scale ALL time knobs uniformly — partial scaling breaks A3LATE/race semantics.**

PoC mb-next-payment-gateway's `poc/integration/` runs a 60-min fixture timeline against hosted Supabase. SPEED env (e.g. "60x") collapses sim-time to wall-clock-seconds. Three time knobs control behavior:

1. `schedule_offset_ms` — when fixture-loader POSTs deposit/payout (relative to fixture start)
2. `real_lag_ms` — when bot pushes statement (relative to deposit POST)
3. `expires_in_seconds` — when deposit auto-expires (post create_deposit)

**Initial impl scaled only #1.** Real-world rationale: race-guard window is wall-clock physics; bot lag should reflect real timing. But at SPEED=60x:
- A3LATE has expires=30s real, lag=90s real → statement arrives at +90s but deposit expired at +30s (correct semantic)
- BUT quiescence check passes at ~25s real (everything terminal) BEFORE bot pushes A3LATE → assertion fails
- RACE seed has lag=500-2000ms real, but at 60x deposit POST itself takes ~400ms → statement may arrive BEFORE deposit lands server-side → cascade returns "no_match" instead of Step 1 match

**Symptom space:** A3LATE Step 2b fails to fire, race seed lost to "no_match", cluster timing broken.

**Fix (PR #92 2026-05-13):** scale ALL three uniformly at fixture-loader:
```ts
// Both delays divided by SPEED so high-SPEED runs don't outpace bot pushes
const realAvailableMs = t0Bulk + (e.schedule_offset_ms + e.real_lag_ms) / SPEED;
// expires_in also scaled (floor 1s) — A3LATE expired-then-late-statement holds at any SPEED
expires_in_seconds: Math.max(1, Math.round(d.expires_in_seconds / SPEED)),
```

**Trade-off accepted:** the "wall-clock physics" intuition was wrong for PoC. Fixture timeline is a logical timeline; SPEED just compresses the whole simulation uniformly. Real-world race-guard windows still hold because the gap between deposit POST and statement arrive scales together.

**Result:** smoke wall-clock 6m17s (SPEED=10x) → 1m22s (SPEED=60x) with same 51/51 assertion coverage. Tunable.

**How to apply:** when adding new time-based fixture knobs to a SPEED-scaled simulation, scale them by SPEED unless they represent fixed-cost infrastructure (e.g., HTTP RPC roundtrip latency). If unsure, error on the side of scaling — partial-scaling bugs are sneaky and only surface at high SPEED.

---
*Added via Oracle Learn*
