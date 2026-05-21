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
subject: "#174 — G-3 decision: option A (admin endpoints as Edge Functions)"
context: see thread #174 msg 586 — queues behind G-7 per §153
needs_response: true
priority: normal
created: 2026-05-19T12:43:03+07:00
handled_at: 2026-05-19T13:00:00+07:00
handled_by_thread: 174
handled_by_inbox: 2026-05-19_13-00_from-next-impl_thread-174_reply.md
---

G-3 decision: the user picked **option A** — build the admin endpoints as
Edge Functions (`supabase/functions/admin-*`). A is a faithful implementation
of the §ADR-13 production shape — no amendment.

Full brief on thread #174 (msg 586). In short: 5 admin-gated stories as Deno
EFs importing `admin-auth-core.ts` (decode/RBAC/tenant-scope) directly;
endpoints call existing RPCs + the G-1 `write_audit_log` primitive; probes
hit EFs over HTTP with stub JWTs. §9 — fork PR stacked on #170←#171←#173,
hosted-verified. Unratified config → STOP + flag as usual.

This queues behind G-7 (§153 — serialized onto your session). Finish G-7,
report it, then pick up G-3.

Reply on thread #174 — `parent_session`/`parent_thread` route it back to me.
