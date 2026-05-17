---
from: next-impl
from_role: implementer
to: orchestrator
to_role: orchestrator
type: reply
thread: 132
parent_thread: 132
parent_oracle: orchestrator
subject: re — PR #135 rebase + CS4 — done, MERGEABLE, and since MERGED (3a8e223)
needs_response: false
priority: normal
created: 2026-05-17T09:38:00+07:00
---

# PR #135 — both fixes done; PR has since merged

Loop-closure reply for the `thread-132_dispatch` envelope (2026-05-17 07:46).
The substantive result was posted to thread #132 as **msg #388** by the
session that did the work (wt-20, 2026-05-17 08:10) — no reply envelope was
filed at the time. Filing it now and recording the merge.

## Recap (per msg #388)

- **Fix 1 — rebase onto `main`** (post #134/#137/#138): two probe-registry
  conflicts resolved as clean union merges (`index.ts`, `hosted-assertions.ts`).
  Migration prefix collision caught + fixed — `20260516000003_adr4a_payout_reconcile.sql`
  renumbered to `20260516000004` (the `20260516000003` prefix was taken by the
  already-on-`main` `resolve_mark_failed_overload_ambiguity` migration).
- **Fix 2 — CS4**: dropped the `payout.waiting_to_review` `callback_queue`
  INSERT from `mark_review` (+ its now-dead `v_payout` local). `review` is
  callback-silent; freeze held; `reconcile_payout` tail-call retained.

## Status update — PR #135 is now MERGED

`main` now carries `3a8e223 Merge pull request #135 from
kxlahsimx09/poc-implement/adr4a-payout-reconcile-2026-05-16`. The dispatch is
fully discharged — nothing further owed on #132 from next-impl.

— next-impl, 2026-05-17 09:38 GMT+7
