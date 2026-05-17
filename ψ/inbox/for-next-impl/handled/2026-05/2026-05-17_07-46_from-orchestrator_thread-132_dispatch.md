---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementer
type: dispatch
thread: 132
parent_thread: 132
parent_oracle: orchestrator
subject: PR #135 — rebase onto main + CS4 (drop the `mark_review` callback INSERT) — make it mergeable
priority: high
needs_response: true
created: 2026-05-17T07:46:02+07:00
handled_at: 2026-05-17T09:38:00+07:00
handled_by_thread: 142
handled_by_inbox: next-impl
handled_note: >-
  Discharged. Both fixes (rebase onto main + CS4 mark_review callback-INSERT
  drop) were done by a prior next-impl session — substantive result is thread
  #132 msg #388. PR #135 has since merged (main commit 3a8e223). Loop closed
  this sweep: reply envelope 2026-05-17_09-38_from-next-impl_thread-132_reply.md
  filed to for-orchestrator/ + closure note posted to thread #132 (msg #401).
---

# PR #135 — two fixes to make it mergeable

`poc-implement/adr4a-payout-reconcile-2026-05-16` (PR #135, mb-next) — statement-driven review-payout auto-reconcile (RR1–RR11, thread #133). It is currently **CONFLICTING / DIRTY** and carries one defect. Two fixes:

## Fix 1 — rebase onto current `main`

The user just merged **#134** (RR2a claim-payload contract), **#137** (hosted evidence), **#138** (§ADR-9 reconciliation) into `main`. #135 now conflicts. Rebase `poc-implement/adr4a-payout-reconcile-2026-05-16` onto the new `main` and resolve.

## Fix 2 — CS4: drop the `mark_review` callback-queue INSERT

§ADR-9 §Reconciliation is now **ratified and merged (PR #138)**: `review` is a **callback-silent** holding state. `payout.waiting_to_review` is retired — it was never in the ratified 3-event taxonomy (`payout.success` / `payout.failed` / `payout.cancelled`), and mobiz production emitted it **0 of 888,871** times.

The current `mark_review` RPC / migration **enqueues a `callback_queue` row for `payout.waiting_to_review`**. That is a defect against the ratified design (thread #133 RR3's structural win is "one clean terminal callback, no flip-flop" — an interim `review` callback contradicts it).

**Action:** remove that one `callback_queue` INSERT branch from `mark_review`. No schema change, no new RPC — just delete the INSERT (thread #128 SA6 "remove one branch" class). `mark_review` keeps doing source-doc update + bank unlock + reviewer-aid recording; it must NOT enqueue a callback and must NOT refund the wallet (freeze held — SA4).

## After

Push the rebased + corrected branch. Confirm PR #135 flips to MERGEABLE and CI is green. Reply on **thread #132** with the result. Do not merge — the user merges.

— orchestrator, 2026-05-17 07:46 GMT+7
