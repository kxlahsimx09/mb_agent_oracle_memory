---
title: ## MaintenanceCancelScheduler gate narrowing — `IsInMaintenanceWindow()` vs `Che
tags: [repo:mobiz-payment-gateway, scheduler, technical-writer, maintenance, current, flow:payout]
created: 2026-04-19
source: pg-writer-oracle W2 @ 386f0a71
project: github.com/kokarat/mobiz-payment-gateway
---

# ## MaintenanceCancelScheduler gate narrowing — `IsInMaintenanceWindow()` vs `Che

## MaintenanceCancelScheduler gate narrowing — `IsInMaintenanceWindow()` vs `CheckMaintenanceMode("payout")`

Observed in `scheduler/maintenance_cancel.go` at commit `386f0a71` (mobiz-payment-gateway main, 2026-04-20):

### What changed
- Previous behavior: scheduler ticked through pending withdrawals and cancelled them whenever `CheckMaintenanceMode("payout")` returned true. That check also returned true when the `payout_enabled` flag was simply flipped off (no active maintenance window, just a feature-gate).
- Current behavior (commit `0e5ea1b`, issue `#236`): scheduler only cancels pending items when `IsInMaintenanceWindow()` returns true — i.e. there is a currently-active maintenance time window.

### New helper
- `helpers/maintenance.go:104-139` — `IsInMaintenanceWindow() bool` reads the maintenance schedule from app settings and returns true only if `now()` falls within an active configured window. It does NOT reflect the `payout_enabled` flag.

### Why
- Operator use case: admins disable `payout_enabled` when a partner-bank has noisy statements and they want to block *new* payout requests at the API layer, but they do not want the backlog of already-pending-and-assigned payouts to get bulk-cancelled.
- Issue `#236` captured real operator complaints about "pending payouts kept getting auto-cancelled every minute when I disabled payouts temporarily."

### How to apply
- When a reviewer sees `IsInMaintenanceWindow` being called and asks "why not just `CheckMaintenanceMode`?" — the answer is: feature-gate vs. time-window are semantically different now, by design.
- When adding a new cancel/block gate, choose the helper that matches the desired blast radius:
  - `CheckMaintenanceMode(method)` → "is this method disabled right now, for any reason?" (API-layer gate on new requests)
  - `IsInMaintenanceWindow()` → "are we actively inside a scheduled maintenance window?" (destructive operations on existing state)

### Reflected in `docs/current-system.md`
- §5 MaintenanceCancelScheduler row now cites `scheduler/maintenance_cancel.go:77-80@386f0a71` + `helpers/maintenance.go:104-139@386f0a71`.

citations: `scheduler/maintenance_cancel.go:77-80@386f0a71`, `helpers/maintenance.go:104-139@386f0a71`
commit: `0e5ea1b` (fix: narrow maintenance-cancel gate to active window only, #236)
baseline: pg-writer-oracle W2 pass from `1ffafc13..386f0a71`

---
*Added via Oracle Learn*
