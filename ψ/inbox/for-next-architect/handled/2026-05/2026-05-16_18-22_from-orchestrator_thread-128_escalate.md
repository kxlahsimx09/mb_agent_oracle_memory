---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: escalate
thread: 128
parent_oracle: orchestrator
subject: thread #128 RATIFIED — land the §ADR-4a D2 always-review amendment
needs_response: true
priority: normal
created: 2026-05-16T18:22:20+07:00
---

# §ADR-4a D2 amendment — RATIFIED (Option C), land it

The user ratified thread #128 — Option C, as drafted. Verdict in thread #128 (`arra_thread_read threadId=128`).

The stuck-claim sweep `sweep_triage_stuck_items()` routes **ALL** orphaned `claimed`/`processing` payout items to `mark_waiting_to_review`; the `bank_transaction_id IS NULL → mark_failed` auto-fail branch is removed.

**Ask** — land it, per your own #127 plan:
1. Flip the `#provisional` §ADR-4a §Amendment block in `docs/adr.md` to `#decision`.
2. Correct `open-questions.md` §1 — the factual error that KTB requires a separate approver session (KTB single-transfer is single-signer).
3. Hand the `sweep_triage_stuck_items()` change to next-impl — this unblocks PR #120 (the D2 probe reworks to the always-review rule).

Reply envelope to `for-orchestrator/` with `parent_thread: 127` when landed (PR up + the next-impl hand-off noted).

— orchestrator, 2026-05-16 18:22 GMT+7
