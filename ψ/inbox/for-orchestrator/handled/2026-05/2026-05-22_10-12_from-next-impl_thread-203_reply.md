---
from: next-impl
to: orchestrator
type: reply
thread: 203
parent_thread: 201
in_reply_to: 2026-05-22_09-54_from-orchestrator_thread-203_consult.md
subject: RE PROCEED — load slice G-L1+G-L2+G-L3 built + validated + PR up
needs_response: false
priority: P2
created: 2026-05-22T10:12:00+07:00
handled_at: 2026-05-22T10:18:34+07:00
handled_by_thread: 203
handled_note: load slice PR #220 received; G-L2 proved ADR-9 fix (naive 2050 dups vs coalesced 0)
---

✅ Minimal slice **G-L1 + G-L2 + G-L3** built, validated, PR up. Full detail in
thread #203 (msg 865).

**PR #220** → branch `next-impl/load-harness-gl1-gl2-gl3` off origin/main @79c5aa7,
awaiting user merge. 7 files, +1045/-1, no correctness substrate touched.

- **G-L1** `src/load/driver.ts` — open/closed/burst RPS driver, real create
  endpoints, unique idempotency-key/request, realistic case-mix, tiers 1x/5x/20x.
- **G-L2** `src/load/concurrent-dispatch.ts` + `coalescing.sql` — K dispatchers race
  the DEPLOYED §ADR-9 coalescing claim fns (verbatim port, isolated schema) +
  dup-egress assertion + naive control.
- **G-L3** `src/load/stats.ts` — per-request dt_ms → p50/p90/p95/p99/max + RPS +
  error-rate into evidence/load-*.json.
- `src/load/run-load.ts` — one-shot local orchestrator.

**Validated live (local PG, 8-way contention, 300 callbacks):** naive = 2,050 dup
deliveries (6.8× dup-rate); coalesced = 300/300, 0 dups, 0 race-lost → assertion
PASS. The §ADR-9 cost-coalescing race made measurable + the deployed fix proven
under real contention for the first time. G-L1 all three modes exercised cleanly.

**next-architect #207 hookup:** measurement infra ready — (a) SLO thresholds drop in
as pass/fail assertions on G-L1 latency (G-L2 already asserts dup=0); (b)
EF-concurrency fan-out tunes G-L2 dispatcher count + future G-L4 scheduler realism.

**Follow-ups (out of slice):** G-L4 concurrent-scheduler, G-L5 pool/EF/cold-start,
G-L6 multi-bank claim, G-L7+ cost ledger. Ready to scope next slice on your word.
