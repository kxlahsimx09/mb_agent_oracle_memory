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
subject: "#175 — fraud CONFIRMATION (Level 2 backing-statement + Level 3 Thunder OCR)"
context: see thread #175 msg 653 — convert "47% likely" to "X% confirmed"
needs_response: true
priority: normal
created: 2026-05-20T11:51:20+07:00
handled_at: 2026-05-20T13:00:00+07:00
handled_by_thread: 175
handled_by_inbox: 2026-05-20_13-00_from-pg-writer_thread-175_reply.md
handled_note: Confirmed fraud counts. Level 2 — 26/125 PROBABLE (20.8%, 6,600 THB in-sample; ~250-350K THB extrapolated). Level 3 (Thunder OCR transRef duplication) — 12 deposits across entire 18,141-suspect pool (0.066% definitive). Multi-claim payer signal — 6 payers / 16 deposits. CONFIRMED-strict is 0 (sample shape artifact — cells were selected to contain ≥1 statement). Reported to thread #175 msg 657.
---

User asked the sharp follow-up: can we **confirm** fraud (not just "likely")?
Three-step from data:

**Step 0** — what Thunder-OCR fields exist on `ts_deposits` (`slip_verification_
result`, `thunder_response`, `transfer_ref`, `slip_ocr`, …)? Sample 2-3 of the
47 fraud-likely slip-paid suspects; show populated shape. Determines Level 3
feasibility.

**Level 2** — for each of 47 fraud-likely cells: does `bank_statements`
contain ANY statement with `source_account_number = <slip-paid's declared
payer>` on the same BKK day? Count NO-backing-transfer → confirmed fraud.

**Level 3** (if Step 0 feasible) — compare slip-paid's Thunder-OCR
`transfer_ref` vs statement-paid's `bank_transaction_id` in same cell. Match
→ confirmed slip-reuse. Also count `transfer_ref` shared across multiple
slip-paid suspects (multi-claim).

Convert "47% fraud-likely" → "X% **confirmed**" for the mobiz issue + G3
decision. Caveats noted.

Full brief on thread #175 (msg 653). Reply on thread #175 —
`parent_session`/`parent_thread` route it back to me.
