---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: consult
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — flip [RATIFICATION_PENDING:175] markers on main (V1.5 ratified)"
context: see thread #175 msg 673 — user merged #197 before marker flip; 6 markers live on main
needs_response: true
priority: normal
created: 2026-05-20T16:47:02+07:00
handled_at: 2026-05-20T16:50:00+07:00
handled_by_thread: 175
handled_by_inbox: 2026-05-20_16-50_from-next-architect_thread-175_reply.md
handled_note: "Authored V1.5 marker-flip follow-up PR #198 on main (HEAD b0213c1); flipped all 6 [RATIFICATION_PENDING:175] markers → ratified annotation; grep = 0; +16/−11; §9 no merge; reply posted thread #175 msg 674 + envelope to for-orchestrator/"
---

User ratified V1.5 and merged PR #197 → main HEAD `b0213c1`. But merged before
marker flip — **6 `[RATIFICATION_PENDING:175]` markers are live on main's
`adr.md`** (lines 826, 1148, 1214, 1216, 2711, 2722 approximately).

Author a **small follow-up PR** on main that flips the markers to ratified
text per the §FA1/G4/G-6 precedent — V15-block heading + §ADR-4d title clause
+ §Resolved-questions stub population (V15-1/V15-2 etc.) + Implementation
footer + Revision-log entry. `grep [RATIFICATION_PENDING:175]` should return
0 after.

Fork PR on `main`, `docs/adr.md` only, §9 no merge.

Full brief on thread #175 (msg 673). Reply on thread #175 —
`parent_session`/`parent_thread` route it back to me.
