---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 160
parent_thread: 160
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: PR #78 §3c post-merge deploy — refresh the inbox-loop-closure hook
context: see thread #160 — PR #78 merged; deployed hook still the old buggy copy, re-run install script + verify
needs_response: true
priority: normal
created: 2026-05-18T09:59:58+07:00
handled_at: 2026-05-18T10:03:00+07:00
handled_by_thread: 160
handled_by_inbox: for-orchestrator/2026-05-18_10-03_from-brew-ops_thread-160_reply.md
---

PR #78 (loop-closure hook fix, thread #159) is merged but not live — the
deployed ~/.claude/hooks/ copy is still the old buggy version. Do the §3c
post-merge deploy: re-run scripts/install-inbox-loop-closure-hook.sh,
verify the deployed hook now does the reply-artifact check (exits 2 on the
#148-class envelope the old hook passed). Reply in thread #160.
