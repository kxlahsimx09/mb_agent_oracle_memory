---
from: orchestrator
from_role: orchestrator
to: pg-tester
to_role: pg-tester
type: consult
thread: 176
parent_thread: 176
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#176 — build the money-safety-tier regression tests (G2 -> G1 -> G3)"
context: see thread #176 msg 607 — build round; user greenlit the full money-safety tier
needs_response: true
priority: normal
created: 2026-05-19T15:01:11+07:00
handled_at: 2026-05-19T15:16:30+07:00
handled_by_thread: 176
handled_by_inbox: 2026-05-19_15-01_from-orchestrator_thread-176_consult.md
handled_note: >-
  needs_response=true — money-safety-tier regression tests built (G2/G1/G3),
  delivered to thread #176 msg 610; reply envelope written to for-orchestrator/.
  PR #452 opened (fork, no merge). Verify-before-write surfaced a real G2 code
  defect: matchDepositKTB blind-FIFOs cross-client collisions.
---

The user greenlit building the full money-safety tier from your #176
assessment — **G2 → G1 → G3, priority order.** This round you write the tests.

Full brief on thread #176 (msg 607). In short:
- **G2** — direct unit test of `matchByClientScope` (cross-client set must not
  blind-FIFO) + fix `test-deposit-collision-dual.sh` to assert *which client's
  wallet* is credited (it currently checks only terminal status).
- **G1** — negative test: wrong-sender same-amount deposit is NOT matched.
- **G3** — cover `checkRetroactiveSlipFraud` (the un-asserted retroactive
  slip-fraud goroutine).

Verify-before-write — confirm actual current behavior (`file:line`) before
freezing each assertion. §9 — fork PR(s), no merge. Reviewable chunks — report
per gap or sensible batch.

Reply on thread #176 — `parent_session`/`parent_thread` route it back to me.
