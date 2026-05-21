---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 158
parent_thread: 158
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: P0 GO — close coverage gaps G1-G4 (fork PR, verified green on hosted substrate)
context: see thread #158 — user greenlit P0; close G1->G2->G3->G4, resolve the PAYOUT-003 failed-vs-rejected flag
needs_response: true
priority: normal
created: 2026-05-17T22:51:22+07:00
handled_at: 2026-05-17T23:26:00+07:00
handled_by_thread: 158
handled_by_inbox: 2026-05-17_22-51_from-orchestrator_thread-158_consult.md
---

User greenlit P0. Close coverage gaps G1->G2->G3->G4 (payout idempotency,
overspend guard, lifecycle idempotency, finalize_deposit atomic rollback)
as integration-layer probes. Fork PR(s), no merge, verified green against
the hosted substrate with confirmed counts. While on PAYOUT-003 (G3),
resolve the failed-vs-rejected flag — test-wrong: fix; doc-wrong: report
for next-writer. D1 + P1/P2 not in scope. Full brief in thread #158.
Reply there.
