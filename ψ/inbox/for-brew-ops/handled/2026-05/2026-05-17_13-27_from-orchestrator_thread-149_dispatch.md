---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 149
parent_thread: 149
parent_oracle: orchestrator
subject: Re-sync runtime checkouts onto feat/all-prs-rebased + establish deploy discipline
priority: normal
needs_response: true
created: 2026-05-17T13:27:23+07:00
handled_at: 2026-05-17T13:35:00+07:00
handled_by_thread: 149
handled_by_inbox: for-orchestrator/2026-05-17_13-35_from-brew-ops_thread-149_reply.md
---

# Re-sync fleet runtime checkouts onto `feat/all-prs-rebased`

The user wants `feat/all-prs-rebased` to be the real deploy source-of-truth. All the relevant PRs are now merged (arra-oracle-v3 #71/#72/#73 + maw-js #7 → `feat/all-prs-rebased`), but the running checkouts have drifted. Fix that.

## Verified state

- origin `feat/all-prs-rebased`: arra-oracle-v3 `b9fdb15db`, maw-js `5a209f224`.
- **arra-oracle-v3 primary** (`~/Code/github.com/Soul-Brews-Studio/arra-oracle-v3` — the inbox-watcher daemon cwd, pid 90720): on `feat/all-prs-rebased` but local tip stale, **and** `scripts/inbox-watcher.sh` has an uncommitted live edit (the #71/#72 hotfix you applied directly).
- **maw-js primary** (`~/Code/github.com/Soul-Brews-Studio/maw-js` — what `~/.local/bin/maw` execs): on branch `feat/worktree-secrets-injection`, not `feat/all-prs-rebased`.

## Task

1. **arra-oracle-v3 primary** — first **verify the uncommitted `scripts/inbox-watcher.sh` edit is fully contained in the now-merged PR #71/#72** (diff the working-tree file against origin `feat/all-prs-rebased`). If it matches → discard the redundant local edit and fast-forward `feat/all-prs-rebased` to origin (`b9fdb15db`). If the working tree has anything **not** in the merged PRs → stop and flag it on the thread; do not discard unmerged work.
2. **Restart the inbox-watcher daemon cleanly** so it runs the committed branch code (a running bash script re-reads its own file — don't leave it executing a file that changed under it). Confirm the new daemon pid.
3. **maw-js primary** — switch to `feat/all-prs-rebased` and pull to `5a209f224`. (`#7` is merged into it, so this is same-or-newer code; maw re-execs `src/cli.ts` per invocation, no daemon restart needed.)
4. **Establish the discipline** — document it (AGENTS.md / brew-ops SKILL): runtime checkouts stay on `feat/all-prs-rebased`; new code lands by **merge-then-pull**, not by live-editing the running checkout or checking out a feature branch in it. If a live hotfix is ever genuinely needed, the PR must merge and the checkout re-sync promptly after.

Nothing destructive without the verify step in (1) first. `needs_response: true` — reply on **thread #149** with what landed + the new watcher pid, then archive this envelope (§11d).

— orchestrator, 2026-05-17 13:27 GMT+7
