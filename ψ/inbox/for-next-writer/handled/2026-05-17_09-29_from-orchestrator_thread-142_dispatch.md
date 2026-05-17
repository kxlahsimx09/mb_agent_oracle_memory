---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: dispatch
thread: 142
parent_thread: 142
parent_oracle: orchestrator
subject: Audit #141 finding #2 — fix stale PAYOUT-004 AC#1 + PAYOUT-003 AC#5 (stuck claim → review, not failed)
priority: high
needs_response: true
created: 2026-05-17T09:29:24+07:00
---

# Fix finding #2 — stale acceptance criteria in `epic-payout.md`

From the thread #141 audit. The user authorized remediation — this one is **money-safety-relevant**: the stale text tells anyone re-implementing from the doc to auto-fail a stuck payout, which is exactly what §ADR-4a §Amendment forbade.

## The defect

In `docs/requirements/epic-payout.md`:

1. **§PAYOUT-004 AC#1** still reads (paraphrase): *"if none was recorded the payout is closed `failed` via the standard release lifecycle."* — This is stale. Per **§ADR-4a §Amendment 2026-05-16** (thread #128, SA1): a NULL-`bank_transaction_id` stuck claim is **not** auto-failed — **every stuck claim routes to `review`**. The NULL→auto-fail branch was removed. The rest of PAYOUT-004 (edge cases), PAYOUT-009 §1, the migrations and the tests already reflect always-`review` — only AC#1 was missed.

2. **§PAYOUT-003 AC#5** — *"never-claimed payout → sweep `mark_failed` claim_timeout"* — stale the same way, and it also **internally contradicts** PAYOUT-003's own edge case *"pre-claim close → `cancelled`, not `failed`."* Reconcile AC#5 with that edge case and with §ADR-4a §Amendment.

## Task

Correct AC#1 and AC#5 so both are consistent with §ADR-4a §Amendment 2026-05-16 and with the rest of their own stories. Do not change behavior elsewhere — this is a stale-text reconciliation.

**Before pushing — mandatory:** run the W1 Step 8 mermaid parser gate (`references/check-mermaid.mjs`) on `epic-payout.md`.

Open a PR off `main`; do not merge — the user merges. `needs_response: true` — reply on **thread #142** with the PR number, then archive this envelope (§11d).

— orchestrator, 2026-05-17 09:29 GMT+7
