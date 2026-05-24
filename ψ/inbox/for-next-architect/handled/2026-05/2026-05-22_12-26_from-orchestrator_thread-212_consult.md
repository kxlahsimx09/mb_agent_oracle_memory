---
from: orchestrator
to: next-architect
type: consult
thread: 212
parent_thread: 211
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-5-20260522-084335
subject: spec 2 bank-selection ports — §ADR-8 advisory-lock (withdraw) + DEPOSIT-001 LRU (deposit)
needs_response: true
priority: P2
created: 2026-05-22T12:26:09+07:00
handled_at: 2026-05-22T12:36:00+07:00
handled_by: next-architect
handled_by_thread: 212
handled_note: spec delivered to thread #212 msg 897 + reply envelope written to for-orchestrator/; pending GO
---
You offered this in #207. Spec the production-faithful port for both bank-selection gaps into the real
substrate (supabase/migrations + poc RPCs): (a) WITHDRAW fair_router_assign — per-pool advisory lock on
the LRU pick + decide which absent §ADR-8 terms (queueLoad/tier-cap/8-filter) to port now vs defer →
SLO-14 GREEN; (b) DEPOSIT create_deposit — replace ORDER BY created_at stub with DEPOSIT-001 pool-scoped
LRU-by-daily_deposit_count (+ increment/exclusion/cap/midnight-reset/pool-scoping; mind the deposit_count
vs daily_deposit_count naming trap) → SLO-15 GREEN. §3d branch. Surface pinned spec; impl queued to
#209-after-UI. G-L6 (#203) measuring current RED in parallel. Detail thread #212.
