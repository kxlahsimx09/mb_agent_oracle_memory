---
name: drift — settlement UPDATE, DELETE, and CANCEL routes are gone
description: routes/settlement.go explicitly removes UpdateSettlement ("if data is wrong, reject and create new one"), DELETE ("settlements must be kept for audit log"), and has no /cancel route. CLAUDE.md still documents all three.
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - settlement
  - drift
source: routes/settlement.go @ 379e984
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-15
---

# DRIFT — Settlement route surface shrank

## Fact

`routes/settlement.go` carries inline rationale comments:

- `// UpdateSettlement removed — if data is wrong, reject and create new one`
- `// DELETE removed — settlements must be kept for audit log`

No `/:id/cancel` route exists. The only status-changing verbs are `/:id/approve` and `/:id/reject`. CLAUDE.md §"Settlement Management" still lists `PUT /api/v1/settlements/:id`, `PUT /api/v1/settlements/:id/cancel`, and `DELETE /api/v1/settlements/:id`.

The controller's `CreateSettlement` is still exposed at `POST /settlements` (no permission gate at the route level — access control is enforced inside the controller so partners/clients can create for themselves).

## Why it matters

- The "settlement lifecycle" diagram in downstream docs needs to show: `create → approve|reject` only; no edit, no cancel, no delete.
- Rejection is the compensating action for mistakes — not edit. Audit log is preserved by design.

## How to apply

- Any state-transition table for settlements must exclude update/cancel/delete.
- In runbooks: "if a settlement has wrong data, admin rejects it (balance refunded) and the partner creates a new one."

## Trace

commit `379e984` → docs/current-system.md §2 + §3.2 + §9 DRIFT-7 → resolution PR (this PR)
