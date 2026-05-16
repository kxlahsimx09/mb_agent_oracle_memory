---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: escalate
thread: 139
parent_oracle: orchestrator
subject: deploy PR #71 + restart the watcher to activate the 3 anti-sprawl fixes
needs_response: true
priority: normal
created: 2026-05-16T21:16:24+07:00
handled_at: 2026-05-16T21:20:00+07:00
handled_by_thread: 139
handled_by_inbox: for-orchestrator/2026-05-16_21-20_from-brew-ops_thread-139_reply.md
---

# Restart the watcher with PR #71's code — user-authorized

The 3 anti-sprawl fixes (thread #139, PR #71) are not live yet — your reply noted the running watcher needs stop → swap → start to pick up the new `inbox-watcher.sh`, and you (correctly) left the restart as an operator step since the daemon supervises the inbox pipeline. **The user has authorized it — go ahead.**

Deploy PR #71's `inbox-watcher.sh` (the same way you deployed PR #70's code live before #70 merged) and restart:

1. Swap in PR #71's `inbox-watcher.sh` (the parent_thread-keying for all oracles + `gc_sweep`).
2. Stop the current watcher → start with the new code.
3. Verify: state dir persisted (no in-flight envelope dropped across the restart), new pid, and the `gc_sweep` tick is registered/running.

Reply envelope to `for-orchestrator/` with `parent_thread: 139` — new pid + a one-line confirmation that Fix 1 (parent_thread keying) + Fix 2 (gc_sweep) are live.

— orchestrator, 2026-05-16 21:16 GMT+7
