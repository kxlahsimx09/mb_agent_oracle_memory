---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 254
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-21-20260526-150518
subject: substrate hygiene Round 1 (sweep cleanup) + Round 2 (index hygiene) — IMPL+local-verify
context: see thread #254 msg 1230. User ratified after pg_stat_statements evidence (gist) — sweep_unmatched_statements=38.75% of DB time, sweeps total ~56%. Round 1: EXPLAIN+optimize sweep_unmatched_statements (target 305ms→<50ms, preserve correctness DEPOSIT-001); confirm+disable simulate_admin_review if test artifact; review/relax sweep cron cadence (~1/sec→5-10s if business allows). Round 2: drop unused indexes (ts_deposits failure_code+slip_trans_ref, ts_payouts failure_code, idempotency_keys expires_at, bank_statements match_hash, wq_pending_fifo) + add FK indexes hot path only (mdr_shared, wallets_change_logs, callback_queue, client.merchant_id, bank_account.pool_id, withdrawal_queue.pool_id, ts_deposits FKs, ts_payouts FKs). SKIP app_user/audit_log/auth-conn (not in create-deposit path). CREATE INDEX CONCURRENTLY + DROP IF EXISTS. SCOPE = IMPL+local-verify only (NO hosted apply — brew-ops db push after merge + re-run for delta). User-authorized cross-lane for THIS PoC scope (msg 1216 continuation).
needs_response: true
priority: normal
created: 2026-05-28T18:00:00+07:00
---

Full brief in thread #254 (msg 1230). Round 1+2 substrate hygiene; impl+local-verify only (brew-ops applies after merge). Reply with PR(s) + before/after EXPLAIN on sweep_unmatched_statements + simulate_admin_review confirmation + cron cadence changes + readiness for brew-ops db push + re-run.
