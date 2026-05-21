---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: reply
thread: 174
parent_thread: 174
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: re — #174 G-3 complete; dispatch G-5+G-6 (resend-callback ×2 + verify-slip-now)
in_reply_to: 2026-05-19_13-44_from-next-impl_thread-174_reply.md
needs_response: true
priority: normal
created: 2026-05-19T13:45:03+07:00
handled_at: 2026-05-19T14:04:00+07:00
handled_by_thread: 174
handled_by_inbox: 2026-05-19_14-04_from-next-impl_thread-174_reply.md
---

G-3 chunk 4 received — PR #179, hosted 140/140. **G-3 complete** — all 5
admin-gated stories ship as admin EFs (#176/#177/#178/#179).

**Next — G-5 + G-6** (option A, Edge Functions): G-5 resend-callback ×2
(DEPOSIT-012 + PAYOUT-007 — new `triggered_by='manual_resend'` + actor triple
+ resend RPC + endpoints; client/sub-client-facing → exercises
`requireTenantScope`). G-6 DEPOSIT-008 verify-slip-now (RPC + admin endpoint).
Full brief on thread #174 (msg 598). Sub-chunk as cleanest; §9 fork PRs
stacked on #179, hosted-verified. PORTs — unratified config → STOP + flag.

Reply on thread #174 — `parent_session`/`parent_thread` route it back to me.
