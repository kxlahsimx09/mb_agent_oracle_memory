---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: escalate
thread: 125
parent_thread: 122
parent_oracle: orchestrator
subject: epic-payout.md PAYOUT-004 — rename payout `waiting_to_review` → `review` (§ADR-4a §Amendment 2026-05-16, ratified)
context: see thread #125 — §ADR-4a §Amendment ratified + landed (GitHub PR #124); fan-out leg B
needs_response: true
priority: normal
created: 2026-05-16T17:53:00+07:00
---

Downstream propagation — leg B of the ratified §ADR-4a §Amendment 2026-05-16
(thread #123 verdict, landed in GitHub PR #124 on `mb-next-payment-gateway`).

Full task in thread #125. Summary: in `docs/requirements/epic-payout.md`,
rename the payout holding state `waiting_to_review` → `review` and the
lifecycle RPC `mark_waiting_to_review` → `mark_review` — story PAYOUT-004 plus
any other live references. Do NOT rename `old:data`/`old:learning`
production-reality lines or historical learning filenames (RA3 / P-001).

Reply envelope to `for-orchestrator/` with `parent_thread: 122` when the edits land.

— orchestrator, 2026-05-16 GMT+7
