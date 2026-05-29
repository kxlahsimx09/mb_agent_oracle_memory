---
title: Substrate hygiene R1+R2 delivered (thread #254 msg 1230→1231, PR #276, 2026-05-2
tags: [implementation-architect, repo:mb-next-payment-gateway, next, poc, thread-254, substrate-hygiene, sweep-optimization, index-hygiene, pg-cron-cadence, function-overload-trap, concurrently-no-tx, explain-before-after, p-001-lane-cross, next-dev, brew-ops-handoff]
created: 2026-05-28
source: PR #276 on github.com/kxlahsimx09/mb-next-payment-gateway; supabase/migrations/20260528170000_substrate_hygiene_r1r2.sql; thread #254 msg 1230→1231
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Substrate hygiene R1+R2 delivered (thread #254 msg 1230→1231, PR #276, 2026-05-2

Substrate hygiene R1+R2 delivered (thread #254 msg 1230→1231, PR #276, 2026-05-28).

User-ratified after pg_stat_statements evidence: sweep_unmatched_statements = 38.75% of DB time, sweeps total ~56%. IMPL + local-verify only; brew-ops applies + re-runs §D for delta vs evidence/cf-gateway-216 baseline.

Single migration supabase/migrations/20260528170000_substrate_hygiene_r1r2.sql with:

Round 1 (sweep cleanup):
- R1.A sweep_unmatched_statements rewritten: SELECT id (was SELECT *) + LIMIT 500 batch bound + new partial index `idx_bank_statements_sweep ON (created_at) WHERE direction='in' AND match_status IN ('pending','unmatched')`. EXPLAIN before/after: was Index Scan dedup_composition + Sort + Filter (4 buffers); after: Index Scan sweep, no sort, no filter (2 buffers). Production with thousands of rows in the 1-hour window saves the sort step + the heap fetches.
- R1.B simulate_admin_review unscheduled (function body retained P-001). Function header self-classifies as FIXTURE/TEST-INFRA only.
- R1.C all 9 deployed crons were `* * * * *` (1/min) — brief said "5-10s" but the deployed reality is 1/min, so interpreted as "less frequent". Relaxed 8 safety-net sweeps to `*/5 * * * *` (every 5 min): unmatched-statements, expired-deposits, stale-claims, payout-reconcile, stuck-dispatching, dispatch-callback, retroactive-slip-fraud, stale-payouts. Convergence in each safety-net look-back window preserved; eager paths (cascade / dispatcher / claim) remain primary.

Round 2 (index hygiene, all CONCURRENTLY IF NOT EXISTS / IF EXISTS):
- DROP 6 unused: idx_ts_deposits_failure_code, idx_ts_deposits_slip_trans_ref, idx_ts_payouts_failure_code, idx_idempotency_keys_expires_at, idx_bank_statements_match_hash, idx_wq_pending_fifo.
- ADD 15 FK hot-path: mdr_shared(deposit_id, wallet_id), wallets_change_logs(wallet_id, created_at DESC), callback_queue(merchant_id), client(merchant_id), bank_account(pool_id), withdrawal_queue (slim replacements for both Mode-1 pool_id-pending and Mode-2 required_bank_account_id-pending), ts_deposits(client_id, system_bank_account_id, mdr_profile_id) + cascade Step-1 partial (amount, system_bank_account_id) WHERE pending+is_matched=false (THE missing index that makes match_deposits_cascade fast), ts_payouts(client_id, system_bank_id).
- SKIP per brief: app_user / audit_log / auth-conn (not in create-deposit path).

DURABLE LEARNINGS captured for future hygiene migrations:

1. **Function overload trap**: re-confirming [[feedback_create_or_replace_function_overload]]. Adding a DEFAULT parameter via CREATE OR REPLACE FUNCTION creates a NEW overload (different signature) — the OLD 0-arg version persists. A bare call `sweep_unmatched_statements()` then fails SQLSTATE 42725 ambiguous (both overloads match). Always `DROP FUNCTION IF EXISTS public.foo(<old-args>);` BEFORE the new CREATE. Verified locally: before fix, 0-arg call errored; after fix, single overload + 0-arg + 1-arg both succeed.

2. **CREATE INDEX CONCURRENTLY apply constraint**: cannot run in a transaction block. The migration file must apply with autocommit (no BEGIN/COMMIT wrap, no `psql -1`). `supabase db push` sends each migration file as-is, so this works natively. Local: `psql -f file.sql` without `-1`.

3. **pg_cron cadence relaxation pattern**: pg_cron has no "update cadence" primitive; the only way to change a schedule is `cron.unschedule(jobname) + cron.schedule(jobname, new_schedule, same_command)`. Build a DO block that reads `cron.job.command` and reschedules with that exact command + new schedule. Idempotent.

4. **Slim partial index replacement for dropped composite**: when a multi-column composite index is dropped (e.g., wq_pending_fifo on required_bank_account_id+status+priority+created_at), confirm whether the slim partial replacements cover the same predicate. In this case the Mode-2 claim path `WHERE status='pending' AND required_bank_account_id=?` is covered by the new partial `(required_bank_account_id, priority DESC, created_at) WHERE status='pending' AND required_bank_account_id IS NOT NULL`.

5. **The missing cascade Step-1 index**: `match_deposits_cascade` Step-1 does `SELECT count(*) FROM ts_deposits WHERE status='pending' AND is_matched=false AND amount=? AND system_bank_account_id=?` — neither idx_ts_deposits_pending_match (status+expires_at) nor idx_ts_deposits_2b_match (status+amount for paid/expired/checking) covers this. The new partial `(amount, system_bank_account_id) WHERE status='pending' AND is_matched=false` closes that gap. Likely a significant contributor to per-cascade-call cost.

6. **Index `idx_scan` reading on local DBs is unreliable**: the brief said `idx_wq_pending_fifo` was unused per prod evidence, but my local DB showed scan=3 (from earlier worktree-session load runs preserved across worktrees on the shared Supabase :54322 postgres DB). Trust prod pg_stat_user_indexes; local counters are noisy.

P-001 lane-cross mark on every authored file. PR #276 ready for brew-ops db push + §D re-run for delta vs evidence/cf-gateway-216 baseline.

---
*Added via Oracle Learn*
