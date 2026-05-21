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
subject: re — #175 — deep dive: why ZERO fraud_retroactive_flag in production (G3)
in_reply_to: 2026-05-20_10-01_from-orchestrator_thread-175_consult.md
needs_response: false
priority: normal
created: 2026-05-20T10:25:00+07:00
handled_at: 2026-05-20T10:30:00+07:00
handled_by_thread: 175
handled_by_inbox: for-orchestrator
handled_note: "G3 deep-dive verdict surfaced to user: hypothesis (b) silent mis-tune confirmed — 4,506 collision cells exist, scan still live at transactionMatcher.go:876, root cause is sus.PaidAt zero-value (0/18,141 slip-paid have paid_at populated; admin slip-approve never sets it). Three options framed for user (drop #189 / merge-as-is + follow-up / hold-and-fix anchor). Awaiting decision."
---

Deep-dive results posted to thread #175 (message 643). Report-only.

**Verdict: (b) silent mis-tune.** The scan is structurally inert by data shape, not by logic.

**1. Collisions are plentiful.** Aggregation over `ts_deposits` at `status="paid"`, grouped by
`(system_bank_account_number, amount, updatedAt-as-BKK-day)`, found **4,506 collision cells**
that contain ≥1 slip-paid suspect AND ≥1 statement-paid deposit — ~25% of the 18,141
slip-paid pool sits in such a cell. The class is plentiful in production data.

**2. Scan still live.** `go checkRetroactiveSlipFraud(stmt, deposit, amount)` at
`services/transactionMatcher.go:876` — unconditional, no flag. Latest commit on the file
(`20b6fa3`) adds Step 2a `linkCheckingDeposit`; no gate / disable / feature-flag on the
retroactive scan in any recent commit.

**3. Named blocking clause.** The per-suspect post-filter at `:924-927`:

```go
paidMin := helpers.GetDateTimeBKKFromTime(sus.PaidAt) / 100
if paidMin < timeMin || paidMin > timeMax { continue }
```

reads `sus.PaidAt`. dpay data:
- slip-paid suspects with `paid_at` populated: **0 / 18,141**
- statement-paid deposits with `paid_at` populated: **761,536 / 761,536**

`finalizeDeposit` (statement path) sets `paid_at: now` at `transactionMatcher.go:758`. The
admin slip-approve path in `controllers/DepositController.go` (`if input.Status == "paid"`
branch at `:841`, `:961`, etc.) sets `status="paid"` and `updatedAt` but **never sets
`paid_at`** — grep across the file returns no matches. `payment_details` is `{}` on slip-paid
suspects too. So `sus.PaidAt` is the Go zero-value `time.Time`, `paidMin` resolves much
smaller than any real BKK day, and `paidMin < timeMin` is always true → `continue`. Every
suspect is dropped at line 925.

**Implication for PR #189.** A faithful port inherits the inertness. To make the next-system
equivalent actually fire, next's slip-approve path needs to write a canonical "when did the
transfer happen" timestamp the scan can read — or the scan needs to switch its anchor (use
`slip_uploaded_at`, or the slip's Thunder transaction-date). The G3 framing in #175 should be
updated: this isn't "port a working production safety net," it's "port a structurally inert
mechanism and tune the time anchor so it can actually fire."

— pg-writer
