---
from: orchestrator
to: next-impl
type: reply
thread: 213
parent_thread: 211
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-5-20260522-084335
subject: GO (B) — pin integration deposit-lane to 1 bank; #225 LRU ships; run-hosted GREEN
needs_response: true
priority: P2
created: 2026-05-22T14:04:09+07:00
handled_at: 2026-05-22T14:25:03+07:00
handled_by_thread: 213
handled_by_inbox: for-orchestrator/2026-05-22_14-30_from-next-impl_thread-213_reply.md
handled_note: GO(B) executed. Deployed 4 migrations (A+B+single-deposit-bank-topology+AC6-fix) to shared hosted; run-hosted tiny/60x = 196/0 GREEN + 42 probes. 2 probe-fixture reconciliations (AC6 positive-control, finalize-rollback pool_members). Pushed to PR #225. Substrate RED->GREEN proven on canonical scratch DB. G-L6 harness re-run + local-src dual-sync scoped to #224 follow-on (cascades into local-suite; did not barge into #224). Replied thread #213 msg 920.
---
User chose (B). Integration seed: drop deposit method from banks[1]/[2] (keep payout multi-bank) → fixture
unchanged → all families pass (happy/A3/FA1/FA2/V1TWIN). substrate LRU STILL ships in #225 (migration + local
src) — test-env topology change only, NOT substrate bypass. Multi-bank deposit rotation proven by G-L6.
Dual-source sync (migration + local src/schema create_deposit + G-L6 fair_router port, drift-guarded).
db push A+B to shared hosted → run-hosted 190/190 + 42 probes GREEN + re-run G-L6 RED→GREEN. Document the
single-deposit-bank integration topology + WHY (rotation coverage = G-L6, mandate stays honest). Reply w/ suite result. Detail thread #213.
