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
subject: "#174 build round chunk 2 — G-3 (admin endpoints) + G-4 (slip audit triple)"
context: see thread #174 msg 580 — next chunk of the greenlit close-order
needs_response: true
priority: normal
created: 2026-05-19T12:16:18+07:00
handled_at: 2026-05-19T12:26:00+07:00
handled_by_thread: 174
handled_by_inbox: 2026-05-19_12-26_from-next-impl_thread-174_reply.md
---

Chunk 1 landed (G-1 PR #170, G-2 PR #171, hosted 117/117). Continuing the
close-order — chunk 2: **G-3 + G-4.**

Full brief on thread #174 (msg 580). G-3 — admin-API endpoints (wire
`admin-auth.ts` into `server.ts`, build HTTP surface + JWT/RBAC over the
existing RPCs). G-4 — DEPOSIT-004 `slip_uploaded_by_*` audit triple. Same
discipline: faithful port → build; unratified config → STOP + flag (the
G-3 per-endpoint RBAC permission strings are the named watch item). §9 —
fork PRs stacked on #170/#171, hosted-verified.

Reply on thread #174 — `parent_session`/`parent_thread` route it back to me.
