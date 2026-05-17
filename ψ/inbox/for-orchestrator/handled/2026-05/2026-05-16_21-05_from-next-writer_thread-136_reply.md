---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 136
parent_thread: 132
parent_oracle: orchestrator
subject: RR11 #1 done — PAYOUT-009 authored (statement-driven review-payout auto-reconcile, Phase-1 review→success)
needs_response: false
priority: normal
created: 2026-05-16T21:05:00+07:00
handled_at: 2026-05-16T21:18:00+07:00
handled_by_thread: 132
handled_note: §11k aggregate — RR11 #1 received. next-writer reported via envelope only; orchestrator mirrored the content into sub-thread #136 (msg 376) for the durable record and closed #136. Progress posted to parent #132 msg 377. needs_response=false, no reply envelope sent. File was found already moved to handled/ by a concurrent process (content intact); handled_* metadata appended here. Campaign #132 still awaits sub #137.
---

RR11 writer handoff #1 is done — GitHub **PR #133** on
`kxlahsimx09/mb-next-payment-gateway` (`docs/requirements/epic-payout.md`,
+82/−1).

## Decision: a new story (PAYOUT-009), not a PAYOUT-004 extension

RR10 states PAYOUT-004 is *unchanged and remains the fallback*. Auto-reconcile
is a distinct mechanism — a new outbound-matcher EF, its own trigger wiring,
feature flag, and cross-repo memo contract — so it gets its own story.
PAYOUT-004's decisions are untouched; it received exactly one editorial
edge-case bullet pointing forward to PAYOUT-009.

## Scope shipped — Phase-1 `review → success` only

- **RR3 core** — a `direction='out'` debit row whose transfer description
  carries a `review` payout's `request_id` resolves the payout via
  `mark_success`: freeze settled exactly once, one `payout.success` callback,
  `bank_transaction_id` from the statement row, no interim `failed`.
- **RR4 `review → failed`** — Phase-2-deferred (thread #133 Q1 = (B)); covered
  as an edge case explaining the "absence never auto-fails" invariant —
  **out of story scope** as instructed.
- **RR9** — `payout_auto_reconcile_enabled` default ON (Q2 = (ON)); the
  default-ON-vs-§Amendment-2026-05-15-default-OFF divergence is noted in an
  edge case.
- RR5 / RR6 / RR7 / RR8 carried into ACs + edge cases.

## One consistency call flagged

The amendment phrases the outcome as `review → completed` (mobiz's stored
word). I authored the story on the next-system terminal **`success`** per
§ADR-9 §Bundle TS2 (PAYOUT-002 already ratified this and explicitly notes
mobiz uses `completed`). The matcher calls `mark_success` → stored status
`success` → event `payout.success`. An edge case flags the wording
difference so the `completed`/`success` gap is not mistaken for a defect.

## Changes

- Epic index table — PAYOUT-009 row (S2, gateway + bot).
- Epic Subsystems line — §ADR-4b statement-intake pipeline added.
- PAYOUT-004 — one edge-case bullet ("most `review` payouts now resolve
  without an admin; PAYOUT-004 is the fallback"); mechanics unchanged.
- PAYOUT-009 — full story: 6-step journey, mermaid, 8 ACs, 8 edge cases,
  13-line Sources block.

## Production grounding (dpay MCP, 2026-05-16, my own verification)

`bank_statements` 1,063,735 rows — `direction='out'` 339,989 (matched
214,036 / fee 120,598 / unmatched 5,303 / pending 52); **67,976**
`direction='out'` rows embed a `PAY…` `request_id` in the description (the
KTB memo signal). Sampled SCB `direction='out'` rows carry dest bank/last-4/
name but **no** `request_id` — corroborates RR2's bank-dependent signal +
graceful-degradation design. `ts_payouts` review-state rows are 100%
`request_id`-populated.

Mermaid render checked — no `-`-starter token in any message-text label.

PR #133 depends on §ADR-4a §Amendment 2026-05-16 landing in `docs/adr.md`
(PR #132, next-architect). Parallel PRs; both merge independently to the
consistent end state.

— next-writer, 2026-05-16 GMT+7

<!-- handled_at: 2026-05-16T21:20:00+07:00 — RR11 #1 done, PAYOUT-009 PR #133(mb-next). -->
