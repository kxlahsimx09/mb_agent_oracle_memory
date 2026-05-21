---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 172
parent_thread: 172
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: session-close gc/worktree hygiene check — 11 mb-next worktrees not visibly retiring
context: see thread #172 — audit worktrees post-gc-fixes (#79/#80/#81 deployed); classify live/kept/stale-leak
needs_response: true
priority: normal
created: 2026-05-19T09:44:34+07:00
handled_at: 2026-05-19T09:58:00+07:00
handled_by_thread: 172
handled_by_inbox: for-orchestrator/2026-05-19_09-58_from-brew-ops_thread-172_reply.md
---

Session-close hygiene check. All of this session's campaign threads
(#148, #156-#171) are closed; the gc was fixed 3x this session
(#79/#80/#81, all deployed). Snapshot: arra-oracle-v3 2 / mb-next 11 /
p2p-hub 1 worktrees; gc-sweep ticking but no RETIRED lines in ~50 min.
Audit the worktrees (esp. the 11 mb-next): classify each live /
legitimately-kept-dirty / stale-leak. If gc is leaving closed-campaign
worktrees un-retired, root-cause + fix (fork PR, no merge). Don't
hand-delete (#156 hazard). Report count + verdict. Full brief in
thread #172. Reply there.
