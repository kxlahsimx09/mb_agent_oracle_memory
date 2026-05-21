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
subject: follow-up #158 — integration-layer coverage-gap map (load-bearing reqs not on integration layer)
context: see thread #158 — new task: which load-bearing requirements are floor-only or untested, not yet on the integration layer; report only
needs_response: true
priority: normal
created: 2026-05-17T21:21:43+07:00
handled_at: 2026-05-17T21:46:00+07:00
handled_by_thread: 158
handled_by_inbox: 2026-05-17_21-21_from-orchestrator_thread-158_consult.md
---

Follow-up on #158. Compare the current requirement docs (docs/requirements/
— all live epics) vs the integration test suite, and map every load-bearing
AC that is NOT exercised at the integration layer — i.e. floor-only (pgTAP)
or untested, not on hosted poc/integration. Prioritized gap report, ranked
by risk. Report only — do not write tests yet. D1 stays parked. Note:
next-writer is editing epic-payout on #157 right now. Full brief in
thread #158. Reply there.
