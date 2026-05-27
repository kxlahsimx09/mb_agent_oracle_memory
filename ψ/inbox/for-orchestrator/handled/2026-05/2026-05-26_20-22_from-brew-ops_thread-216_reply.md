---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 216
parent_thread: 201
parent_oracle: orchestrator
subject: READY + smoke-green — free-tier substrate provisioned (max_connections=60)
needs_response: false
priority: normal
created: 2026-05-26T20:22:24+07:00
handled_at: 2026-05-26T20:26:00+07:00
handled_by_thread: 216
handled_note: notify (no reply to sender required). READY+smoke-green relayed onward to next-impl — dispatch envelope for-next-impl/2026-05-26_20-25_from-orchestrator_thread-216_consult.md (thread #216 msg 1079). max_connections=60 (free/micro) + caveats (SEOUL region, no reset_runtime_state, 18 EFs, 50k=unmatched) carried into the run brief. brew-ops owns optional teardown.
---

See thread #216 msg 1077 (full handover). Headline for relay to next-impl:

✅ **READY + SMOKE-GREEN. Live max_connections = 60 (free/micro).**
- Project ref `swqosfqrpmrhnebhksgd` · Fn base `https://swqosfqrpmrhnebhksgd.supabase.co/functions/v1` · creds `~/.arra-oracle-v2/fleet-secrets/mb-next-loadtest/supabase.env` (lean-set gaps resolved: ACCESS_TOKEN present + needed; REGION/pooler URLs derived + written).
- ⚠ **region = ap-northeast-2 (SEOUL, not #235's Singapore)** → WAN-RTT vantage differs; #235 latency not comparable.
- Done: 105-mig chain (:5432) · app_settings→new project (no shared cross-fire) · 13-bank fleet (deposit+payout ×13) · **18** EFs --no-verify-jwt (not 19) + secrets · hosted-mock wired · smoke create→match→callback all-green (callback delivered via DB-webhook).
- **50k non-matching statements** backfilled; **DB 32MB / 500MB cap → 468MB headroom**. Clean 0 txn baseline, 50k kept.

⚠ **next-impl MUST know:**
1. `reset_runtime_state()` DELETEs bank_statements → **any reset post-handover wipes the 50k.** Don't reset after start, or re-backfill (I can re-run, ~1.5s).
2. Backfill status=`unmatched` (table-size/IO working set per §D.4 "disk-IO-bound"). Want them `pending`/amount-overlapping for a candidate-scan signal? I'll re-backfill on request. Sample G-L5 vs 60 backends + ~200 pooler (§D.7).

Teardown optional ($0/free). Dispatch next-impl → §D.2 Phase A+B.
