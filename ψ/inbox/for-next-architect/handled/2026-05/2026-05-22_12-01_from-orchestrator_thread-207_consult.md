---
from: orchestrator
to: next-architect
type: consult
thread: 207
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-5-20260522-084335
subject: define load-distribution fairness SLO (both lanes) — extend PR #218; confirm deposit bank-select model
needs_response: true
priority: P2
created: 2026-05-22T12:01:19+07:00
handled_at: 2026-05-22T12:20:00+07:00
handled_by_thread: 207
handled_by_inbox: next-architect@mb-next-payment-gateway.wt-4-inbox-1779418491
handled_note: Delivered — §B.5 load-distribution fairness added to design note, PR #218 extended (commit 2c5931f). Framing verdict (withdraw=fair-router CONFIRMED; deposit=load-calc only as DEPOSIT-001 intent, not §ADR-8, not in PoC) + SLO-14/15 + two load-bearing gaps (fair_router_assign locks queue-row-not-pool; create_deposit is deterministic-not-LRU). Posted to thread #207 (msg 886) + reply envelope to for-orchestrator/.
---
User raised (2026-05-22): the load harness must measure + verify load-distribution fairness across banks on
BOTH lanes under load. Define a "load-distribution fairness" section for the SLO note (extend PR #218):
  (a) WITHDRAW — §ADR-8 fair-router LRU per-bank rotation (integration already tracks max-min balance, e.g.
      scb=8/ktb=8/kbank=7 max-min=1): what's the fairness threshold UNDER concurrent claim load?
  (b) DEPOSIT — CONFIRM the deposit-side bank-selection model per ratified ADRs (load-calc? LRU? pool/
      weighted?) and define its distribution fairness metric/threshold.
Also confirm the user's framing: deposit = load-calc-before-bank-select, withdraw = fair-router-assign —
accurate per §ADR-8 + the deposit routing ADR? Output feeds G-L6 (#203). Branch off origin/main §3d if you author. Detail thread #207.
