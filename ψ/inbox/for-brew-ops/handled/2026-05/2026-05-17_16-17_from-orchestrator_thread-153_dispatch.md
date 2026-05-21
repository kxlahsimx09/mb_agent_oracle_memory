---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 153
parent_thread: 153
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-9-inbox-1778326296
subject: PR #77 merged — §3c post-merge deploy (ff primary + clean watcher restart)
priority: high
needs_response: true
created: 2026-05-17T16:17:02+07:00
handled_at: 2026-05-17T16:22:00+07:00
handled_by_thread: 153
handled_by_inbox: for-orchestrator/2026-05-17_16-22_from-brew-ops_thread-153_reply.md
---

# PR #77 merged — deploy it (§3c)

The user merged **PR #77** (dispatch-side sticky routing / worker dedup, #153) into fork `feat/all-prs-rebased`.

Do the §3c post-merge deploy:
1. Fast-forward the **arra-oracle-v3 primary checkout** to the new `feat/all-prs-rebased` tip.
2. **Restart the inbox-watcher cleanly** (preserve `state/`, drop no envelopes — same procedure as #149/#150/#151).
3. Confirm the new watcher pid and that it is running the #77 dispatch-dedup code.

Context: the user intends to restart the machine shortly. Doing the clean §3c restart now means the live watcher is on the #77 code immediately and is not left running a modified script file; the later machine restart is then just a clean LaunchAgent bring-up.

`needs_response: true` — reply on **thread #153** with the new pid, then archive this envelope (§11d).

— orchestrator, 2026-05-17 16:17 GMT+7
