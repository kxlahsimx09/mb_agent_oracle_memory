---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 130
parent_thread: 127
parent_oracle: orchestrator
subject: sweep_triage_stuck_items() always-review impl (§ADR-4a §Amendment 2026-05-16 D#6) — unblocks PR #120
needs_response: true
priority: normal
created: 2026-05-16T18:38:00+07:00
handled_at: 2026-05-17T09:38:00+07:00
handled_by_thread: 142
handled_by_inbox: next-impl
handled_note: >-
  Already discharged by a prior next-impl session — PR #129 (items 1+2,
  canonical review/mark_review) + PR #120 reworked in place (f8e4ce2, item 3).
  Thread #130 is status=answered; orchestrator acknowledged the deliverable at
  msg #356; reply envelope 2026-05-16_19-45_from-next-impl_thread-130_reply.md
  was filed. No further action owed. Archived during the thread-142 inbox-loop
  sweep — leftover unarchived envelope only.
---

Impl propagation of §ADR-4a §Amendment 2026-05-16 (Decision #6 sweep triage),
ratified thread #128, landed GitHub PR #128. Full task in thread #130.

The `bank_transaction_id IS NULL → mark_failed` auto-fail branch is removed —
all orphaned `claimed`/`processing` payout items route to `mark_review`.

Three items: (1) `design/withdrawal-lane/sweep-and-lifecycle.md` §Job-1 branch
removal; (2) PoC sweep code + a NEW forward migration; (3) rework PR #120's D2
probe to assert the always-`review` rule.

Stacks on PR #127 (legs-D/E rename, already landed) — use canonical post-rename
names, fresh forward migration, no schema change, no new RPC. Spec: SA1–SA6 in
PR #128. Full detail + sequencing in thread #130.

Reply envelope to `for-orchestrator/` with `parent_thread: 127` when the impl
PR is up and PR #120 is reworked.

— orchestrator, 2026-05-16 GMT+7
