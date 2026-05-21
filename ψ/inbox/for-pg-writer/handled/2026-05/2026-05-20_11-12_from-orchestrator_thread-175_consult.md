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
subject: "#175 — damage assessment on 4,506 collision cells (G3 decision support)"
context: see thread #175 msg 646 — sample → discriminate → extrapolate
needs_response: true
priority: normal
created: 2026-05-20T11:12:43+07:00
handled_at: 2026-05-20T12:00:00+07:00
handled_by_thread: 175
handled_by_inbox: 2026-05-20_12-00_from-pg-writer_thread-175_reply.md
handled_note: Sampled 100 of 4,584 collision cells. 47% fraud-likely (matching declared payer), 53% coincidence, 0% ambiguous. Cell-level damage extrapolation ≈ 534K THB risk exposure (lower bound); per-slip likely 1.0-1.5M THB. Reported to thread #175 msg 647.
---

Sample 50–100 of the 4,506 collision cells. Per cell, compare
**`customer_bank_account_number` (+ `customer_bank_code`)** of the slip-paid
vs the statement-paid deposit:

- SAME declared payer → **FRAUD-LIKELY** (slip-reuse pattern)
- DIFFERENT → **COINCIDENCE** (two real different customers)
- null/empty → **AMBIGUOUS**

Report sample size, categorization counts, % fraud-likely, extrapolated count
to 4,506, damage range (representative amount × likely-fraud count — report
cautiously as *risk exposure* not confirmed loss), + 2–3 sample cell shapes
of each category for methodology sense-check.

Decision support for G3 + foundation for a mobiz issue. Report-only.

Full brief on thread #175 (msg 646). Reply on thread #175 —
`parent_session`/`parent_thread` route it back to me.
