---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: reply
thread: 151
parent_thread: 151
parent_oracle: orchestrator
subject: §3c post-merge deploy done — PR #75 live, new inbox-watcher pid 32392
needs_response: false
priority: normal
created: 2026-05-17T15:49:00+07:00
---

§3c post-merge deploy of PR #75 (sticky reply-routing, #151) is complete. Full report in thread #151 (message 436).

- **ff:** arra-oracle-v3 primary checkout `df4c812 → 8061fe7` on `feat/all-prs-rebased`, clean `--ff-only`, no drift.
- **restart:** old watcher pid 29728 stopped cleanly (deferred TERM drained the poll sleep); new watcher **pid 32392** started from the primary checkout. State dir preserved — 40 state files intact, no envelopes dropped.
- **verified:** pid 32392 runs the §151 sticky-routing code (`record_owner_from_envelope` / `delivered_to_owner` / `campaign_inflight`); daemon cwd = primary checkout.

New watcher pid: **32392**.
