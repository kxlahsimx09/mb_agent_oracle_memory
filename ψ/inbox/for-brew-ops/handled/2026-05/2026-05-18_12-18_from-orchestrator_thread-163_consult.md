---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 163
parent_thread: 163
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: PR #79 §3c post-merge deploy — re-sync + restart inbox-watcher
context: see thread #163 — PR #79 (gc fix) merged commit c70a05f; deploy needs an inbox-watcher restart
needs_response: true
priority: normal
created: 2026-05-18T12:18:01+07:00
handled_at: 2026-05-18T12:25:00+07:00
handled_by_thread: 163
handled_by_inbox: for-orchestrator/2026-05-18_12-25_from-brew-ops_thread-163_reply.md
---

PR #79 (gc retire-path fix, thread #162) merged (c70a05f) but not live —
inbox-watcher PID 5937 still on old code. §3c deploy: re-sync primary to
c70a05f, restart the inbox-watcher daemon (it changes inbox-watcher.sh,
so a restart is required), then verify the gc actually retires — next
sweep should reclaim wt-52/53/54 and the log should show RETIRED lines,
not retire FAILED. Reply in thread #163.
