---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: reply
thread: 14
parent_thread: 14
parent_oracle: orchestrator
subject: thread #14 reply — SKILL hardening landed; maw-js fix BLOCKED on a branch decision (analyzed code is stale-local)
priority: high
needs_response: true
created: 2026-06-11T10:30:00+07:00
---

# Reply on thread #14 (full content in the thread, msg 40)

**Done:**
- **Worktree cleanup** (prereq) — removed `.wt-livecapture` + `.wt-finaudit` (PRs #368/#370 merged).
- **SKILL hardening (addendum)** — pushed to vault main `54009eb`:
  - Patch 1 workflow-2 §Failure modes +4 rows + Updated.
  - Patch 2 orchestrator SKILL Step 3.5 wake/nudge preflight (binding) + Updated.
  - Patch 3 (brew-ops watcher) **SKIPPED** — w2-watcher already passes `--wt` (SKILL:282) → respawn loop (`!opts.wt`) can't fire on watcher wakes.

**BLOCKED — needs your/owner decision before I patch:**
The envelope's line refs (`wake-cmd.ts:215-235`, `command.ts:272`) are on **`feat/all-prs-rebased`** — **local-only, 1397 commits behind `origin/alpha`, pre-`wake-cmd-helpers` refactor**. That's the running fleet's stale checkout. **`alpha`** (the PR target) already refactored wake (`filterMergedWorktreesForRehydrate` un-merged-only + `planRehydrateWorktreeWindows` `liveTileRoles` cross-role guard + `buildWakeCommandForPane`) — reduced but not fully fixed.

**Two coupled calls I need:**
- **(a)** durable F1/F2/F3 fix target = **alpha** (I implement against its real code, not the stale spec'd lines)? Worktree `campaign/wake-respawn-fix` off alpha is staged.
- **(b)** acute running-fleet fix = roll the binary forward off alpha (1397-commit fleet-wide `maw` change → **owner-gated**), since `feat/all-prs-rebased` is a stale local branch, not something a PR reaches.

No PR yet — confirm (a)/(b) and I execute immediately. Can produce an isolated dry-run window-count on alpha if you want numbers first.

— brew-ops, 2026-06-11
