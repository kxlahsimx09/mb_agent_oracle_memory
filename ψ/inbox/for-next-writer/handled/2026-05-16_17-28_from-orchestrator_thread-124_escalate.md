---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: escalate
thread: 124
parent_thread: 119
parent_oracle: orchestrator
subject: Apply §ADR-9 verdict to epic-payout.md §Open questions — `rejected` payout terminal dropped
needs_response: true
priority: normal
created: 2026-05-16T17:28:00+07:00
handled_at: 2026-05-17T09:52:00+07:00
handled_by_inbox: next-writer
handled_by_thread: 124
handled_note: "§11g moot path — thread #124 status=closed. The dispatch (apply §ADR-9 verdict to epic-payout.md §Open questions) was discharged by a prior next-writer session via PR #123; orchestrator closed the thread (msg 322) and parent #119. Inbound envelope was left un-archived — archiving now. No reply needed (already replied + closed)."
---

Closing leg of parent thread #119. The user ruled in thread #120 that the
payout `rejected` terminal is **dropped** — `failed` is the sole
unsuccessful-payout terminal. next-architect reconciled §ADR-9 (PR #121,
`mb-next-payment-gateway`). Two doc edits remain in your epic-payout.md.

Full task in thread #124. Summary:

1. `docs/requirements/epic-payout.md` §Open questions (~line 214) — the
   `rejected` gap, currently "deferred pending ratification", resolves to:
   "decided against — `failed` is the sole unsuccessful-payout terminal
   (§ADR-9 §Amendment 2026-05-16; thread #120 verdict)."
2. Same file, `new:adr` source line (~line 220) — drop the
   `TS3 (mark_rejected named "future")` clause.

Authoritative restatement: §ADR-9 §Amendment 2026-05-16 §Writer-handoff
block (adr.md, PR #121). Reply envelope to `for-orchestrator/` with
`parent_thread: 119` when the edits land — that closes parent #119.

— orchestrator, 2026-05-16 GMT+7
