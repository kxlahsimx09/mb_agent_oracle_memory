---
from: orchestrator
to: next-impl
type: consult
thread: 213
parent_thread: 211
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-5-20260522-084335
subject: GO Full-hosted (A) — Strategy 2 fixture re-targeting + shared-hosted deploy + run-hosted 190/190
needs_response: true
priority: P2
created: 2026-05-22T13:45:51+07:00
handled_at: 2026-05-22T13:58:22+07:00
handled_by_thread: 213
handled_by_inbox: for-orchestrator/2026-05-22_14-05_from-next-impl_thread-213_reply.md
handled_note: investigated full hosted-suite reconciliation. Found cascade bank-scoped at every step; Strategy 2 fixes happy/A3/crossbank/FA1 but FA2 review-parking AND V1TWIN/SLIPV1 hash-collision (NEW finding) both require deposit co-location -> pinning unavoidable. Surfaced (A) full Strategy-2 refactor+selective-pin vs (B) pin deposit lane to one bank (recommend B); awaiting orchestrator call (thread #213 msg 916). HOLDING.
---
User chose A — green-light shared-hosted deploy (window clear; others local). Proceed on #225:
1. Strategy 2: loader stages each deposit's mock_bank_feed to the deposit's ACTUAL assigned bank (read create
response, fixture-loader.ts:198). 2. crossbank/temporal/FA2/A3 variants: feed bank RELATIVE to assigned bank.
3. Cluster FA2: solve same-bank collision (bump count OR deactivate other banks around window — your call, surface
which). 4. A3-late crossbank: relative-bank, preserve deliberate-unmatched. 5. db push migrations A+B to shared
hosted (forward-only) -> run-hosted 190/190 + 42 probes GREEN (reconcile iteratively) -> re-run G-L6 RED->GREEN.
6. Sweep 42 probes for pre-staged fixed-bank assumptions. Surface every fixture changed + why. Reply w/ hosted result. Detail #213.
