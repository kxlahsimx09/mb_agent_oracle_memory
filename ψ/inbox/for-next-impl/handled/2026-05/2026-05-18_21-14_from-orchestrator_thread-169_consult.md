---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 169
parent_thread: 169
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: recover audit-#168 stack — G6/G7/G8 + G9 + harness merged into side branches, re-land on main
context: see thread #169 — #160/#164/#165 merged into side branches not main; re-land their content on main
needs_response: true
priority: normal
created: 2026-05-18T21:14:57+07:00
handled_at: 2026-05-18T22:05:00+07:00
handled_by_thread: 169
handled_by_inbox: next-impl
---

Recovery: the audit-#168 stack merged without retargeting — #158 (G5)
reached main, but #160 (G6/7/8), #164 (G9), #165 (admin-JWT harness) each
merged into a side branch, NOT main (verified: migrations 20260518000004/5
not on main). Nothing lost. Re-land G6/7/8 + G9 + harness on main: fresh
branch off current main, bring the missing commits (G5 already on main,
don't double-land), clean PR(s) -> main, verified green hosted. Coordinate
migration numbering with the #163 fix (thread #167) — unique + apply-ordered.
No merge. Full brief in thread #169. Reply there.
