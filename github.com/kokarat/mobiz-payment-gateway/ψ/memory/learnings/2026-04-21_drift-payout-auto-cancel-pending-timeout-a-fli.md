---
title: drift — payout-auto-cancel-pending-timeout (a) flip-before-refund with no rollba
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, followup, flow:payout-auto-cancel-pending-timeout, atomicity, transaction, rollback, refund, scheduler]
created: 2026-04-21
source: docs/flows/payout-auto-cancel-pending-timeout.md + scheduler/payout_expiry.go:161-187,217-223@74689ec + controllers/PayoutController.go:913-1135@74689ec + thread #31 closed 2026-04-21
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — payout-auto-cancel-pending-timeout (a) flip-before-refund with no rollba

drift — payout-auto-cancel-pending-timeout (a) flip-before-refund with no rollback vs admin path atomic transaction. `scheduler/payout_expiry.go:process()` commits the `ts_payouts.status → cancelled` CAS (`:161-169`) BEFORE attempting `AtomicBalanceAdd` (`:187`). On refund failure there is no rollback, no retry, and the SSE + callback at `:217-223` still fire unconditionally. Contrast: `controllers.PayoutController.CancelPayout` (admin-initiated at `:913-1135`) uses `session.WithTransaction` wrapping payout-update + queue-cancel + wallet-refund + change-log — on refund failure the whole transaction aborts and the payout stays pending. Ratified via Oracle thread #31 on 2026-04-21 as drift — should fix. Recommended fix: wrap 6a + 6c (CancelBySource) + 6d (AtomicBalanceAdd) + 6f (wallets_change_logs InsertOne) inside a single `session.WithTransaction` block modeled on `PayoutController.CancelPayout:996-1135`. SSE publish (6g) and callback goroutine (6h) stay outside the transaction — both are best-effort fire-and-forget. If (a) lands, question (b) (discarded CancelBySource error) is effectively resolved in the same change — the transaction will abort on queue-cancel failure. Queued for W4 pickup.

---
*Added via Oracle Learn*
