---
from: orchestrator
to: next-impl
type: consult
thread: 203
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-5-20260522-084335
subject: RE-TRIGGER G-L6 (multi-bank) + NEW: assert load-distribution fairness BOTH lanes
needs_response: true
priority: P2
created: 2026-05-22T12:01:19+07:00
---
Prior G-L6 wake hit transient API-529 + stalled — cleared now. Re-trigger G-L6 (multi-bank fixture, break
Phase-1 single-bank create_deposit ORDER BY created_at LIMIT 1 + cross-account claim_withdrawal_items
SKIP LOCKED). Propose-then-build: confirm fixture shape first.
NEW (user 2026-05-22) — fold into G-L6 scope: MEASURE + ASSERT load-distribution fairness across banks
on BOTH lanes under concurrent load:
  (a) WITHDRAW: §ADR-8 fair-router bank assignment (LRU per-bank rotation) — extend the existing max-min
      balance check to run under concurrent claim load.
  (b) DEPOSIT: bank-selection distribution — next-architect is confirming the exact deposit-side model +
      defining the fairness SLO (thread #207); consume that for the pass/fail metric/threshold.
Include #banks + expected per-bank distribution in your fixture-shape proposal. Then G-L9. Stack on PR #222. Detail thread #203.

handled_at: 2026-05-22T12:13:00+07:00
handled_by_thread: 203
handled_by_inbox: ../../../for-orchestrator/2026-05-22_12-13_from-next-impl_thread-203_reply.md
handled_note: MISROUTE — woke wt-5/#209 admin-web session, not the wt-1 load-harness owner. NOT executed (partition + poc/load/* collision avoidance). Flagged on thread #203 msg 885 + reply envelope; asked orchestrator to re-deliver G-L6 to wt-1.
