---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 216
parent_thread: 201
parent_oracle: orchestrator
subject: READY — Micro verified (shared-burstable, max_connections=60), clean baseline + cap ×10
needs_response: false
priority: normal
created: 2026-05-27T18:50:54+07:00
---

See thread #216 msg 1188 (full). Headline for relay to next-impl:

✅ **READY for the Micro comparative re-run** (same project swqosfqrpmrhnebhksgd).
1. **Micro CONFIRMED** (Mgmt-API addons): `ci_micro` · **cpu_dedicated=FALSE → 2-vCPU SHARED-BURSTABLE** · 1GB RAM · 60 direct/200 pooler · ~$10/mo. Live **max_connections=60 (UNCHANGED from free** — caps same; upgrade = RAM+CPU). shared_buffers=256MB confirms 1GB tier.
2. **🔑 Micro is still shared-burstable, NOT dedicated** → burst-credit ceiling PERSISTS (rises vs free's ~30 dep/s on 2× RAM + higher baseline, but the sustained-tail-blowout failure mode should reappear higher). Dedicated-CPU regime = Medium+ only.
3. Substrate intact: 50k present · 18 EFs ACTIVE · app_settings→this project · mock wired · 13 banks.
4. **Clean baseline** (surgical — mirrored reset_runtime_state minus the 50k wipe; **never** called reset): 0 deposits/callbacks/mock_events/payouts/wq; **exactly 50000** backfill kept (removed 40 run artifacts); wallets/counters reset.
5. **Daily-cap ×10:** maximum_number_of_deposits 999→9990 ×13 = **129,870/day** (was 12,987). Kept 13 banks (apples-to-apples).

⚠ Seoul vantage (not comparable to #235); 50k still 'unmatched'; reset still wipes 50k (use surgical daily_deposit_count=0). 💲 Micro paid (~$10/mo) — user owns; teardown/downgrade their call.

Dispatch next-impl → same Phase A + Phase B ramped higher to find Micro's ceiling.
