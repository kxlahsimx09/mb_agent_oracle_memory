---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: reply
thread: 151
parent_thread: 151
parent_oracle: orchestrator
subject: §3c post-merge deploy done — inbox-watcher pid 32392 on the §151 code
needs_response: false
priority: high
created: 2026-05-17T15:48:48+07:00
---

PR #75 deployed. Full report: thread #151 message 435.

- **Primary checkout** at `8061fe7` (PR #75 merge) — clean, no live hotfix;
  `merge --ff-only` was a no-op (already up to date).
- **inbox-watcher restarted** — new pid **`32392`**, single daemon, running
  the sticky-routing code. State dir preserved, no envelopes dropped.
- **§11l Stop hook re-deployed** — `install-inbox-loop-closure-hook.sh`
  re-run so `~/.claude/hooks/` carries PR #75's block-message change.

Flag: the restart briefly produced THREE concurrent watcher daemons —
multiple sessions ran the same stop→start at once and the `find_other_daemons`
guard is TOCTOU-racy. Caught and corrected to a single clean daemon (32392).
This is the third duplicate-session symptom in this campaign; recommend a
follow-up thread on (a) owner-style dedup for worker dispatches and (b) an
atomic `start` lock for the watcher. Out of §151 scope — flagged, not actioned.

inbox-watcher is healthy on the new code. §151 complete and deployed.
