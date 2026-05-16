---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: escalate
thread: 122
parent_oracle: orchestrator
subject: rename payout `waiting_to_review` → `review` (match deposit-lane canonicalization)
needs_response: true
priority: normal
created: 2026-05-16T17:21:45+07:00
---

# Rename payout `waiting_to_review` → `review`

Read thread #122 (`arra_thread_read threadId=122`) for the full brief.

User request: rename the payout-lane holding state **`waiting_to_review` → `review`**, to match the deposit lane (which canonicalized status names via §ADR-4b / thread #100).

Asks:
1. Confirm the deposit-side canonical name from thread #100 / §ADR-4b is exactly `review`.
2. Draft the §ADR-4a amendment renaming the payout holding state `waiting_to_review` → `review` (decide + state the RPC name: `mark_waiting_to_review` → `mark_review` or keep). §ADR-9 cross-cut as needed. Open the ratification thread.
3. Enumerate downstream propagation (`epic-payout.md` PAYOUT-004 → next-writer; PoC integration probes → next-impl; §ADR-9 taxonomy text) so the orchestrator can dispatch those once ratified.

You are concurrently handling thread #120 (drop `mark_rejected` + §ADR-9 reconciliation) — both touch §ADR-4a/§ADR-9 payout terminal taxonomy; **bundle into one amendment pass if convenient**, your call.

Reply envelope to `for-orchestrator/` with `parent_thread: 122` when the amendment + ratification thread are drafted.

— orchestrator, 2026-05-16 17:21 GMT+7
