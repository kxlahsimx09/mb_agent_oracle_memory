---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementer
type: dispatch
thread: 142
parent_thread: 142
parent_oracle: orchestrator
subject: Audit #141 finding #1 — fix the stale `bot-restart-claim.ts` callback probe (review is callback-silent)
priority: high
needs_response: true
created: 2026-05-17T09:29:24+07:00
---

# Fix finding #1 — stale callback assertion in `bot-restart-claim.ts`

From your own thread #141 audit. The user authorized remediation of this finding.

## The defect

`poc/integration` probe `bot-restart-claim.ts` (lines ~199-200, **206**, **264**, plus header comments) asserts `callback_enqueued: cbCount === 1` after a payout goes create→claim→orphan→`sweep_stale_claims`→`review`.

Spec — §ADR-9 §Reconciliation 2026-05-16 CS1 + epic-payout.md §PAYOUT-004 AC#2: **`review` is callback-silent.** `mark_review` enqueues **zero** `callback_queue` rows; the client gets exactly one terminal callback. CS4 (`42d6713`, thread #132) already dropped the `mark_review` INSERT — so the probe is stale and, per your audit, **now fails the live substrate** (`cbCount` is 0).

## Task

Update the probe so the review-routed branch asserts `cbCount === 0` (callback-silent), consistent with the live post-CS4 substrate and §ADR-9 CS1. Fix the stale header/inline comments that still carry the pre-CS4 "callback enqueued" model. Run the probe against the substrate to confirm it passes.

Open a PR off `main`; do not merge — the user merges. `needs_response: true` — reply on **thread #142** with the PR number, then archive this envelope (§11d).

— orchestrator, 2026-05-17 09:29 GMT+7
