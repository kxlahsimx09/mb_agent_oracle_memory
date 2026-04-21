---
title: regression-candidate — callback resend with idempotency needed on BOTH payout-au
tags: [technical-writer, repo:mobiz-payment-gateway, current, regression-candidate, callback, idempotency, flow:payout-auto-cancel-pending-timeout, flow:deposit-auto-expire-pending, scheduler, durability]
created: 2026-04-21
source: docs/flows/payout-auto-cancel-pending-timeout.md + docs/flows/deposit-auto-expire-pending.md + services/callbackService.go:379-422@74689ec + threads #31 + #19
project: github.com/kokarat/mobiz-payment-gateway
---

# regression-candidate — callback resend with idempotency needed on BOTH payout-au

regression-candidate — callback resend with idempotency needed on BOTH payout-auto-cancel-pending-timeout and deposit-auto-expire-pending TTL-terminals. If the scheduler is killed between the CAS-flip (committed) and the callback-goroutine-spawn (not yet fired), the client never receives the terminal callback AND there is no recovery mechanism — the next scheduler tick's Find filter won't re-pick the row because it's already in a terminal status (`cancelled` for payout, `expired` for deposit). The `services.CallbackService` at HEAD `74689ec` has no scheduled resend loop for payouts. For deposits, a `ProcessPendingCallbacks` function exists (`services/callbackService.go:379-422`) but is NOT wired to any scheduler — latent, not dead, per deposit-auto-expire-pending thread #19 Q-b ruling. Ratified via Oracle thread #31 on 2026-04-21 (payout side) and thread #19 earlier (deposit side). The unified fix sketch: (i) add `callback_sent` + `callback_attempts` + `last_callback_attempt_at` fields to both `ts_payouts` and `ts_deposits`, (ii) wire or create a `PendingCallbacksScheduler` that scans for terminal rows with `callback_sent=false` periodically, (iii) ensure the callback delivery path sets `callback_sent=true` idempotently so re-fire on restart is safe, (iv) guard against duplicate-delivery with a unique callback-event-id or `If-None-Match`-style check on the client side. Ratified scope: the fix should serve both rails simultaneously — a combined PR would collapse two regression-candidates into one primitive. Learning cross-links: deposit-side regression-candidate learning (from thread #19), payout-side ratification (thread #31). Queued for W4 pickup as a high-value but non-urgent regression hardening — no active production incident but the invariant "every terminal state produces one callback" is violated in the kill-mid-tick window.

---
*Added via Oracle Learn*
