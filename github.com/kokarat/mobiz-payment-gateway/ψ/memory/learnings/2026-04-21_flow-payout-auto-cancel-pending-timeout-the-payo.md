---
title: Flow: payout-auto-cancel-pending-timeout. The PayoutExpiryScheduler (scheduler/p
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, payout-auto-cancel-pending-timeout, payout, scheduler, timeout, auto-cancel, wallet-refund, withdrawal-queue, callback, reverse-engineered, ratification-pending, s4]
created: 2026-04-21
source: docs/flows/payout-auto-cancel-pending-timeout.md@74689ec
project: github.com/kokarat/mobiz-payment-gateway
---

# Flow: payout-auto-cancel-pending-timeout. The PayoutExpiryScheduler (scheduler/p

Flow: payout-auto-cancel-pending-timeout. The PayoutExpiryScheduler (scheduler/payout_expiry.go, 1-minute tick) is the forcing function that closes out pending payouts that never got claimed by a bot. Every tick: (1) reads payout_auto_cancel_enabled via GetAppSettingBoolStrict — fails closed on DB error so an operator pause can't be silently overridden by a Mongo blip; (2) acquires the lock:payout_expiry distributed lock (55s TTL); (3) finds ts_payouts.status=pending with createdAt older than app_settings.payout_pending_timeout_minutes (default 15 min); (4) per row, atomically CAS status → cancelled, calls services.CancelBySource to cancel any pending withdrawal_queue row, refunds amount+payout_fee to the client wallet via helpers.AtomicBalanceAdd, writes a wallets_change_logs row (operation=payout_refund, changed_by=payout_expiry_scheduler), publishes SSE payouts/cancelled, and fires an async payout.cancelled callback via CallbackService.SendPayoutCallback. Four reverse-engineered open questions folded into Oracle thread #31: (a) flip-before-refund has no rollback path and no transaction — divergent from admin-initiated CancelPayout which uses a session; (b) CancelBySource return value is discarded; (c) bank lock is not released on queue-cancel — bank may stay busy for up to 15 min until stale-lock sweep; (d) scheduler-killed-mid-tick has no callback-resend machinery, paired with deposit-side regression-candidate (deposit-auto-expire-pending thread #19 Q-d). Sibling on deposit rail: deposit-auto-expire-pending (same scheduler pattern, no wallet touch, no queue coupling). Sibling on payout rail: MaintenanceCancelScheduler (same semantics, different entry gate). Doc at docs/flows/payout-auto-cancel-pending-timeout.md@pending-commit. W8 root trace 7d0880fb-91bc-49cc-bdd5-4e7f4574310e. Claim strength S4, [RATIFICATION_PENDING:31].

---
*Added via Oracle Learn*
