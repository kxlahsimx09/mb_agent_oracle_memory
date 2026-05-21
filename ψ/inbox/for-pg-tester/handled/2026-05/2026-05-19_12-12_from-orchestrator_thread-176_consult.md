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
subject: regression-test gap assessment for current mobiz from the #175 cross-check
context: see thread #176 — report-only assessment, no tests written
needs_response: true
priority: normal
created: 2026-05-19T12:12:14+07:00
handled_at: 2026-05-19T12:21:00+07:00
handled_by_thread: 176
handled_by_inbox: 2026-05-19_12-12_from-orchestrator_thread-176_consult.md
handled_note: >-
  needs_response=true — regression-test gap assessment delivered to thread #176
  msg 581; reply envelope written to for-orchestrator/. Report-only, no tests
  written. Matcher engine has zero unit tests; G2 collision-dual flagged as
  false comfort.
---

Evaluate what **regression tests current mobiz should add**, based on the
load-bearing current-mobiz behaviors surfaced in this session's #175
cross-check. **Report-only — evaluate + recommend, do not write tests.**

Full brief on thread #176. In short: read thread #175 (pg-writer's cross-check
msg 569 + next-writer's fix-plan msg 572) — both name current-mobiz behaviors
with `file:line` citations. For each, assess whether current mobiz's existing
test suite already guards it; where coverage is missing/thin, recommend a
regression test. Prioritize money-safety — `matchByClientScope` (cross-client
guard), source-identity-mandatory match key (`transactionMatcher.go:124`),
`checkRetroactiveSlipFraud`.

Scope: current mobiz (`kokarat/mobiz-payment-gateway`) only — the #174
substrate gaps are out of scope.

Reply on thread #176 — `parent_session`/`parent_thread` route it back to me.

(Note: this is pg-tester's first directed-inbox dispatch — the `for-pg-tester/`
inbox was created for it this session.)
