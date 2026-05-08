---
title: MaintenanceCancelScheduler gains per-bank cancellation branch + is_deleted filte
tags: [technical-writer, repo:mobiz-payment-gateway, current, scheduler, maintenance, payout, wallets_change_logs]
created: 2026-05-07
source: scheduler/maintenance_cancel.go:79-303@0424cdc
project: github.com/kokarat/mobiz-payment-gateway
---

# MaintenanceCancelScheduler gains per-bank cancellation branch + is_deleted filte

MaintenanceCancelScheduler gains per-bank cancellation branch + is_deleted filter fix (0424cdc #417, 2026-05-07).

The scheduler used to run only when the global `helpers.IsInMaintenanceWindow()` returned true. After this PR it now has TWO flavours that share `cancelOnePayout(ctx, payout, reason)`:
  1. system-wide — runs only when `IsInMaintenanceWindow()` is true. Fans out to `cancelPendingPayouts` (every pending payout) and `expirePendingDeposits` (existing behaviour).
  2. per-bank — runs every tick. `cancelPendingOnMaintenanceBanks` finds active `system_banks` whose `maintenance_time` covers `now` (filter via `helpers.IsInBankMaintenanceWindow`) and cancels matching `ts_payouts` with `system_bank_id $in [matchedBanks]`.

The per-bank branch closes a long-standing operational issue: a payout sitting on a bank that just entered its 20:00–08:00 window otherwise waited the full 12+ hours for the bank to wake — leaving the client's money locked overnight. Cancellation cascades exactly like the system-wide path: ts_payouts.status → cancelled, withdrawal_queue cancelled via CancelBySource, wallet refunded amount+fee, wallets_change_logs row written (note tagged with `reason` = "system_maintenance" or "bank_maintenance"), payouts/cancelled SSE published, payout.cancelled callback fired.

Bug fix included: `cancelPendingPayouts` filter `{is_deleted: false}` was matching zero docs in production because `ts_payouts` doesn't populate that field — the system-wide window scheduler logged "Maintenance window active" but did nothing. Switched to `{is_deleted: $ne true}` so missing-field rows still match. Note this UNDOES one of the index-eligibility flips done by `90b2f84` #370 (which had switched 2 sites in this file from `$ne true` → `false` for index hits) — those flips were premature because the population had not been backfilled.

Atomic CAS update guards (`{_id, status:"pending"}`) make duplicate work between a global window + per-bank window harmless: the second writer's MatchedCount==0 and the helper returns false without incrementing the counter.

---
*Added via Oracle Learn*
