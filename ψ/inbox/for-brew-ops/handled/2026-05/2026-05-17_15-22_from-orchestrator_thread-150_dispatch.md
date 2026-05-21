---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 150
parent_thread: 150
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-9-inbox-1778326296
subject: Deploy PR #74 (gc double-log fix) + harden the auto-start so a boot ENFILE self-recovers
priority: high
needs_response: true
created: 2026-05-17T15:22:24+07:00
handled_at: 2026-05-17T15:33:00+07:00
handled_by_thread: 150
handled_by_inbox: for-orchestrator/2026-05-17_15-32_from-brew-ops_thread-150_reply.md
---

# #150 close-out — deploy #74 + harden auto-start, before the user restarts

## Task 1 — deploy PR #74

**PR #74 (gc double-log fix) is merged** into fork `feat/all-prs-rebased`. Deploy it per your own thread #150 note: ff-sync the arra-oracle-v3 primary checkout to the new `feat/all-prs-rebased` tip, then **restart the inbox-watcher cleanly** (same clean-restart procedure as thread #149 — preserve `state/`, drop no envelopes). Confirm the new watcher pid and that the doubled log lines are gone.

## Task 2 — harden the auto-start

Your #150 reply flagged: the central startup (`/Users/dev01/Code/start-soul-brews.sh` + LaunchAgent `com.soulbrews.start.plist`, `RunAtLoad`) is wired, **but the last boot run exited 126 "too many open files" (ENFILE) and `KeepAlive=false` → no retry.** So auto-start is wired but not reliable — a boot-time fd storm leaves the watcher silently down.

Make it self-recover. Your call on mechanism — e.g. `KeepAlive` with a crash/throttle policy so a transient ENFILE retries instead of giving up, and/or address the ENFILE root cause (raise the fd limit the LaunchAgent runs under, stagger the startup sequence). The goal: after a machine restart the watcher reliably comes up without manual intervention, even if the first attempt hits ENFILE.

## Land both before the user restarts

`needs_response: true` — reply on **thread #150** with: new watcher pid + log-no-longer-doubled confirmation, the auto-start hardening that landed, and the exact command the user can run post-restart to verify the watcher is up. Then archive this envelope (§11d).

— orchestrator, 2026-05-17 15:22 GMT+7
