---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: escalate
thread: 132
parent_oracle: orchestrator
subject: design `ReconcileReviewPayoutToCompleted` — statement-driven auto-resolve of a `review` payout
needs_response: true
priority: normal
created: 2026-05-16T18:44:15+07:00
handled_at: 2026-05-17T13:01:04+07:00
handled_by_thread: 132
handled_by_inbox: 2026-05-17_12-48_from-orchestrator_thread-148_dispatch
handled_note: >-
  Thread 132 closed. ReconcileReviewPayoutToCompleted is fully designed and landed —
  §ADR-4a §Amendment ratified via thread #133, RR2a follow-up PR #134, §ADR-9
  callback-silent reconciliation PR #138, impl PR #135, writer PRs #133/#139 — all
  merged. §11g moot path — no reply owed.
---

# Design the `review → completed` statement-driven auto-reconcile

Read thread #132 (`arra_thread_read threadId=132`) for the full brief + the user's reasoning.

Builds on §ADR-4a §Amendment 2026-05-16 (thread #128 — stuck payout claims all route to `review`). This is your flagged **Option D**, now wanted.

**The point:** mobiz's recovery (`ReconcileFailedPayoutToCompleted`, `failed → completed`) works but leaks churn — the client sees two callbacks (`failed` then `succeeded`) and the wallet is debited→credited→re-debited. The next system avoids this **structurally**: a `review` payout has held the callback and the freeze (nothing sent, nothing refunded), so resolution is clean.

**Design `ReconcileReviewPayoutToCompleted`** (+ the symmetric `review → failed`):
1. Trigger — a scraped bank statement matched to a `review` payout (the `request_id`-in-transfer-description signal mobiz uses — confirm it ports).
2. Resolutions — statement confirms landed → `review → completed` (settle freeze once, **one** `payout.success` callback); confirms not-landed → `review → failed` (release freeze, one `payout.failed` callback). A `review` payout emits **no interim callback** — that is the safety win.
3. Coexists with admin-resolve — auto-reconcile moves only *certain* cases out of `review`; uncertain ones stay for the human (PAYOUT-004). Zero safety regression.
4. Draft the §ADR-4a amendment + open the ratification thread.

Additive — does not change the in-flight thread #128 sweep work.

Reply envelope to `for-orchestrator/` with `parent_thread: 132` when the amendment + ratification thread are drafted.

— orchestrator, 2026-05-16 18:44 GMT+7
