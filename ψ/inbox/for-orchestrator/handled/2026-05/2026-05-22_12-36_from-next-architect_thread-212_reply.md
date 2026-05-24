---
from: next-architect
to: orchestrator
type: reply
thread: 212
parent_thread: 211
in_reply_to: 2026-05-22_12-26_from-orchestrator_thread-212_consult.md
needs_response: false
priority: P2
created: 2026-05-22T12:36:00+07:00
subject: SPEC DELIVERED — 2 bank-selection ports (§ADR-8 advisory-lock + DEPOSIT-001 LRU); pending GO; 1 confirm-ask
handled_at: 2026-05-22T12:39:58+07:00
handled_by_thread: 212
handled_note: bank-select port spec delivered (advisory-lock both lanes, blocking rec); GO + impl-dispatch follows
---
Pinned spec posted to **thread #212 msg 897** (status `answered`). Grounded on `origin/main @ b616c0d` + deployed migrations. **No ADR amendment** — both ports implement already-ratified decisions (§ADR-8 advisory-lock prose; DEPOSIT-001 LRU + "thin PL/pgSQL + advisory lock"). **RPC signatures unchanged → zero gateway/EF contract change.**

## Shared root cause (one bug, two lanes)
`ORDER BY <counter> ASC LIMIT 1 FOR UPDATE` does NOT turn skew GREEN — Postgres EvalPlanQual re-checks only the locked candidate's WHERE predicate after a concurrent update, never re-runs ORDER BY/LIMIT. K concurrent same-pool assigns pile onto one bank. Fix both lanes: **per-pool `pg_advisory_xact_lock(class, hashtext(pool_id::text))`** — 2-int form (disjoint from existing 1-bigint locks), `class=1` withdraw / `class=2` deposit.

## (a) WITHDRAW `fair_router_assign` (`20260510000002_entry_points.sql:400-448`)
One lock line after the pool-null guard; counter stays `deposit_count`. **Defer** (not needed for SLO-14 GREEN): tier-cap/outstanding-cap (**columns verified absent** — separate story), queueLoad/base (refinement; ≤1 already), 8-filter heartbeat (redundant — §ADR-8 D5 puts liveness at *claim* time) + budget (claim accumulator enforces). **→ SLO-14 re-scope:** drop invariant (iii) tier-cap (not assertable; columns don't exist); keep (i) exactly-once + (ii) pile-on + ≤2. One-line edit to PR #218 §B.5.

## (b) DEPOSIT `create_deposit` (latest def `20260520000004_g13_separate_daily_count_column.sql:53-191`)
Same 13-arg sig (resolve pool internally — no new param, no overload trap). Add: pool-resolve (`pool_members` client-member → merchant-member fallback per §ADR-8 D2; substrate has no `client.pool_id`), lock(2), pool-scope ×3 queries, LRU `ORDER BY (CASE WHEN reset_date<today THEN 0 ELSE daily_deposit_count END) ASC, created_at, id`. Counter stays `daily_deposit_count` — **NEVER touch `deposit_count`** (= the G-13 `[1,1,1]→[1,1,19]` regression). Cap/lazy-reset/FOR-UPDATE/exclusion already present.

## 🔱 The one confirm-ask (non-obvious fork)
Recommend **blocking `pg_advisory_xact_lock`, not `pg_try_…`** (your task text named try). Try-lock is a mobiz poll-loop artifact; next-system replaced the loop with a per-INSERT webhook EF — a try-fail needs EF-500-retry or a NEW re-route sweep (none exists). Blocking makes the RPC the serialization point; deposit is synchronous so must block anyway. **If user wants try-semantics on withdraw → larger scope (re-route sweep), I re-spec separately — flag it.**

## Next
On **GO** → next-impl (queued #209-after-UI): migration A (fair_router lock) + migration B (deposit LRU+pool-scope) + concurrent SLO-14/15 tests + G-L6 re-run (RED→GREEN; #203 is measuring the RED baseline now). Full impl checklist in thread #212 msg 897. Ready to confirm GO or re-spec the try-lock fork.
