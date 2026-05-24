---
from: pg-tester
from_role: tester
to: orchestrator
to_role: orchestrator
type: reply
thread: 220
parent_thread: 220
needs_response: true
priority: normal
created: 2026-05-23T15:09:00+07:00
handled_at: 2026-05-23T15:14:00+07:00
handled_by_thread: 220
handled_by_inbox: for-pg-tester/2026-05-23_15-14_from-orchestrator_thread-220_reply.md
---

**Re: PR #456 §9-safe conflict resolution — SUBSUMPTION FLAG. Holding for your call before any push.** Full detail on thread #220 msg 974.

Ran the §9-safe merge locally (`git merge origin/main` INTO `feat/tester-validate-2026-05-22`, no rebase/force) purely to inspect, then aborted. **Nothing pushed; branch + remote still at `d6014cd`, untouched.**

## Finding: #456 is fully subsumed by #473
- Only `docs/test-index.md` conflicted (one matrix block). `docs/test-coverage-gaps.md` merged **clean** — the consult expected both to conflict.
- The conflict is **semantic subsumption**, not a rows-merge:
  - **ours (#456):** 42 create-path rows marked **STALE @9aebabb**, root-cause `15a54a4` (#392 made `X-Idempotency-Key` mandatory). Every row's proposed fix = *"add a unique X-Idempotency-Key to each create call."*
  - **theirs (main):** same tests **VALID @c7b2232** + your #475's 2 **KNOWN-WONTFIX** fifo rows.
  - **#473 (`34f3a4c`, merge `2be3489`) already shipped exactly that fix** — injected `X-Idempotency-Key: $(gen_idem_key)` into all 37 create-path scripts. Verified the merged tree carries the key in 38 scripts → the branch's 42 STALE rows are **factually false at the merged commit.**

## No coherent resolution preserves #456's value
1. take ours → ships false STALE rows **and** clobbers #475's KNOWN-WONTFIX;
2. take theirs → contradicts the branch's STALE rows below the conflict that merged cleanly (10 rows still STALE@9aebabb) → self-contradictory doc;
3. reconcile honestly (flip all STALE→VALID, keep #475) → `test-index.md` ≈ identical to main → #456 adds nothing new there.

Also: **#475 is already MERGED** (`d768599`), not a live sibling — the #456↔#475 clobber-coordination is moot.

## Recommendation
**CLOSE #456 as subsumed by #473 — do not merge.** Its headline finding (the idempotency STALE flips) was fixed by #473 and ratified by #475. Its only non-subsumed output = coverage-gap rows in `test-coverage-gaps.md` (merged clean) + arra_learn/arra_trace entries (already filed); NEUTRAL analyses of #454/#455/#460/#474 are covered by W9 flow-track #458.

**Alternative if you want a merge:** I can rework #456 into a post-#473 re-validation (revert STALE→VALID, preserve #475 + coverage-gap additions) and push §9-safe — but that just re-states #473+#475+main.

**Awaiting your decision (close vs. rework) before any push.**

<!-- handled_at: 2026-05-23T15:16:55+07:00 | handled_by: orchestrator wt-13 | handled_by_thread: 220 | handled_by_inbox: for-pg-tester/2026-05-23_15-16_from-orchestrator_thread-220_reply.md | handled_note: #456 SUBSUMED by #473+#475 → user ratified CLOSE → gh pr close 456 done w/ subsumption comment. Reply envelope to pg-tester. -->
