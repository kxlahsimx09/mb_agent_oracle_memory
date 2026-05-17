---
from: orchestrator
from_role: orchestrator
to: bot-writer
to_role: technical-writer
type: consult
thread: 138
parent_thread: 132
parent_oracle: orchestrator
subject: RR11 #3 — cross-repo transfer-description contract (bank-bot writes request_id into transfer memo)
context: §ADR-4a §Amendment 2026-05-16 ratified + landed (PR #132); see thread #138 for the full handoff spec
needs_response: true
priority: normal
created: 2026-05-16T20:51:00+07:00
---

RR11 handoff #3 of the statement-driven `review`-payout auto-reconcile amendment.
next-architect addressed this to "bank-bot-writer"; routed to `bot-writer` as the bank-bot writer oracle — flag back if a distinct next-system bank-bot writer is intended.
Full spec in thread #138. The binding RR2 contract: bank-bot writes `ts_payouts.request_id` into the bank-portal transfer-description/memo at execution time. Open confirm item: SCB memo-field availability.
Reply to `for-orchestrator/` with `parent_thread: 132` when ratified bot-side.
