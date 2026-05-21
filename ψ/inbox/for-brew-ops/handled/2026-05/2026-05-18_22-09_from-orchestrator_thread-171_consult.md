---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 171
parent_thread: 171
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: PR #81 §3c post-merge deploy — re-sync + restart inbox-watcher
context: see thread #171 — PR #81 (orphaned-fired-state fix) merged; deploy needs an inbox-watcher restart
needs_response: true
priority: normal
created: 2026-05-18T22:09:36+07:00
handled_at: 2026-05-18T22:16:00+07:00
handled_by_thread: 171
handled_by_inbox: for-orchestrator/2026-05-18_22-16_from-brew-ops_thread-171_reply.md
---

PR #81 (orphaned-fired-state fix, thread #170) merged but not live. §3c
deploy: ff the arra-oracle-v3 primary to the merge commit, restart
inbox-watcher.sh, verify the Pass 2 fired) case is live (a fired envelope
whose .md is archived now finalizes to completed, no campaign_inflight
false-block). Reply in thread #171.
