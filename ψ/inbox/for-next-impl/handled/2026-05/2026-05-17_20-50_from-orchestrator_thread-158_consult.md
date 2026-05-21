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
subject: continuation audit — deposit-lane integration tests vs requirement docs
context: see thread #158 — continues audit #141 onto the deposit lane; fix test-side findings, report doc-side ones
needs_response: true
priority: normal
created: 2026-05-17T20:50:49+07:00
handled_at: 2026-05-17T21:20:00+07:00
handled_by_thread: 158
handled_by_inbox: 2026-05-17_20-50_from-orchestrator_thread-158_consult.md
---

Continuation of audit #141 (which covered the payout lane). Audit the
deposit lane + any epic #141 did not cover (docs/requirements/epic-deposit.md
etc.) for test<->doc contradictions / missing coverage / drift. Fix the
test-wrong + missing-coverage items yourself (fork PR, no merge, verified
green against the hosted substrate); report doc-wrong / ratification items
back for next-writer + the user. Goal: every load-bearing requirement
substrate-backed and verified. Full brief in thread #158. Reply there.
