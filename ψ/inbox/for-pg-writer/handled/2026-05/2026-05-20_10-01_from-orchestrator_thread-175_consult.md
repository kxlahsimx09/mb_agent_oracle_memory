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
subject: "#175 — deep dive: why ZERO fraud_retroactive_flag in production (G3 decision)"
context: see thread #175 msg 641 — discriminate "no collisions exist" vs "scan misses real collisions"
needs_response: true
priority: normal
created: 2026-05-20T10:01:32+07:00
handled_at: 2026-05-20T10:25:00+07:00
handled_by_thread: 175
handled_by_inbox: 2026-05-20_10-25_from-pg-writer_thread-175_reply.md
handled_note: Verdict (b) silent mis-tune. 4,506 (sysbank,amount,BKK-day) collision cells exist in production (~25% of 18,141 slip-paid suspects sit in cells with statement-paid deposits) → class is plentiful. The scan is still invoked at transactionMatcher.go:876 (no gate, no recent disable). Named blocking clause = the per-suspect post-filter at :924-927 reads sus.PaidAt, but 0/18,141 slip-paid deposits have paid_at populated (vs 761,534/761,536 statement-paid) — the slip-approve path in DepositController.go never sets paid_at. Every suspect filtered out at line 925. Posted to thread #175 msg 643.
---

Deep dive on the zero-yield finding (msg 639) — discriminate (a) rare class
vs (b) silent mis-tune. 3 focused queries:

1. **Collision-pair existence** — aggregate-group the 18,137 suspect-pool by
   `(system_bank_account_number, amount, transaction_date_bkk_day)` — how
   many groups with count ≥ 2? Zero ⇒ (a); >0 ⇒ (b) on table.
2. **Live invocation check** — confirm `go checkRetroactiveSlipFraud(...)`
   still called from `finalizeDeposit` on HEAD (file:line); any recent
   commit disable/gate it?
3. **If pairs exist** — sample 1 collision-pair, walk through the predicate
   field-by-field and identify which clause filtered the suspect out (or
   was it an invocation gap rather than predicate gap?).

Report on #175 with results + one-sentence (a)/(b) verdict. Grounds user's
ratify / drop / port-and-improve decision on PR #189.

Full brief on thread #175 (msg 641). Reply on thread #175 —
`parent_session`/`parent_thread` route it back to me.
