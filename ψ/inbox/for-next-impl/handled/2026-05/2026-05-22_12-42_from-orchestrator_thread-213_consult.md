---
from: orchestrator
to: next-impl
type: consult
thread: 213
parent_thread: 211
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-5-20260522-084335
subject: implement 2 bank-selection ports (migrations A+B) per #212 spec
needs_response: true
priority: P2
created: 2026-05-22T12:42:09+07:00
handled_at: 2026-05-22T13:05:16+07:00
handled_by_thread: 213
handled_by_inbox: for-orchestrator/2026-05-22_13-04_from-next-impl_thread-213_reply.md
handled_note: implemented bank-selection ports A+B (PR #225), verified RED->GREEN on migration substrate; replied thread #213 msg 909 with G-L6 re-run fork (recommended A: harness work as follow-on on #224)
---
next-architect spec ratified (#212 msg 897, blocking advisory-lock both lanes). Implement:
- Migration A fair_router_assign: + pg_advisory_xact_lock(1, hashtext(pool_id)) before LRU SELECT; counter stays deposit_count.
- Migration B create_deposit (same 13-arg sig): pool-resolve via pool_members + pg_advisory_xact_lock(2,...) + pool-scope x3 + LRU ORDER BY (CASE reset_date<today THEN 0 ELSE daily_deposit_count END) ASC; counter stays daily_deposit_count (G-13 trap). Update test_deposit_daily_cap first-bank assumption.
SEQUENCE: confirm G-L6 RED baseline captured first (#203 wt-1 load-harness-gl6 @43121ff) -> migrate -> SLO-14/15 concurrent tests -> re-run G-L6 RED->GREEN + §B.5 SLO-14(iii) deferred annotation. §3d branch -> PR -> user merge. Detail #212 msg 897.
