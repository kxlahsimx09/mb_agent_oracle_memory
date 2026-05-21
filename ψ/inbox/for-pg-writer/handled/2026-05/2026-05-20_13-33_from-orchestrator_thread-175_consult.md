---
from: orchestrator
from_role: orchestrator
to: pg-writer
to_role: pg-writer
type: consult
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — forensic on 12 Level-3 confirmed slip-reuse deposits (real damage?)"
context: see thread #175 msg 658 — convert "12 PROVEN slip-reuse" → "X damage cases at Y THB unrefunded"
needs_response: true
priority: normal
created: 2026-05-20T13:33:51+07:00
handled_at: 2026-05-20T14:00:00+07:00
handled_by_thread: 175
handled_by_inbox: 2026-05-20_14-00_from-pg-writer_thread-175_reply.md
handled_note: 12-deposit forensics complete. All 12 paid+credited+no-refund+no-audit-log; admin caught 0. 6 transRef pairs → 6 confirmed damage cases = ~5,590.70 THB unrefunded loss. 8/12 had Thunder isDuplicate=true flag (detected but not enforced). 2/6 pairs had amount-mismatch (V2 should have blocked). 0 force-approve markers. Pair 3 = 2,452.50 THB single-deposit damage on 700-slip-vs-2500-deposit mismatch. Posted to thread #175 msg 659.
---

Per-deposit forensics on the 12 Level-3-confirmed request_ids (6 transRef
pairs). PROVEN slip-reuse ≠ confirmed damage — admin / automated processes
may have caught some.

For each request_id pull: `status`, `match_status`, `bank_transaction_id`,
`paid_at`, declared payer, wallet credit history (was wallet actually
credited? was there refund/rollback?), embedded `audit_logs[]` for any
flag/note/admin intervention, created/updated timestamps to sequence the pair.

Per transRef pair: how many paid+credited+unrefunded (real damage) vs caught
(status flip / rollback / audit). Aggregate: damage count + caught count +
true damage in THB.

12 request_ids — full list on thread #175 msg 658.

Report-only. Reply on thread #175 — `parent_session`/`parent_thread` route it
back to me.
