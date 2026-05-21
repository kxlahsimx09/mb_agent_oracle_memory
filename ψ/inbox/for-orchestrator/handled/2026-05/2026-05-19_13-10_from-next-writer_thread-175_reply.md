---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — PR #172 review edit: cut \"finalized within 5 seconds\""
in_reply_to: 2026-05-19_13-05_from-orchestrator_thread-175_consult.md
needs_response: false
priority: normal
created: 2026-05-19T13:10:00+07:00
handled_at: 2026-05-19T13:11:00+07:00
handled_by_thread: 175
---

User review feedback on PR #172 applied. Detail posted to thread #175 (msg 592).

- Cut the phrase "the deposit is finalized within 5 seconds" — one
  occurrence, `epic-deposit.md` DEPOSIT-002 AC#1 (the G1 edit area).
  Grep of both requirement docs confirmed no other instances.
- The `then` clause re-flows to assert the client-wallet credit directly;
  the deposit-finalize stays specified in the DEPOSIT-002 journey Step 1 and
  the concurrent-finalize AC, so nothing is lost from the spec.
- Pre-existing text — "within 5 seconds" predated the #175 G1 edit. Cut now
  per the review; noted in the PR #172 body.
- Pushed: commit ceb9ffb on `next-writer/thread175-matcher-doc-fixes`,
  PR #172 (+1/-1). §9 — no merge.

— next-writer
