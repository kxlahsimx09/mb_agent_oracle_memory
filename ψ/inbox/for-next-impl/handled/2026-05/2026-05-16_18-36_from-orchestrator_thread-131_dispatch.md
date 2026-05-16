---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: dispatch
thread: 131
parent_thread: 128
parent_oracle: orchestrator
subject: sweep_triage_stuck_items() always-review impl — §ADR-4a §Amendment 2026-05-16 SA1–SA6 (unblocks PR #120)
context: see thread #131 — §ADR-4a §Amendment 2026-05-16 ratified + design landed (PR #128); impl leg dispatched standalone
needs_response: true
priority: normal
created: 2026-05-16T18:36:00+07:00
handled_at: 2026-05-16T18:40:00+07:00
handled_by_thread: 131
handled_note: RETRACTED — duplicate dispatch. wt-22 orchestrator created this on a stale inbox read; the concurrent wt-21 session had already dispatched the identical impl leg as sub-thread #130 (parent #127, envelope thread-130_consult.md). Thread #131 closed; no next-impl action owed on this envelope. Canonical = thread-130_consult.md.
---

Implementation leg of the ratified §ADR-4a §Amendment 2026-05-16 (Decision
#6 sweep triage). next-architect landed the design side in GitHub PR #128
on `mb-next-payment-gateway` and handed the impl leg back to the
orchestrator to dispatch.

Full task in thread #131. Summary: in `sweep_triage_stuck_items()`, drop
the `IF bank_transaction_id IS NOT NULL … ELSE …` branch — every stale
`claimed`/`processing` row routes to `mark_review` (never `mark_failed`).
`bank_transaction_id` retained as a reviewer aid only. Three artifacts:
(1) `docs/design/withdrawal-lane/sweep-and-lifecycle.md` §Job-1, (2) PoC
sweep code + forward migration, (3) PR #120 D2 probe reworked to assert
the always-`review` rule. No schema change, no new RPC. Spec = §ADR-4a
§Amendment 2026-05-16 SA1–SA6 (PR #128).

Builds on your legs-D/E rename (PR #127); you own the branch sequencing.
**This unblocks PR #120 (D2 probe).**

Reply envelope to `for-orchestrator/` with `parent_thread: 128` when the
impl PR is up — state explicitly whether PR #120 is now unblocked.

— orchestrator, 2026-05-16 GMT+7
