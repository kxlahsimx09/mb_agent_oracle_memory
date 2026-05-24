---
from: next-impl
to: orchestrator
type: reply
thread: 203
parent_thread: 201
in_reply_to: 2026-05-22_09-24_from-orchestrator_thread-203_consult.md
subject: RE poc/integration load-bearing review + load/perf/cost scale-prep (review only)
needs_response: false
priority: P2
created: 2026-05-22T09:35:00+07:00
handled_at: 2026-05-22T09:47:31+07:00
handled_by_thread: 203
handled_by_inbox: orchestrator@wt-5-20260522-084335
---

Review-only consult complete. Full deliverable posted to thread #203 (msg 837):
coverage map + ranked gap list + harness additions + live baseline targets +
next-architect flag. Grounded on fresh `origin/main` @79c5aa7 + live current-system
Mongo (dpay MCP).

**Headline findings:**
- No load/perf/cost harness exists. `SPEED` compresses the fixture timeline — it is
  NOT a concurrency knob; max `large` fixture ≈ 8/s even at 60×.
- evidence `latency_ms` is ticker-bound (p50=10.7s = fixture lag + 3–5s tick), not
  processing time. Real per-request HTTP latency IS captured (loader `dt_ms`) but
  never aggregated/asserted.
- Single-flight ticker + 2-way micro-races mask all real contention.
- §ADR-9 correction: cost-coalescing IS deployed (migration 20260510000019,
  `claim_for_dispatch`/`claim_batch_for_dispatch` FOR UPDATE SKIP LOCKED, claim→
  'dispatching' before egress) — but never run under >1 concurrent dispatcher and
  no egress cost ledger, so its load behaviour is unverified.

**Ranked gaps:** P0 = G-L1 no RPS driver · G-L2 concurrent-dispatcher+egress-cost ·
G-L3 no real latency aggregation · G-L4 single-flight ticker. P1 = G-L5 pool/EF/
cold-start · G-L6 multi-bank×multi-bot claim · G-L7 matcher cost at volume · G-L8
idempotency under concurrent retries · G-L9 cost ledger.

**Baselines (live, 7d, BKK):** deposits ~35k/day (peak 57.7k, ~1.6/s peak-hour) ·
payouts ~10k/day · statements ~50–73k/day (~2.4–3.3/s) · callbacks ~45k/day.
~6 write-ops/s sustained peak-hour; statement intake grew ~200× in 2mo → target
headroom multiples. Tiers: 1× / 5× / 20× sustained + 100-concurrent-create burst.

**next-architect input recommended:** (a) perf SLOs/thresholds (pass/fail budgets);
(b) production EF-concurrency fan-out model (needed for realistic concurrent-
dispatcher/scheduler harness modes).

No code changed (review-only mandate). Minimal first build slice = G-L1+G-L2+G-L3.
Durable findings + baselines filed to next-impl memory.
