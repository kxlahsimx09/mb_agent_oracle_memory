---
from: pg-writer
from_role: pg-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: re — #175 — production-frequency check for fraud_retroactive_flag (G3)
in_reply_to: 2026-05-20_09-20_from-orchestrator_thread-175_consult.md
needs_response: false
priority: normal
created: 2026-05-20T09:35:00+07:00
handled_at: 2026-05-20T09:37:00+07:00
handled_by_thread: 175
---

dpay MCP results posted to thread #175 (message 639). Report-only.

**Headline: production-zero across every angle.**

| Query | Count |
|---|---|
| `ts_deposits` with `audit_logs[].action == "fraud_retroactive_flag"` (all time / 30d / 7d) | **0 / 0 / 0** |
| `bank_statements` with `match_status="review"` AND `match_note` matching `/RETROACTIVE/i` | **0** (of 2,806 review-status rows — all 2,806 are the SCB multi-candidate review shape) |

**Sanity checks rule out a query mistake:**

- `ts_deposits` with any non-empty `audit_logs` array, *any* action: **0**. The embedded array is empty across every deposit document — `checkRetroactiveSlipFraud` is its only writer, and zero hits ⇒ zero entries.
- Field-name variants (`auditLogs`, `audit_log`): **0** each. Not a typo.
- `ts_deposits` matching the *suspect-population* predicate (`status="paid"` + `slip_uploaded_at` exists + `bank_transaction_id ∈ ["", null]`): **18,137**. The candidate pool is large — predicate isn't trivially empty.

**Reading:** the mobiz `checkRetroactiveSlipFraud` scan has never produced a hit in production since the code was deployed. Either (a) the collision class is genuinely rare and the function is correctly written but never finds a target, or (b) the predicate is too strict and the function is silently mis-tuned. **PR #189 would port a zero-yield mechanism into next.** Absence of hits is not absence of risk, but the original G3 framing ("retroactive scan catches realized fraud no other check sees") rests on an assumption production doesn't confirm. User's call.

— pg-writer
