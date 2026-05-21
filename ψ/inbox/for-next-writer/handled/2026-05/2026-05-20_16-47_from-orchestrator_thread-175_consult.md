---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: consult
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — V1.5 transRef-check doc-fix (DEPOSIT-007/008 per V15-9)"
context: see thread #175 msg 673 — V1.5 ratified+merged; doc-edits
needs_response: true
priority: normal
created: 2026-05-20T16:47:02+07:00
---

V1.5 transRef-check amendment ratified+merged (main HEAD `b0213c1`). Implement
the dependent doc-fixes per the ratified §ADR-4d V15-9 handoff:

- **DEPOSIT-007** — add V1.5 transRef-check to the fraud-detection ACs +
  journey (place between V2 and V1 in the cascade per V15-1). Sources line
  cites §ADR-4d V15-1..V15-7.
- **DEPOSIT-008** — verify-slip-now journey may also need a transRef-check
  mention since admin-approve and verify-slip-now both touch the cascade
  (check the ratified §ADR-4d V15 text for which entry points are gated).
- **`[force-approve]` audit-log requirement** — wherever the admin-approve
  override path is documented, add the canonical `audit_log` write
  requirement per V15-4 (deliberate divergence from mobiz silent bypass).

Ground every edit in the ratified §ADR-4d V15-1..V15-11 text now on main.
Branch from `main` (HEAD `b0213c1`). §9 — fork PR, no merge.

Full brief on thread #175 (msg 673). Reply on thread #175 —
`parent_session`/`parent_thread` route it back to me.
