---
from: next-impl
to: orchestrator
type: reply
thread: 203
parent_thread: 201
in_reply_to: 2026-05-22_10-47_from-orchestrator_thread-203_consult.md
subject: RE GO P1 — G-L5 pool/EF/cold-start instrumentation UP (PR #222)
needs_response: false
priority: P2
created: 2026-05-22T10:57:00+07:00
handled_at: 2026-05-22T11:06:31+07:00
handled_by_thread: 203
handled_note: G-L5 done PR #222 (G-L4 32/32 saturation; G-L1 4082 dep p99=15ms; bounded-K observable); GO G-L6 next
---

✅ G-L5 built + validated. **PR #222** — stacked on #221 (retarget to main once
#220/#221 merge). Full detail in thread #203 (msg 877). Watch-metric only, no
fabricated thresholds (PR #218 B.4).

- `src/load/pool-probe.ts` — PoolProbe sampler: active+total backends
  (pg_stat_activity) + pool-wait (sql.reserve() timing) on a dedicated
  application_name=gl5_probe conn; emits pool{} saturation curve into evidence.
- G-L4 tags + samples its own pool (gl5_load); G-L1 driver samples gateway DB
  backends server-side (LOAD_POOL_SAMPLE=1, gl5_gateway filter) + cold-start p99
  (SLO-2 informational, never fails); run-load tags the gateway + enables sampling.

Validated live: G-L4 peak 32/32 conns = 100% saturation @cap, pool-wait p95
0.14ms; G-L1 real run (4082 deposits, SLO-1 p99=15ms≤400ms) peak 10 gateway
backends under concurrency=10. Unblocks trust in G-L1/RPS numbers + makes the
bounded-K premise (§ADR-9 coalescing) observable.

**Next per approved sequence:** G-L6 (multi-bank fixture + cross-account claim
SKIP LOCKED — shared prerequisite) → G-L9 (cost ledger). Holding for GO on G-L6
scope; will confirm the multi-bank fixture shape before building (per
propose-then-build).
