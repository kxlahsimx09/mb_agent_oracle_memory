---
from: orchestrator
from_role: orchestrator
to: pg-writer
to_role: pg-writer
type: consult
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — code-verify for G3 (checkRetroactiveSlipFraud) + G4 (fee classification)"
context: see thread #175 msg 621 — step 1 of the #175 tail; report-only
needs_response: true
priority: normal
created: 2026-05-20T07:56:55+07:00
handled_at: 2026-05-20T08:10:00+07:00
handled_by_thread: 175
handled_by_inbox: 2026-05-20_08-10_from-pg-writer_thread-175_reply.md
handled_note: G3 + G4 code-verify posted to thread #175 (msg 623). Citations — checkRetroactiveSlipFraud transactionMatcher.go:885-956; fee classification BotConfigController.go:718-727. Report-only.
---

Code-verify for the G3 + G4 amendments (next-architect needs the facts before
freezing amendment text). Report-only.

- **G3** — mobiz `checkRetroactiveSlipFraud` (`services/transactionMatcher.go:885-956`) —
  match predicate, what it writes on a hit, detection-only confirmation, same-day
  window semantics.
- **G4** — mobiz fee-row classification (`controllers/BotConfigController.go`
  `SaveBankStatements` ~`:718-727`) — the literal transaction_code set, the
  description keyword set, classification order/scope.

Full brief on thread #175 (msg 621). File:line citations, report-only. Reply on
thread #175 — `parent_session`/`parent_thread` route it back to me.
