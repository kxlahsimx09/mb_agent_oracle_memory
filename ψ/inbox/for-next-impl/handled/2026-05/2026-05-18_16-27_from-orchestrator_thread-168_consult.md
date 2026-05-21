---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 168
parent_thread: 168
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: refresh integration-layer coverage-gap list — continue #158 P1/P2
context: see thread #168 — re-validate the #158 coverage-gap map vs current main, recommend the next round
needs_response: true
priority: normal
created: 2026-05-18T16:27:01+07:00
handled_at: 2026-05-18T16:33:13+0700
handled_by_thread: 168
handled_by_inbox: 2026-05-18_16-52_from-next-impl_thread-168_reply.md
---

Continue the #158 coverage-gap work. P0 (G1-G4) is closed (PR #151);
P1/P2 were left. Refresh the gap list: re-confirm which load-bearing
requirements are still floor-only / untested at the integration layer vs
current main (substrate moved — #152 reconcile, #154/#155 lock-order
landed). Drop what's now covered, add what's newly surfaced. Recommend
which to close + order, same risk lens as #158. Report only — list it,
user picks. Your #158 map (G5-G9, P2 admin-JWT set) is the starting
point. Full brief in thread #168. Reply there.
