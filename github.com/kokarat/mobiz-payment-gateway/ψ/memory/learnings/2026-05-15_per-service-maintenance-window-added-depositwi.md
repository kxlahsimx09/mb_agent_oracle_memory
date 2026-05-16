---
title: Per-service maintenance window added — `deposit_window` and `payout_window` app_
tags: [technical-writer, repo:mobiz-payment-gateway, current, maintenance, scheduler, deposit, payout, regression-candidate]
created: 2026-05-15
source: helpers/maintenance.go:47-126,218-267@cf3e02f
project: github.com/kokarat/mobiz-payment-gateway
---

# Per-service maintenance window added — `deposit_window` and `payout_window` app_

Per-service maintenance window added — `deposit_window` and `payout_window` app_settings keys (mobiz `cf3e02f` #442, 2026-05-15) let ops schedule daily closes per service independently of the system-wide `maintenance_window`. CheckMaintenanceMode priority chain is now (first match blocks): 1. `<service>_enabled = "false"` manual toggle, 2. `<service>_window` covers now (NEW), 3. `maintenance_window` covers now (system-wide). Critical invariant retained on purpose: `IsInMaintenanceWindow()` still checks ONLY the system-wide window, so MaintenanceCancelScheduler / payout-expire / deposit-expire schedulers do not retroactively cancel items accepted before a per-service window opened — per-service windows refuse NEW requests only. `isInWindowString(window)` helper extracted from the previously-duplicated parse-and-compare logic; CheckMaintenanceMode, IsInMaintenanceWindow, and GetMaintenanceStatus all use it. Public `/api/v1/maintenance/status` response shape extended with `deposit_window`, `payout_window`, `in_deposit_window`, `in_payout_window`, `deposit_blocked`, `payout_blocked`, `deposit_message`, `payout_message`. Existing fields keep semantics so old clients are unaffected. No schema migration; defaults to empty string ("no window"). Frontend GeneralSettings UI for the two new keys ships in a follow-up PR.

---
*Added via Oracle Learn*
