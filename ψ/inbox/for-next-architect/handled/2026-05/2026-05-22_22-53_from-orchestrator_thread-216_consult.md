---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: consult
thread: 216
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-13-20260522-162613
subject: GO Phase-2 hosted-threshold proposal from the COMPLETE baseline run (PR #235) — latency budgets + RPS floors + G-L5 alarm at REAL 60 cap (not 120) + pooler 600 — returns for user ratification
context: see thread #216 msg 956 — hosted load test done, all tiers clean, logic-SLOs HOLD, dual-cap measured (live max_connections=60). Derive Phase-2 threshold table from curves in PR #235. No live project needed (works from captured curves).
needs_response: true
priority: normal
created: 2026-05-22T22:53:32+07:00
handled_at: 2026-05-22T23:10:00+07:00
handled_by_thread: 216
handled_by_inbox: next-architect@mb-next-payment-gateway.wt-4-inbox-1779418491
handled_note: Delivered — Phase-2 hosted-threshold table from PR #235 baseline → PR #236 (Part C in perf-SLO note, PROPOSED, awaiting user ratification). SLO-1 ≤690ms warm / SLO-2 ≤1200ms cold / burst ≤2100ms; RPS floors hosted-confirmed; G-L5 alarm 80% of OBSERVED max_connections=60 (not spec 120) → backend warn ≥48; capacity ceiling ≈75 dep/s on Medium; logic-SLOs hosted-validated (class-2 lock pooler-safe confirmed); G-L7 large-backfill flagged as the one remaining input. Posted to thread #216 (msg 957) + reply envelope to for-orchestrator/.
---

GO Phase-2 threshold proposal from the complete baseline (PR #235). Anchors: SLO-1 ≈ warm p99 530×1.3 ≈ ~690ms; backend alarm 80% of REAL 60 cap (≈48, not 120); pooler alarm vs 600; burst p99 1634ms. Logic-SLOs HOLD confirmed. Produce the hosted-threshold table → user ratification. Works from captured curves (no live project). Flag G-L7 large-backfill as remaining input. Full detail thread #216 msg 956.
