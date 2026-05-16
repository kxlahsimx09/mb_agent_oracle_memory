---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 125
parent_thread: 122
parent_oracle: orchestrator
subject: epic-payout.md PAYOUT-004 — payout `waiting_to_review` → `review` rename landed (leg B)
needs_response: false
priority: normal
created: 2026-05-16T17:55:00+07:00
handled_at: 2026-05-16T18:00:00+07:00
handled_by_thread: 122
handled_note: leg B reply; sub-thread 125 closed; progress posted to parent 122 msg 329; 126 still open
---

Leg B of the ratified §ADR-4a §Amendment 2026-05-16 is done — GitHub **PR #125**
on `kxlahsimx09/mb-next-payment-gateway` (`docs/requirements/epic-payout.md`,
+14/−14).

## Renamed — 14 live references

`waiting_to_review` → `review`, `mark_waiting_to_review` → `mark_review`:

- **PAYOUT-004** — epic index row, `[S2 ratified]` summary, user-journey step 3
  (Reference-present branch) + step 4, mermaid sequence diagram, all 6
  acceptance criteria, the "non-bot paths to terminal" edge case, and the
  `new:adr` source line (sweep triage `NOT NULL → mark_review`; admin-reconcile
  applies to `review` only).
- **PAYOUT-003** — one live reference in the §Open questions resolved block
  ("parked at `review` for a human").

## Kept verbatim — 6 references (RA3 production-reality carve-out)

- 4× `old:data` production-verification source lines (lines 91, 160, 289, 290 —
  status distributions + mongo collection shapes; mobiz production still uses
  `waiting_to_review`).
- 1× `old:learning` line describing the mobiz withdrawal-lane RPC shape
  (`mark_success` / `mark_failed` / `mark_waiting_to_review`).
- 1× edge-case bullet stating a production fact ("Across production, 550 payout
  work items have reached `waiting_to_review`") — this is a true statement about
  the current system, which the rename deliberately diverges from.

Mermaid render checked — the changed diagram line (`status → review …`) carries
no `-`-starter token; no dash-token render risk.

PR #124 (leg A, the ADR) was OPEN at time of writing; both PRs merge
independently to the consistent end state.

— next-writer, 2026-05-16 GMT+7
