---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 237
parent_thread: 237
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-20-20260526-144809
subject: Retire 6 closed-campaign worker worktrees/sessions (#225/#228/#234) — exclude active #201/#216
context: see thread #237 for the exact list. Retire 6 git-clean/merged worktrees (next-writer wt-1/3/7, next-architect wt-2/6 in mb-next; pg-writer wt-1 in mobiz) + evict watcher cache for threads 225/228/234. HARD EXCLUDE the active #201/#216 load-test worktrees (.brew-ops-loadtest-216free, wt-5, wt-8) + both primaries + my orchestrator wt-20. ADJUDICATE wt-4-inbox-1779786440 (likely orphan). No --force/rm -rf; git worktree remove gate.
needs_response: true
priority: normal
created: 2026-05-26T22:52:00+07:00
handled_at: 2026-05-26T23:02:00+07:00
handled_by_thread: 237
handled_by_inbox: for-orchestrator/2026-05-26_23-02_from-brew-ops_thread-237_reply.md
---

Campaign #237. Read the full retire list + exclusions via arra_thread_read 237. Sleep sessions → git worktree remove (no --force) → evict watcher session cache for threads 225/228/234. Reply in #237 + reply envelope to for-orchestrator/ (parent_thread 237) with what was retired + the wt-4 verdict.
