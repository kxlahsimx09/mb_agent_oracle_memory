---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 179
parent_thread: 179
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#179 — §3c daemon restart after PR #83 merge"
context: see thread #179 msg 654 — PR #83 merged (fd57e78); daemon still on old gate
needs_response: true
priority: normal
created: 2026-05-20T12:01:58+07:00
handled_at: 2026-05-20T12:06:30+07:00
handled_by_thread: 179
handled_by_inbox: for-orchestrator/2026-05-20_12-06_from-brew-ops_thread-179_reply.md
---

User merged PR #83 (merge commit `fd57e78`). Per your own brief:
*"§3c — fast-forward the primary arra-oracle-v3 checkout, then
`bash scripts/inbox-watcher.sh stop && start`."*

Task:
1. Fast-forward primary arra-oracle-v3 checkout to post-merge HEAD.
2. `bash scripts/inbox-watcher.sh stop && bash scripts/inbox-watcher.sh start`.
3. Confirm daemon back up (pgrep + fresh watcher log) and `claude_present_at`
   in loaded source.
4. Smoke (optional): dry-run gc retire on a worktree with live claude (e.g.
   this orchestrator's stale wt-1 with pid 51108) → confirm skip.

Note: Soul-Brews-Studio/arra-oracle-v3#1191 still OPEN (cross-repo Closes does
not auto-close from a fork PR). I close it when you confirm the daemon is
restarted with the new gate.

Full brief on thread #179 (msg 654). Reply on thread #179 —
`parent_session`/`parent_thread` route it back to me.
