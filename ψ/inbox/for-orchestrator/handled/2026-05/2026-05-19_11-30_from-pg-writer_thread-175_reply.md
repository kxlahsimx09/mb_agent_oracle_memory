---
from: pg-writer
from_role: pg-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 175
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: re — current-system cross-check round 2 — gap review of next's requirement docs (continue #167)
in_reply_to: 2026-05-19_11-17_from-orchestrator_thread-175_consult.md
needs_response: false
priority: normal
created: 2026-05-19T11:30:00+07:00
handled_at: 2026-05-19T11:38:00+07:00
handled_by_thread: 175
---

Round 2 cross-check complete — full report posted to thread #175 (message 569),
thread marked `answered`. Report-only: no doc edits, no PRs.

**8 gaps found.** Cross-checked the matcher branch
(`next-writer/thread167-matcher-epic @ 3624600` — `main`'s epic-deposit/payout
are stale) against live mobiz Go (`transactionMatcher.go`,
`payoutReconciliation.go`, `withdrawalQueue.go`, `slipMatchHash.go`,
`BotConfigController.go`, `scheduler/transaction_matcher.go`).

epic-statement-matching.md got the deep pass (priority — never cross-checked).

P1 (3):
- G1 — MATCH-002 Step 1 mis-states the matching key: live requires source-identity
  as a mandatory filter, amount-only was deliberately removed (`transactionMatcher.go:124`).
- G2 — degenerate-FIFO carve-out (DEPOSIT-005 §FA1) has no cross-client guard;
  "wallet target is identical" is false for same-payer/different-client → wrong-client-credit
  risk. mobiz has `matchByClientScope` ahead of FIFO; next drops it.
- G3 — `checkRetroactiveSlipFraud` (matcher-time fraud mirror of approve-time V1)
  uncovered by MATCH-002 and DEPOSIT-007.

P2 (3): G4 fee-row intake classification absent (MATCH-001) · G6 OUT matcher serves
the unified withdrawal queue, not just payouts (MATCH-003) · G7 no branch for a debit
matching an in-flight `processing` payout (MATCH-003).

P3 (1): G5 dedup tail is per-row-presence not per-bank-declared + skipped on missing date.

Also listed 6 verified-covered items (failed→completed divergence, `pending_review`
§FA3, advisory lock, request_id amount cross-check, tryReconcileAfterMarkFailed race-net,
match_hash sparse-compute) so the verify pass can skip them. Severity roll-up table is
on the thread. User picks fold-in scope next round.

— pg-writer
