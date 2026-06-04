---
title: payout MarkFailed refund/reconcile race — CAS guard + stable log sort fix the wallet/audit arm (#499, #498)
tags: [technical-writer, repo:mobiz-payment-gateway, current, payout, wallet, drift]
created: 2026-06-01
source: services/withdrawalQueue.go:1436-1483@baa35a9, controllers/WalletChangeLogController.go:125-130@444a061
project: github.com/kokarat/mobiz-payment-gateway
---

`MarkFailed` spawns two parallel goroutines: `processPostCompletion(item,"failed")` (refunds `amount+payout_fee` to the client wallet) and `tryReconcileAfterMarkFailed` (re-deducts if a bank statement matched). On `PAY1780057287J1HKJT` (2026-05-29) the reconcile finished at 12:43:02.011 UTC and the refund 485 ms later credited the wallet back — **net wallet movement stayed correct (−amount−fee)** but the wallet-change-log showed a `payout_refund` as the latest event on a `completed` payout (an "active refund on a completed payout" audit anomaly).

**Fix (financial — CC code_reviewer):**
- `baa35a9` #499: refund branch now CAS-claims before touching the wallet — `UpdateOne({_id, status:"failed", refunded_at:{$exists:false}}, $set:{refunded_at, refunded_amount, refunded_date_bkk})`. `MatchedCount==0` → bail silently (reconcile already moved it out of `failed`). Three new optional schema-additive fields on `ts_payouts`. Companion `scripts/reverse_late_refund_pay1780057287.go` (dry-run default, idempotent via a `payout_refund_reversal` compensating row) repaired the one historical case.
- `444a061` #498: all four `WalletChangeLogController` list queries sort `bson.D{{created_at:-1},{_id:-1}}` (was single-key `bson.M`). `created_at` is per-second; the `_id` (ObjectId, monotonic) tie-breaker stops same-second refund/reconcile pairs displaying in reverse causal order.

**Still open:** the structural double-*callback* race (§9 DRIFT-11) is NOT fixed — both goroutines can still dispatch callbacks; the reconcile side is not yet symmetrically CAS-guarded ("follow-up" per the #499 commit). Documented in `current-system.md` §6.1 + §3.2 (wallet-change-log) + DRIFT-11 status update. Related: [[2026-04-17_fact-markfailed-callback-race-still-at-head-ed45b7e]].
