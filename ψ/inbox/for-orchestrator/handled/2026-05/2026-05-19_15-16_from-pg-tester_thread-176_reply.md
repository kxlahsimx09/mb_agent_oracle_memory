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
subject: money-safety-tier regression tests built (G2/G1/G3) — PR #452; G2 surfaced a real code defect
needs_response: false
priority: normal
created: 2026-05-19T15:16:14+07:00
handled_at: 2026-05-19T15:18:00+07:00
handled_by_thread: 176
references_inbox: for-pg-tester/handled/2026-05/2026-05-19_15-01_from-orchestrator_thread-176_consult.md
---

Built the money-safety-tier regression tests (G2 → G1 → G3). Posted to
thread #176 (msg 610). §9 — fork PR open, no merge.

**PR #452** — `kokarat/mobiz-payment-gateway`, branch
`tests/matcher-money-safety-regression` → base `main`, +774 / 2 files.
All Go tests run green locally (8 pass + 1 documented skip).

**G2** — new `services/transactionMatcher_test.go` (first unit tests for
the matcher engine): direct `matchByClientScope` tests (cross-client set
not auto-matched; single-eligible-client wins; same-client defers to
FIFO). `test-deposit-collision-dual.sh` Step 9 added — asserts each KTB
client is credited once for its own deposit (statement↔deposit↔wallet
pairing + contamination guards).

**G1** — four negative unit tests (KTB + SCB): a same-amount deposit is
not finalized on a source-account or source-bank-code mismatch.

**G3** — two unit tests for `checkRetroactiveSlipFraud` (flags a
slip-approved suspect, detection-only no reversal; different-day not
flagged) — the goroutine `test-deposit-slip-fraud.sh` left un-asserted.

**Headline — verify-before-write surfaced a real code defect, not just a
test gap.** Current `matchDepositKTB` falls through `matchByClientScope`
to `matchByFIFO`, which blind-picks oldest with NO client scoping — so a
cross-client collision is still wrong-client-credited at the
matcher-entry level. `matchByClientScope` is only a partial guard. I
encoded the correct (park-for-review) behavior in
`TestMatchDepositKTB_CrossClientCollisionShouldParkForReview` and
`t.Skip`-ped it — it fails on current code and is the ready-made
regression guard once the fix lands.

**Recommendation back:** dispatch a follow-up code fix to extend the
client-scope guard into the FIFO tier (or make the KTB multi-client
path park for review, matching the SCB path). That is a code change,
out of this test-build round's scope.

Full detail in thread #176 msg 610.

— pg-tester
