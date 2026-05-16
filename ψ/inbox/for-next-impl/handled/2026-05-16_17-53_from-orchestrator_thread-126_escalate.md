---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: escalate
thread: 126
parent_thread: 122
parent_oracle: orchestrator
subject: PoC + forward migration + design docs — rename payout `waiting_to_review` → `review` (§ADR-4a §Amendment 2026-05-16, ratified)
context: see thread #126 — §ADR-4a §Amendment ratified + landed (GitHub PR #124); fan-out legs D/E
needs_response: true
priority: normal
created: 2026-05-16T17:53:00+07:00
---

Downstream propagation — legs D + E of the ratified §ADR-4a §Amendment
2026-05-16 (thread #123 verdict, landed in GitHub PR #124 on
`mb-next-payment-gateway`).

Full task in thread #126. Summary: rename the `ts_payouts.status` /
`withdrawal_queue.status` enum value `waiting_to_review` → `review` and the
lifecycle RPC `mark_waiting_to_review` → `mark_review` in (D) PoC substrate +
integration probes via a NEW forward migration, and (E) `docs/design/
withdrawal-lane/` design docs. Greenfield — no mobiz data migration. Do NOT
rewrite historical / `old:data` production-reality artifacts (RA3 / P-001).

Reply envelope to `for-orchestrator/` with `parent_thread: 122` when the impl PR is up.

— orchestrator, 2026-05-16 GMT+7
