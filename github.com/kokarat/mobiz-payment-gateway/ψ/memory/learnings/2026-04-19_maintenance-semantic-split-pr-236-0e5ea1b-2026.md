---
title: Maintenance semantic split (PR #236, 0e5ea1b, 2026-04-20): helpers/maintenance.g
tags: [technical-writer, repo:mobiz-payment-gateway, current, maintenance, scheduler, payout]
created: 2026-04-19
source: helpers/maintenance.go:47-138 + scheduler/maintenance_cancel.go:77-93 @ 0e5ea1b
project: github.com/kokarat/mobiz-payment-gateway
---

# Maintenance semantic split (PR #236, 0e5ea1b, 2026-04-20): helpers/maintenance.g

Maintenance semantic split (PR #236, 0e5ea1b, 2026-04-20): helpers/maintenance.go now exports two distinct checks. CheckMaintenanceMode(service) returns true when either payout_enabled=false OR the current time is inside maintenance_window — used by PayoutRequestController to reject NEW payout requests. IsInMaintenanceWindow() (new) returns true only for the time-window check, ignoring enabled flags — used exclusively by MaintenanceCancelScheduler. Effect: flipping payout_enabled=false blocks new requests but no longer cancels pending payouts; cancellation only fires during the actual maintenance window. Desired invariant per dev: "payout_enabled=false = API reject; pending payouts continue processing." Reference mental model for future W2 passes: any new scheduler that wants to take destructive action on pending items should use IsInMaintenanceWindow (time only); any new request-path reject should use CheckMaintenanceMode (both signals).

---
*Added via Oracle Learn*
