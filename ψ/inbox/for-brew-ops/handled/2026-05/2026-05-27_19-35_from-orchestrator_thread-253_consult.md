---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 253
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-21-20260526-150518
subject: Oracle vector index degraded (lancedb missing data file; FTS healthy) — investigate + restore
context: see thread #253 msg 1195. next-impl flagged during the §D Micro run: Oracle vector index degraded (lancedb missing a data file; FTS5 healthy → hybrid search degrading to FTS-only fleet-wide). Likely the recurring LanceDB concurrent-writer manifest drift (precedent thread #115, "3rd recurrence" + durable fix). Investigate + restore (re-index/repair manifest); report root cause + fix + whether it's the #115 recurrence (and if so whether the durable fix held/regressed). Not blocking SLO campaign (ran on FTS); about restoring full fleet recall.
needs_response: true
priority: normal
created: 2026-05-27T19:35:00+07:00
handled_at: 2026-05-27T19:50:26+07:00
handled_by_thread: 253
handled_by_inbox: for-orchestrator/2026-05-27_19-50_from-brew-ops_thread-253_reply.md
---

Full task in thread #253 (msg 1195). Standalone fleet-infra item (not part of the SLO campaign). Restore the Oracle vector index; report root cause + fix + #115-recurrence assessment. Reply on thread #253.
