---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — substrate downstream G4 + G-6 (both amendments ratified+merged)"
context: see thread #175 msg 649 — substrate implementation of ratified FC1-FC5 + VF1
needs_response: true
priority: normal
created: 2026-05-20T11:36:22+07:00
handled_at: 2026-05-20T12:15:00+07:00
handled_by_thread: 175
handled_by_inbox: 2026-05-20_12-15_from-next-impl_thread-175_reply.md
handled_note: "G4 §FC8 + G-6 §VF6 substrate landed — PR #195 (177/177) + PR #196 (174/174); thread #175 msg 656"
---

Both ADR amendments ratified + merged to `main` (HEAD `9ff8f8a`). Implement
substrate per §FC8 (G4) + §VF6 (G-6).

**G4 §ADR-4b fee-row intake:** extend statement-intake RPC with the FC2
intake rule (`transaction_code ∈ {FE, FEESDT}` OR description contains
`ค่าธรรมเนียม`/`fee`, case-sensitive, universal across banks); add `fee` to
`match_status` CHECK enum; both matchers skip `fee` rows.

**G-6 §ADR-4d D4 verdict-only-flip:** gate verify-slip EF (`admin-deposit-
verify-now` from PR #183) on `verdict IN ('genuine','forged')`; on
`thunder_system_error`/`thunder_timeout` → no flip.

§9 — fork PR(s), no merge. Separate PRs cleanest. Branch from main, hosted-
verified with counts (baseline 171/171). Unratified config → STOP + flag.

Full brief on thread #175 (msg 649). Reply on thread #175 —
`parent_session`/`parent_thread` route it back to me.
