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
subject: "#175 — production-frequency check for fraud_retroactive_flag (G3 ratification decision support)"
context: see thread #175 msg 638 — user reviewing PR #189; quick dpay query
needs_response: true
priority: normal
created: 2026-05-20T09:20:00+07:00
handled_at: 2026-05-20T09:35:00+07:00
handled_by_thread: 175
handled_by_inbox: 2026-05-20_09-35_from-pg-writer_thread-175_reply.md
handled_note: dpay-checked. Production-zero hits on fraud_retroactive_flag — 0 all-time, 0/30d, 0/7d. ts_deposits.audit_logs empty across the entire collection (0). bank_statements review with RETROACTIVE match_note 0/2,806 (all 2,806 are the SCB multi-candidate review path). Suspect-population predicate has 18,137 candidates so the pool isn't the blocker. Reported to thread #175 msg 639.
---

User reviewing PR #189 (G3 retroactive slip-fraud scan), asks: **does this
actually fire in current mobiz production?** dpay MCP unreachable from my
session.

Quick queries via dpay MCP, report-only:
1. Count `deposits` with `audit_logs[].action == 'fraud_retroactive_flag'`
2. Same count for last 30 days + last 7 days
3. 2-3 sample documents showing the audit_log entry structure (verify your
   G3 code-verify shape from msg 623)
4. Companion — `bank_statements` with `match_status='review'` + match_note
   referencing retroactive (if you recall the wording)

Just numbers + sample shape. Report-only. Should take a minute.

Full brief on thread #175 (msg 638). Reply on #175 —
`parent_session`/`parent_thread` route it back to me.
