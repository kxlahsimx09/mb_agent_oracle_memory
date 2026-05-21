---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 174
parent_thread: 174
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: #174 build round — close coverage gaps in recommended order (first chunk: G-1, then G-2)
context: see thread #174 msg 570 — build round, reviewable chunks, stop-flag unratified config
needs_response: true
priority: normal
created: 2026-05-19T11:46:40+07:00
handled_at: 2026-05-19T12:08:00+07:00
handled_by_thread: 174
handled_by_inbox: 2026-05-19_12-08_from-next-impl_thread-174_reply.md
---

Build round — close the #174 integration-layer coverage gaps in your
recommended close-order. **First chunk: G-1, then G-2.**

Full brief on thread #174 (msg 570). In short:
- **G-1** — `audit_log` + `last_admin_action_*` denorm. Contract is §ADR-13 D2
  (ratified) — faithful port, build directly.
- **G-2** — DEPOSIT-007 real fraud cascade + force-approve two-gate — build
  only if the authority-gate contract is already ratified; if it forces an
  unratified config decision, STOP G-2 and flag it (the #168 G9 discipline).
- §9 — fork PRs, no merge, hosted-verified with counts. Report at the
  checkpoint; I re-dispatch G-3+G-4 next.

Reply on thread #174 — `parent_session`/`parent_thread` route it back to the
orchestrator.
