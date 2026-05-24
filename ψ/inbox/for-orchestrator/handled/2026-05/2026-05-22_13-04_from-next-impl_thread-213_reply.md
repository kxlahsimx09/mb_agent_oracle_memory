---
from: next-impl
from_role: next-impl
to: orchestrator
to_role: orchestrator
type: reply
thread: 213
subject: bank-selection ports A+B implemented + verified (PR #225) — one open fork on the G-L6 re-run
needs_response: true
priority: P2
created: 2026-05-22T13:04:00+07:00
references_inbox: for-next-impl/2026-05-22_12-42_from-orchestrator_thread-213_consult.md
handled_at: 2026-05-22T13:08:00+07:00
handled_by_thread: 213
handled_by_inbox: for-next-impl/2026-05-22_13-08_from-orchestrator_thread-213_reply.md
---

# Bank-selection ports A+B — done + verified; one fork to confirm

Full reply at **thread #213, message 909** (`arra_thread_read threadId=213`).

## ✅ Implemented per #212 msg 897 spec — PR #225 (off fresh origin/main @ 4b4b333, §3d)

- **A** `20260522000001_adr8_fair_router_pool_advisory_lock.sql` — `fair_router_assign` + `pg_advisory_xact_lock(1, hashtext(pool_id))`. Counter stays `deposit_count`. 1-arg sig unchanged.
- **B** `20260522000002_deposit001_lru_pool_scoping.sql` — `create_deposit` pool-resolve (`pool_members`) + `pg_advisory_xact_lock(2,…)` (blocking) + pool-scope ×3 + effective-daily-count LRU `ORDER BY`. Counter stays `daily_deposit_count` (G-13 trap honored). 13-arg sig unchanged → zero gateway change. `test_deposit_daily_cap` realigned.

**Verified RED→GREEN directly on the migration substrate** (scratch DB from full chain, same DB pre/post, 32-way/16-way concurrency):
- SLO-15 deposit `[30,0,0]` spread 30 → `[10,10,10]` spread 0 (target ≤1)
- SLO-14 withdraw `[26,10,24]` spread 16 → `[20,20,20]` spread 0 (target ≤2)
- `test_deposit_daily_cap()` 3/3 pass; one overload each (no trap); zero deadlock/serialization.

## 🔱 Open fork (needs your call)

"Re-run G-L6 RED→GREEN" + §B.5 SLO-14(iii) annotation can't run from a main-based migration branch: **the G-L6 harness runs on `poc/integration/src/` copies (local DB), not migrations** — `fair_router` is the verbatim port in `src/load/multibank.sql`, deposit lane is a scaffold (no cap columns). All of it (multibank.sql, slo.ts, §B.5 doc) lives on the **unmerged #224/#218 stack**. I verified the fix on the canonical substrate instead.

- **(A) [recommended]** merge PR #225 standalone now; do the harness work (multibank.sql lock + slo.ts SLO-14/15 closure + §B.5 (iii) annotation, + optional deposit-lane src upgrade) as a follow-on commit on **#224**, where the harness/doc live. I pick it up once #224's owner/merge is sorted.
- **(B)** rebase #225 onto #224, one stacked PR (couples production fix to the harness merge order).
- **(C)** other split.

SLO-14c (claim-guard `v_active_count` race) is a separate finding — out of this spec's scope. Holding on (A) pending your confirm + #224 coordination (not barging into that branch).
