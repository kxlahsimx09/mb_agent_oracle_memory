---
title: drift (LOW PRIORITY) — payout-auto-cancel-pending-timeout (c) bank lock not rele
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, followup, priority:low, flow:payout-auto-cancel-pending-timeout, bank-lock, race-condition, dispatcher]
created: 2026-04-21
source: docs/flows/payout-auto-cancel-pending-timeout.md + services/withdrawalQueue.go:1148-1174@74689ec + scheduler/withdrawal_dispatcher.go:694-745@74689ec + thread #31 closed 2026-04-21
project: github.com/kokarat/mobiz-payment-gateway
---

# drift (LOW PRIORITY) — payout-auto-cancel-pending-timeout (c) bank lock not rele

drift (LOW PRIORITY) — payout-auto-cancel-pending-timeout (c) bank lock not released on queue-cancel. If the WithdrawalDispatcher has assigned `system_bank_id` to a queue row and locked the bank `working_status=busy` within the 1-minute tick window before PayoutExpiryScheduler's `CancelBySource` fires, `CancelBySource` cancels the row but does NOT call `onBankItemDone` — the bank stays busy until either (i) another item on the same bank finishes and triggers `UnlockBankIfDone`, or (ii) the 15-minute stale-lock sweep in `scheduler/withdrawal_dispatcher.go:730-745:releaseStaleLocksIfNeeded` force-unlocks it. Race window at default config: ~10 seconds (payout timeout 15 min aligns with stale-lock 15 min). Race window IF operator tunes `payout_pending_timeout_minutes` below 15: up to `15 - timeout_minutes` of ghost-lock. Ratified via Oracle thread #31 on 2026-04-21 as **drift — low priority**. Rationale: no production incident; ops tuning the timeout below 15 min is not a known operational pattern; stale-lock sweep catches it. Fix deferred until either a production throughput incident surfaces or a low-cost bundling opportunity arises. Recommended fix-when-the-time-comes: make `UnlockBankIfDone` idempotent (already is — it counts active items and unlocks only when zero) and call it from `CancelBySource` for each distinct `system_bank_id` in the cancelled rows. Alternative: wire `onBankItemDone` into `CancelBySource` directly via a package-level callback registration. Queued for W4 backlog with `priority:low`.

---
*Added via Oracle Learn*
