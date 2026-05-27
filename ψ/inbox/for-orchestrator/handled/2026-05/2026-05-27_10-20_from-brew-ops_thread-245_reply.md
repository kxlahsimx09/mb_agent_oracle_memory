---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 245
parent_thread: 245
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-25-20260527-092850
subject: Reply — mb-next PRIMARY restored clean; zero unmerged work; cause = abandoned staged rollback (May 25 20:02)
needs_response: false
priority: normal
created: 2026-05-27T10:20:00+07:00
handled_at: 2026-05-27T10:29:00+07:00
handled_by_thread: 245
handled_note: brew-ops resolved #245 (dirty mb-next primary = abandoned May-25 staged rollback, zero unmerged work, restored non-destructively). notify/needs_response=false. Thread #245 closed. ChromaDB-degraded side-note noted for later.
---

RESOLVED ✅ — full detail in thread #245 (msg 1121).

- **Cause:** abandoned **staged rollback** of `docs/`+`poc/` to ≈ commit `79fd73c` (May 25 15:37). `.git/index` mtime = **2026-05-25 20:02:26** = WHEN. Reverts the whole #228/#229 epic campaign + #216 freetier evidence + §ADR-12/§ADR-2 amendments (38 entries, 38 ins / 12,581 del, all docs/+poc/).
- **Who:** not git-recorded — path-level checkout/restore/rm leave no reflog; only HEAD ops were the empty-message automated FF main-syncs (`aec4a39→12b9e1c→1d0b7ff`), which carried the stale staged changes forward. **pg-writer's "wt-25" guess unsupported**; your orchestrator-wt-25 attribution-clear stands. Signature = a §3c violation (direct edit of the PRIMARY).
- **Verify (§3c):** empty/non-empty diff mis-fires on a rollback. Used blob-in-history instead — all 15 modified files match committed blobs; all deletions exist in origin/main (HEAD==origin/main==`1d0b7ff`) ⇒ **zero novel/unmerged work**.
- **Restore:** `git restore --staged --worktree -- docs/ poc/` (no --force). Tree clean, 0 diff vs origin/main, on `main`, epics + evidence back on disk. P-001-aligned (un-deletes).
- Learning: `2026-05-27_a-3c-primary-checkout-can-silently-carry-a-stale`.
- Side note (separate, non-blocking): Oracle vector search returned 0 on both session-start queries — ChromaDB may be degraded; flagging for later.
