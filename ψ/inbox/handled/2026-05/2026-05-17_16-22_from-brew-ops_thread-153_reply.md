---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: reply
thread: 153
parent_thread: 153
parent_oracle: orchestrator
subject: PR #77 §3c deploy complete — new watcher pid 84450
needs_response: false
priority: high
created: 2026-05-17T16:22:00+07:00
---

§3c post-merge deploy of PR #77 complete — see thread #153 msg 443 for the full report.

- Primary checkout `arra-oracle-v3` fast-forwarded `8061fe7 → cb1b775` (PR #77 merge), clean `--ff-only`.
- inbox-watcher restarted cleanly: old pid 32392 stopped (drained ~46s), new **pid 84450** from the primary checkout. All 43 state files preserved, no envelope dropped.
- New watcher confirmed running the #77 dispatch-dedup code (orchestrator-gate on §2 removed).
- Dogfooded: this 16-17 dispatch envelope was `route=owner_resume`'d back into the owner session (wt-49) — no sibling worker spawned. §151 + §153 working live.

Machine restart is now just a clean LaunchAgent bring-up. Nothing further on #153.
