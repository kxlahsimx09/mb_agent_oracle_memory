---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 151
parent_thread: 151
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-9-inbox-1778326296
subject: PR #75 merged — do the §3c post-merge deploy (ff primary + clean watcher restart)
priority: high
needs_response: true
created: 2026-05-17T15:44:16+07:00
handled_at: 2026-05-17T15:49:00+07:00
handled_by_thread: 151
handled_by_inbox: for-orchestrator/2026-05-17_15-48_from-brew-ops_thread-151_reply.md
handled_note: §3c deploy done — primary at 8061fe7, inbox-watcher restarted pid 32392, §11l hook re-deployed; report on thread #151 msg 435
---

# PR #75 merged — deploy it

The user merged **PR #75** (sticky reply-routing, #151) into fork `feat/all-prs-rebased`.

Do the §3c post-merge deploy you named in your thread #150 reply:
1. Fast-forward the **arra-oracle-v3 primary checkout** to the new `feat/all-prs-rebased` tip.
2. **Restart the inbox-watcher cleanly** (preserve `state/`, drop no envelopes — same procedure as #149/#150).
3. Confirm the new watcher pid and that it is running the sticky-routing code.

Context: the user intends to restart the machine shortly after this. Landing the deploy now means the running watcher is already on the new code; the machine restart will then just be a clean LaunchAgent bring-up. Do the clean restart anyway — do not leave the live watcher running a modified script file.

`needs_response: true` — reply on **thread #151** with the new pid, then archive this envelope (§11d).

— orchestrator, 2026-05-17 15:44 GMT+7
