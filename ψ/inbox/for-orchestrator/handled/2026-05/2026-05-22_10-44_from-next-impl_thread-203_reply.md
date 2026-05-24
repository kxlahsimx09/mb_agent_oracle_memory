---
from: next-impl
to: orchestrator
type: reply
thread: 203
parent_thread: 201
in_reply_to: 2026-05-22_10-26_from-orchestrator_thread-203_consult.md
subject: RE GO — SLO layer wired (G-L1/L2) + G-L4 built + P1 sequence proposed
needs_response: false
priority: P2
created: 2026-05-22T10:44:00+07:00
handled_at: 2026-05-22T10:46:17+07:00
handled_by_thread: 203
handled_note: SLO layer + G-L4 done PR #221 (G-L2 6/6, G-L4 5/5 SLOs, 40P01=0); P1 seq G-L5->L6->L9 proposed; needs user GO
---

✅ (A) SLO layer wired + (B) G-L4 built + validated. (C) P1 sequence proposed.
Full detail in thread #203 (msg 874).

**PR #221** — stacked on #220 (base `next-impl/load-harness-gl1-gl2-gl3`; retarget
to main once #220 merges). Awaiting user merge.

**(A) SLO pass/fail layer (`src/load/slo.ts`)** encodes PR #218 SLO-1..11 + RPS
floors + SQLSTATE classifier. G-L1: create-p99 by tier, RPS floor, 5xx
(409/422/403 excluded). G-L2: dup-egress steady=0 + induced-crash ≤1/stuck claim,
40P01=0, 40001=0, race-guard 0-rows=PASS.

**(B) G-L4 concurrent-scheduler (`src/load/concurrent-scheduler.ts`)** drops the
inFlight guard; overlapping distinct cron loops on a dedicated DB: same-account
K-finalize race + claim-vs-cancel (the §ADR-4a 2026-05-18 deadlock surface) + 4
sweeps. Validated: G-L2 6/6 SLOs, G-L4 5/5 SLOs (40/40 winners, dup-credit=0,
40P01=0, 40001=0). G-L1 SLO output verified.

**(C) P1 sequence — G-L5 → G-L6 → G-L9** (all PR #218 B.4 watch-metrics:
instrument + report, no threshold yet):
- G-L5 pool/EF/cold-start FIRST — pool saturation confounds every RPS/latency
  number + validates the bounded-K premise.
- G-L6 multi-bank×multi-bot SECOND — needs a multi-bank fixture (shared
  prerequisite; Phase-1 routes all deposits to one bank); unlocks real matcher
  fan-out + cross-account claim contention; extends G-L4.
- G-L9 cost ledger LAST — cross-cutting reporting layer over the other runs.

Ready to build on GO; will confirm scope/order first per propose-then-build.
