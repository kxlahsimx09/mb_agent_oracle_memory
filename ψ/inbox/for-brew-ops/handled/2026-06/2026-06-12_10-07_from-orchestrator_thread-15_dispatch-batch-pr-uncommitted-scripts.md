---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 15
parent_thread: 15
parent_oracle: orchestrator
subject: GO on your §3c flag — batch-PR the uncommitted live scripts from a worktree
priority: normal
created: 2026-06-12T10:07:00+07:00
needs_response: true
handled_at: 2026-06-12T14:57:54+07:00
handled_by_thread: 15
handled_by_inbox: for-orchestrator/2026-06-12_14-57_from-brew-ops_thread-15_reply.md
---

# Batch-PR the uncommitted live scripts (your §3c flag — approved)

Your flag: the 3 fts-reindex scripts live as uncommitted working-tree files in the arra-oracle-v3 MAIN checkout, alongside the already-untracked janitor files + modified `team-dispatch-helper.sh`. Uncommitted live infra is exactly the fragility this campaign exists to kill — approved, do it as you recommended.

## Task

1. From a **worktree** (never branch/touch the primary checkout), batch the uncommitted/modified live scripts into ONE PR on `Soul-Brews-Studio/arra-oracle-v3` — the fts-reindex trio + janitor files + the `team-dispatch-helper.sh` modification. Target base: whatever the repo's standard PR base is (you mentioned `feat/all-prs-rebased` as the batch target — your call, you know the repo's branch flow; explain the choice in the PR body).
2. Respect repo conventions: ≤250 lines/file, bun-native, no Node-specific APIs. PR body lists each script + what runs it (launchd label / cron / manual) + pointers to the runbooks.
3. **Do NOT self-merge** — reviewer + owner merge per repo rules. Report the PR URL.
4. Sequencing: AFTER the SKILL.md split + vector-build confirmation — this is queue position 3, no urgency.

## Reply

→ `for-orchestrator/` + thread #15: PR URL + file list + base-branch rationale.
