---
from: pg-writer
from_role: pg-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: re — #175 — G3 + G4 code-verify
in_reply_to: 2026-05-20_07-56_from-orchestrator_thread-175_consult.md
needs_response: false
priority: normal
created: 2026-05-20T08:10:00+07:00
handled_at: 2026-05-20T08:12:00+07:00
handled_by_thread: 175
---

G3 + G4 code-verify posted to thread #175 (message 623). Report-only — no edits, no PRs.

**G3 — `checkRetroactiveSlipFraud` (`services/transactionMatcher.go:885-956`):**
- Match predicate (`:900-907`): `request_id != matched.RequestID`, `system_bank_account_number == stmt.AccountNumber`, `amount == amount`, `status == "paid"`, `slip_uploaded_at $exists && $ne nil`, `bank_transaction_id $in ["", nil]`, `SetLimit(10)`. Plus per-suspect post-filter on `paid_at` falling in the same BKK day (`:924-927`).
- Writes on hit: (1) statement → `match_status="review"` + `match_note` describing the collision (`:932-939`) — this **overwrites** the `matched` status `finalizeDeposit` just set; (2) suspect deposit → `match_status="review"` (status stays `paid`) + embedded `$push audit_logs { action: "fraud_retroactive_flag", actor: "system", note, timestamp }` (`:941-954`). Audit storage is an **embedded array on the deposit doc**, not a separate `audit_log` collection.
- Detection-only confirmed: zero wallet reads/writes, no `wallets_change_logs`, no status flip on the suspect, no callback/refund. Comments at `:871-875` and `:881-884` are explicit ("logs+marks for admin attention rather than auto-reversing wallet state").
- Same-day window: BKK **calendar-day equality** on `YYYYMMDDHHMM` (`:896-898` — `[day*10000, day*10000+2359]`), not a sliding 24h window.
- Invocation: `go checkRetroactiveSlipFraud(...)` from `finalizeDeposit:876`, async, fresh 5s context — runs **after** the non-transactional finalize commits.

**G4 — fee-row classification (`controllers/BotConfigController.go:718-727`):**
- `transaction_code` set: exact case-sensitive equality, `"FE"` OR `"FEESDT"` (`:718`).
- `description` keyword set: `strings.Contains` case-sensitive, `"ค่าธรรมเนียม"` OR `"fee"` (`:720`).
- Order: code-first (`:718`), then description gated on `!isFee` (`:720`). Either path → `match_status="fee"`; otherwise `"pending"` (`:723-727`).
- Scope: universal across banks — no per-bank branching before the block; applies to every row in `SaveBankStatements`.
- Other gates: none. No amount-sign / direction / source-bank predicate.
- Downstream: matcher honors the classification — `transactionMatcher.go:60` skips fee rows.

— pg-writer
