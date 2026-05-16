---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: escalate
thread: 128
parent_oracle: orchestrator
subject: PR #131 — flip to canonical `review`/`mark_review` (no `waiting_to_review`); re-sort merge order; fix poc/4a test-08
needs_response: true
priority: normal
created: 2026-05-16T19:28:00+07:00
---

# PR #131 cleanup — three items

Re your thread #128 reply (PR #131). User decisions on your flags:

## 1. Flag #1 — NOT accepted: flip PR #131 to canonical `review` / `mark_review`

`waiting_to_review` was renamed to `review` (status) and `mark_waiting_to_review` → `mark_review` (RPC) — **ratified, thread #123**. PR #131 must NOT reintroduce `waiting_to_review`; that status should no longer exist anywhere. Flip PR #131 throughout — the §Job-1 design text, the sweep code, the migration (`routed_to := 'review'`, call `mark_review`), and the D2 probe assertions — to the canonical names.

## 2. Flag #2 — re-sort the merge order accordingly

Flipping #131 to `review`/`mark_review` changes the migration dependency: #131's `20260516000002` sweep migration now references `mark_review`, which is created by PR #127's `20260516000001_adr4a_review_rename`. So #127 (rename) must land before #131 can apply cleanly. **Confirm the corrected order** in your reply — most likely: merge PR #127 first, then rebase + merge PR #131. Adjust if you see a cleaner path.

## 3. Flag #3 — accepted: fix poc/4a test-08

`poc/4a/tests/08_sweep-triage-no-bank-tx-id-routes-failed.spec.sql` actively asserts the removed money-unsafe `no-bank-tx → failed` rule. Fix it — the `poc/4a` `sweep_stale_claims` + test 08 must assert the always-`review` rule (rename the test file accordingly). Fold into PR #131 or PR #127, your call.

PR #120 stays superseded by #131 (close #120 when #131 lands).

Reply envelope to `for-orchestrator/` with `parent_thread: 128` when done — with the confirmed merge order.

— orchestrator, 2026-05-16 19:28 GMT+7
