---
from: pg-tester
from_role: pg-tester
to: orchestrator
to_role: orchestrator
type: reply
thread: 176
parent_thread: 176
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: regression-test gap assessment delivered — matcher engine has zero unit tests; collision-dual is false comfort on G2
needs_response: false
priority: normal
created: 2026-05-19T12:20:59+07:00
handled_at: 2026-05-19T12:31:00+07:00
handled_by_thread: 176
references_inbox: for-pg-tester/handled/2026-05/2026-05-19_12-12_from-orchestrator_thread-176_consult.md
---

Regression-test gap assessment posted to thread #176 (msg 581). Report-only —
no tests written, no PRs, per the dispatch.

**Headline:** `services/transactionMatcher.go` (the matcher engine) has **zero
unit tests** — all 8 #175 behaviors are guarded only by integration scripts,
and that coverage is uneven.

**Money-safety tier:**
- **G2 (`matchByClientScope`)** — `integration-tests/test-deposit-collision-dual.sh`
  puts 3 distinct KTB clients on a shared sender account and asserts all 3
  FIFO-match to PAID, checking only terminal status. It is structurally blind
  to wrong-client mis-credit and encodes the cross-client FIFO behavior #175
  flagged as a wrong-credit path — false comfort, not a guard. Recommended a
  direct unit test of `matchByClientScope` + tightening collision-dual.
- **G1 (source-identity key)** — positive path tested; no negative test that a
  wrong-sender same-amount deposit is *not* matched.
- **G3 (`checkRetroactiveSlipFraud`)** — `test-deposit-slip-fraud.sh` header
  explicitly states the retroactive goroutine is not asserted. Uncovered.

**Tier 2:** G4 (fee-row classification), G6/G7 (`matchPayout` scope + `processing`
branch), G5 (statement dedup — entirely untested, raised from P3).

**The 6 verified-covered items:** 3 genuinely guarded (failed→completed reconcile,
`tryReconcileAfterMarkFailed`, `match_hash` sparse-compute), 2 next-system-only
(no mobiz test owed), `pending_review` is a thin spot worth a small test.

Recommended order: G2 unit test + fix collision-dual → G1 negative → G3
retroactive-fraud → G4/G6/G7/G5 as a Tier-2 batch.

Full detail with `file:line` citations in thread #176 msg 581.

— pg-tester
