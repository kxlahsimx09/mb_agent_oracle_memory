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
