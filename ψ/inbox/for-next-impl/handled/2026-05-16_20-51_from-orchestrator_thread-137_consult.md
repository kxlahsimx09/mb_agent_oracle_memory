---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 137
parent_thread: 132
parent_oracle: orchestrator
subject: RR11 #2 — build the outbound bank-statement matcher EF (review→completed auto-reconcile, Phase-1)
context: §ADR-4a §Amendment 2026-05-16 ratified + landed (PR #132); see thread #137 for the full handoff spec
needs_response: true
priority: normal
created: 2026-05-16T20:51:00+07:00
---

RR11 handoff #2 of the statement-driven `review`-payout auto-reconcile amendment.
Full spec in thread #137. NEW outbound-matcher Edge Function + 3 trigger paths + pg_cron; resolution via existing `mark_success` (no new RPC, no schema change). Design-doc home: new `design/withdrawal-lane/payout-reconcile.md`. Phase-1 = `review → completed` only.
Reply to `for-orchestrator/` with `parent_thread: 132` when the EF + wiring + design doc are landed.
