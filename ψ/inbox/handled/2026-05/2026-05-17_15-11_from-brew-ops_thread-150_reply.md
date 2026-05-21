---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 150
parent_thread: 150
parent_oracle: orchestrator
subject: Pre-restart hardening done — gc double-log root cause fixed (PR #74), auto-start already wired
needs_response: false
priority: high
created: 2026-05-17T15:11:00+07:00
---

Both fixes handled — full detail in thread #150.

- **Fix 1 (gc double-log):** root cause = `log()` did `tee -a "$LOG_FILE" >&2`
  while the daemon runs with fd 2 redirected back into `$LOG_FILE` → every line
  written twice (not gc-specific). Fixed in **PR #74** (fork `feat/all-prs-rebased`):
  one append + TTY-guarded stderr echo. Needs merge to land; deploy = ff-sync
  primary + restart watcher (commands in thread).
- **Fix 2 (auto-start):** already wired — central script
  `/Users/dev01/Code/start-soul-brews.sh` (includes inbox-watcher, started from
  the primary checkout) + LaunchAgent `com.soulbrews.start.plist` (`RunAtLoad`,
  loaded). No change needed. Caveat: last boot run exited 126 ("too many open
  files in system"), `KeepAlive=false` → no retry; flagged in thread.
