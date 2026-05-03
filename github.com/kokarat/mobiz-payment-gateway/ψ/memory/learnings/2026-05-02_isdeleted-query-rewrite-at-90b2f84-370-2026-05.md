---
title: is_deleted query rewrite at 90b2f84 (#370, 2026-05-02): 12 sites switched from `
tags: [technical-writer, repo:mobiz-payment-gateway, current, perf, is-deleted, ne-vs-eq, mongo-index, deposit, scheduler, 90b2f84, pr-370]
created: 2026-05-02
source: controllers/DepositController.go:228,499,555,1473,1545,1599,1681,1825@90b2f84 + scheduler/deposit_expiry.go@90b2f84 + scheduler/maintenance_cancel.go@90b2f84 + scheduler/payout_expiry.go@90b2f84 + scripts/backfill_is_deleted_false.go@90b2f84
project: github.com/kokarat/mobiz-payment-gateway
---

# is_deleted query rewrite at 90b2f84 (#370, 2026-05-02): 12 sites switched from `

is_deleted query rewrite at 90b2f84 (#370, 2026-05-02): 12 sites switched from `is_deleted: {$ne: true}` to `is_deleted: false`. Sites: `controllers/DepositController.go` (8 sites: GetAllDeposits + GetDepositByID + GetDepositsByClientID + DeleteDeposit and 4 more), `scheduler/deposit_expiry.go`, `scheduler/maintenance_cancel.go` (2 sites), `scheduler/payout_expiry.go`. Motivation: the compound index `{created_date_bkk:-1, is_deleted:1}` already exists, but `$ne` forces the planner to scan every index entry to verify "not equal" instead of doing a point lookup, defeating the index. Adding more indexes does not help while the predicate stays as `$ne`. Backfill: `scripts/backfill_is_deleted_false.go` — idempotent (only updates documents missing the field); covers `ts_payouts` / `ts_topups` / `ts_settlements` proactively even though those collections are not touched by the query rewrite, so future similar refactors don't need a second migration. Run BEFORE deploying the new query path so legacy rows that pre-date the field don't get filtered out.

---
*Added via Oracle Learn*
