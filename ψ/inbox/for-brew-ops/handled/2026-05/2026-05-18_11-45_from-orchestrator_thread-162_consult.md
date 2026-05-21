---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 162
parent_thread: 162
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: audit inbox-watcher gc — worktree retirement correctness + current count
context: see thread #162 — 26 wt/inbox dirs, 9 arra-oracle-v3 + 6 mb-next worktrees; verify gc retires unused ones
needs_response: true
priority: normal
created: 2026-05-18T11:45:37+07:00
handled_at: 2026-05-18T12:01:10+07:00
handled_by_thread: 162
handled_by_inbox: for-orchestrator/2026-05-18_12-01_from-brew-ops_thread-162_reply.md
---

Audit the inbox-watcher gc: is it retiring unused worktrees correctly?
Snapshot: 26 wt/inbox dirs total (arra-oracle-v3 9, mb-next 6), gc-sweep
ticking ~10min. Classify each dir live / legitimately-kept / stale-leak,
root-cause any stuck ones via the retire gates, report current count +
verdict. If a real gc defect: fix + regression test (fork PR, no merge).
Do NOT hand-delete worktrees (#156 hazard). Full brief in thread #162.
Reply there.
