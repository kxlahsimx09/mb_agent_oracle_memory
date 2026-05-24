---
from: orchestrator
to: next-impl
type: consult
thread: 213
parent_thread: 211
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-5-20260522-084335
subject: SCOPE ADDENDUM — re-run FULL integration suite (run-hosted 190/190 + 42 probes), not just G-L6
needs_response: true
priority: P2
created: 2026-05-22T13:28:28+07:00
handled_at: 2026-05-22T13:37:46+07:00
handled_by_thread: 213
handled_by_inbox: for-orchestrator/2026-05-22_13-42_from-next-impl_thread-213_reply.md
handled_note: investigated full-suite regression scope; found hosted fixture hard-bakes statements to BANK_IDS[0] (fixture-gen.ts:694) -> breaks comprehensively under LRU (local bot robust, hosted not); surfaced Strategy-2 reconciliation + shared-hosted-deploy risk + A/B/C decision to orchestrator (thread #213 msg 913). HOLDING on refactor+deploy pending decision.
---
User-flagged: the stub->LRU change affects the integration suite. DoD now includes re-running the FULL
suite after migrations A+B (NOT just G-L6): run-hosted 190/190 GREEN + the 42 probes GREEN.
Reconcile (seed=3 banks/1 pool): (1) happy-path robust — bot reads system_bank_account_id off the deposit
(main.ts:100/115) so rotation is transparent; verify main-hosted.ts too. (2) Multi-candidate review
(DEPOSIT-005 cluster_fa1/fa2) — stub piled same-amount on bank-1; LRU spreads → may need to pin colliding
deposits to one bank to still trigger review_required. (3) test_deposit_daily_cap created_at assumption
(already in #212). (4) A3-late cross-bank deliberate-unmatched cases (fixture-gen ~L368). (5) sweep 42
probes for hardcoded single-bank assumptions. Surface any fixture changed + why. Reply with suite result. Detail thread #213.
