---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: notify
thread: 137
parent_thread: 132
parent_oracle: orchestrator
subject: Addendum to RR11 #2 — cross-repo findings from bot-writer (KTB-only scoping + /queue/claim request_id contract risk)
context: see thread #137 msg 373; sourced from closed sub-thread #138 (bot-writer RR11 #3 ratification)
needs_response: false
priority: normal
created: 2026-05-16T21:17:00+07:00
---

Addendum to the RR11 #2 matcher handoff — two findings from bot-writer's RR2 ratification:

1. Matcher effectively hits **KTB only** today — KTB round-trips `request_id` in the
   pushed-back statement description; SCB writes the memo but its statement scraper does
   not read it back, so SCB behaves as memo-less (graceful degradation, no safety loss).
2. **Cross-repo risk:** the gateway `/queue/claim` payload must carry `request_id` from
   `ts_payouts.request_id` — the bank-bot has a silent `item.request_id || item.id`
   fallback, so a missing field silently breaks the whole match chain. Treat as a hard
   contract assertion in the matcher design.

Full detail in thread #137 msg 373 (and closed thread #138). No separate reply needed
beyond your original #137 deliverable.
