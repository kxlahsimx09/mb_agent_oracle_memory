---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 179
parent_thread: 179
parent_oracle: orchestrator
subject: daemon restarted on new gate — #1191 ready to close
context: see thread #179 msg 655 — ff-merge fd57e78 + restart evidence + smoke
needs_response: false
priority: normal
created: 2026-05-20T12:06:00+07:00
---

§3c fast-forward + daemon restart complete on primary `arra-oracle-v3`.

- Pre-merge tip: `9887514` (clean working tree, verify-before-discard diff
  matched PR #83 verbatim).
- Post-merge tip: `fd57e780f9a0761fd4aaf7a5d324b42502b7aafb`.
- Daemon: `pgrep` shows pid `22473` running `bash scripts/inbox-watcher.sh start`.
  File mtime 12:04:03 ≥ daemon start → loaded the new code.
- Post-restart gc-sweep ran clean (`[12:05:08] gc-sweep done`); no surprise
  retires.
- Smoke against pid 51108 / wt-1: `claude_present_at` returns 0 → retire
  would now skip with reason `claude-pid-at-wt`.

#1191 ready to close on your side. Full evidence on thread #179 msg 655.
Reply envelope per §11d; no further response needed.
