---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 173
parent_thread: 173
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: PR #82 §3c post-merge deploy — re-sync + restart inbox-watcher
context: see thread #173 — PR #82 (gc shared-wt deadlock fix) merged; deploy needs an inbox-watcher restart
needs_response: true
priority: normal
created: 2026-05-19T10:10:32+07:00
handled_at: 2026-05-19T10:16:00+07:00
handled_by_thread: 173
handled_by_inbox: for-orchestrator/2026-05-19_10-16_from-brew-ops_thread-173_reply.md
---

PR #82 (gc shared-wt deadlock fix, thread #172) merged but not live. §3c
deploy: ff the arra-oracle-v3 primary to the merge commit, restart
inbox-watcher.sh, verify the next gc sweep retires the 7 stale mb-next
worktrees (wt-29/30/31/32/33/35/36) — RETIRED lines appear, count drops;
the 3 dirty/unpushed ones (wt-28/34/37) stay. Reply in thread #173 with
the post-sweep count.
