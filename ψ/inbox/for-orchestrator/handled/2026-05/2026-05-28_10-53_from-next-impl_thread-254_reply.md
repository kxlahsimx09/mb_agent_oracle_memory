---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 254
parent_thread: 254
parent_oracle: orchestrator
subject: substrate hygiene R1+R2 DELIVERED — PR #276; ready for brew-ops db push + §D re-run
needs_response: true
priority: normal
created: 2026-05-28T10:53:00+07:00
handled_at: 2026-05-28T17:57:00+07:00
handled_by_thread: 254
handled_note: >
  next-impl substrate hygiene R1+R2 delivery (msg 1231) relayed to user.
  State-grounding: envelope frontmatter `10:53+07:00` is mislabeled UTC (next-impl's
  writer-bug pattern); real time per thread API is 10:53:25Z = 2026-05-28T17:53 GMT+7.
  Campaign branched new direction (msg 1230): user's pg_stat_statements gist showed
  sweep_unmatched_statements = 38.75% DB-time → hygiene round BEFORE any Medium leg.
  PR #276 verified live via gh: OPEN/MERGEABLE/non-draft, branch
  next-impl/substrate-hygiene-r1r2, commit cba7023. Single migration
  20260528170000_substrate_hygiene_r1r2.sql wires R1.A sweep rewrite (no-heap SELECT
  id + LIMIT 500 + partial idx, overload-trap caught) + R1.B simulate_admin unscheduled
  (body retained per P-001) + R1.C 8 sweeps relaxed to */5 min + R2 DROP 6 / ADD 15 FK
  hot-path indexes (CONCURRENTLY IF NOT EXISTS). Local-verify clean. Relayed delivery
  + 3 user calls (cadence-interpretation confirmation / merge PR #276 / brew-ops db
  push + §D re-run dispatch GO) to user via Telegram (chat 2002026175, msg id 43) at
  2026-05-28T17:57+07:00. Trace marker posted to thread #254 (msg 1232). Thread left
  pending; no dispatch fired (cadence question is a legit ambiguity in wt-21's brief
  that next-impl correctly flagged for user judgment; merge is §9 user-only). §151
  owner remains wt-21.
---

Single migration `supabase/migrations/20260528170000_substrate_hygiene_r1r2.sql`. PR #276 https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/276 (off origin/main, commit cba7023). Thread #254 msg 1231 has the full table.

**Round 1**:
- R1.A `sweep_unmatched_statements` rewritten — SELECT id (no heap) + LIMIT 500 + new partial `idx_bank_statements_sweep (created_at) WHERE direction='in' AND match_status IN ('pending','unmatched')`. EXPLAIN: NO sort, NO filter on prod plan; 2 buffers (was 4). Picked up the function-overload trap from my memory — explicitly DROP the old 0-arg before the new CREATE-with-default-param, else SQLSTATE 42725 ambiguous on the cron's `sweep_unmatched_statements()` call.
- R1.B `simulate_admin_review` unscheduled — function header self-classifies as FIXTURE/TEST-INFRA only. Function body retained (P-001).
- R1.C all 9 deployed crons were `* * * * *` (1/min), NOT 1/sec. Brief's "5-10s" parsed as "less frequent" → relaxed 8 safety-net sweeps to `*/5 * * * *`. Flag if you meant a different cadence.

**Round 2**:
- DROP 6 unused per brief list.
- ADD 15 FK hot-path (mdr_shared/wallets_change_logs/callback_queue/client/bank_account/withdrawal_queue/ts_deposits/ts_payouts) including a slim Mode-2 replacement for the dropped `wq_pending_fifo` AND the missing `(amount, system_bank_account_id) WHERE pending+is_matched=false` for cascade Step-1.

**Local-verify**: 6/6 DROPs gone, 15/15 ADDs present, simulate-admin unscheduled, 8 sweeps at `*/5`, sweep function single-overload + both 0-arg and 1-arg calls succeed. CREATE INDEX CONCURRENTLY everywhere → migration MUST apply with autocommit (no transaction wrap); `supabase db push` is fine.

**Ready for brew-ops:** db push the migration + re-run §D feasibility through the CF Worker (same sizing as cf-gateway-216 baseline). Target: X_faithful recovery toward #266's X_micro ≈ 80 if R1+R2 paid off (less sweep DB-time competing with create-path).

Notes I flagged in-thread: (i) `idx_wq_pending_fifo` had local scan=3 (worktree artifact) — slim replacement covers it; (ii) "5-10s" cadence interpretation needs your confirmation; (iii) brew-ops should compare pg_stat_user_indexes pre/post on prod to confirm the drop list was unused.
