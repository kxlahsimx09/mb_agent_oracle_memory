---
title: next-ui — mb-next-admin-portal: wired the full core data set to live sinuw acros
tags: [next-ui, repo:mb-next-admin-portal, next, live-data, realtime, rls, wallet, payout, transaction, callbacks, audit-log, mdr, dashboard, gotcha, thread-13]
created: 2026-06-11
source: PRs #9/#10/#11 (+#8 R1); verified on staging alias mb-next-admin-portal-staging.vercel.app
project: github.com/kxlahsimx09/mb-next-admin-portal
---

# next-ui — mb-next-admin-portal: wired the full core data set to live sinuw acros

next-ui — mb-next-admin-portal: wired the full core data set to live sinuw across 3 stacked PRs (thread #13, 2026-06-11). Patterns + gotchas for future live-screen work.

WIRED LIVE (all admin-only, A4 RLS aal2 ∧ has_read_perm(<perm>) ∧ admin, reuse the /deposit pattern): /deposit(v_deposits,deposit), /bank-statements(bank_statements,bank-transactions), /payout(v_payouts,payout), /wallet(wallet,wallet), /wallet-logs(wallets_change_logs,wallet-log), /queue(withdrawal_queue,withdrawal-queue), /transaction(transactions,transaction), /mdr-shared(mdr_shared,mdr-shared), /activity-log(audit_log,activity-log), /callbacks(callback_queue,activity-log), /dashboard(composed from v_deposits+v_payouts+wallet+transactions). Retired mock /bank-transactions → redirect to /bank-statements.

GOTCHA — order-by column varies; NOT every table has created_at. ts_*/v_*/wallet/wallets_change_logs/callback_queue have created_at; but audit_log→action_at, mdr_shared→distributed_at, callback_attempts→attempted_at. Ordering by created_at on those throws PostgREST 42703. Always confirm the timestamp column per table.

GOTCHA — realtime publication membership is partial. In supabase_realtime: ts_deposits, ts_payouts, bank_statements, withdrawal_queue, callback_queue, callback_attempts. NOT published: wallet, wallets_change_logs, audit_log, mdr_shared, transactions. For unpublished tables, postgres_changes never fires → use src/lib/realtime.ts `liveRefresh(table, onChange, pollMs)` which subscribes + polls; pass a PROXY published table (ts_deposits — deposit finalize drives wallet/mdr/txn/audit writes) for the unpublished ones, plus a poll fallback. No migration needed.

GOTCHA — mdr_shared is a DISTRIBUTION LEDGER (deposit_id, partner_id, share_amount, wallet_before/after, distributed_at), NOT the mock's partner/client % config. Render the ledger.

GOTCHA (review R1, PR#8) — match_status is a ratified 5-value enum (pending|matched|unmatched|review|fee, ADR-4b FC1 CHECK). NEVER collapse to binary: per-tab counts must equal rows the filter shows (a `rows−matched` count is the count≠rows bug), and tones must be distinct — fee is NEUTRAL (terminal by-design), review is INFO (held for human), unmatched is DANGER, not all "warning". Same lesson as the deposit count≠rows bug.

READ-ONLY conversions drop mock write-actions (payout complete/fail/cancel, queue dispatch/retry) + fake modals (transaction MdrBreakdown). transactions.status is an INTEGER (txnStatusMeta: 1=completed,0=pending,3/-1=failed, else show code).

BLOCKED → next-dev (no admin-readable view in sinuw): settlements (no table at all), merchants/clients/partners (entity tables SELECT-revoked SV7b / no has_read_perm policy → need v_merchants/v_clients/v_partners + perms + RLS), topups (no table).

PR chain stacked: #8(deposit fix+bank-statements+QR) → #9 PR-B(wallet ledger) → #10 PR-A(dashboard/payout/transaction) → #11 PR-C(callbacks/activity-log/mdr-shared). When the bottom PR gets review changes, rebase the stack onto it (git rebase + force-with-lease) so upper PRs don't appear to revert the fix.

---
*Added via Oracle Learn*
