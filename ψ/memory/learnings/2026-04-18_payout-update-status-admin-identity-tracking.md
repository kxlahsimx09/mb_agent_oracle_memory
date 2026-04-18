---
title: PUT /payouts/:id/status now records admin identity on every non-completed status transition
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - payout
  - audit-trail
  - rbac
  - wallet
created: 2026-04-18
source: controllers/PayoutController.go:506-519,800-818,870-885@f44cf44
related:
  - 2026-04-16_deposit-approval-admin-username-197-186-187
project: github.com/kokarat/mobiz-payment-gateway
---

# PUT /payouts/:id/status now records admin identity on every non-completed status transition

Commit `7526257` (#211, 2026-04-18) extended payout admin audit with three linked changes:

1. **Payout document — two new fields.** Every non-completed status flip via `PUT /api/v1/payouts/:id/status` now writes `status_changed_by` (string — `c.Locals("username")`, falling back to `"system"` if empty) and `status_changed_type` (string — `c.Locals("user_type")`, falling back to `"system"`). Applied in both the "refund path" (§3.2.1 is the other end; this path is the non-completed branch at `controllers/PayoutController.go:800-818`) and the early path at `:584-594`.

2. **Wallet change log — admin fields populated.** The refund-path change-log row previously wrote `ChangedByType: "system"` unconditionally. Now it writes `ChangedBy: adminUsername` + `ChangedByType: adminUserType` and the human-readable `Note` includes "refund by `<username>`". This aligns payout refund logs with the `#186`/`#197` pattern already applied to deposit approval and other payout wallet-change-log rows.

3. **Atomic filter widened.** The refund-path `UpdateOne` previously matched `status: {$in: ["pending", "processing"]}`. It now matches `{$in: ["pending", "processing", "waiting_to_review"]}` so admins can move stuck waiting-to-review payouts to `failed`/`cancelled` without first routing through `/confirm-completed`. This is separate from the confirm-completed change (#212/#213/f44cf44) — see `2026-04-18_payout-confirm-completed-accepts-waiting-to-review-with-conditional-deduction.md` for that path.

## Why this matters

- **Audit trail completeness.** Before #211, payout status transitions tracked the admin only on the confirm-completed and override paths. Plain status updates (e.g. `processing → failed`, `pending → cancelled`) were anonymous on the payout doc and hard-coded as "system" in the change-log. Now every transition carries the human who did it.
- **Waiting-to-review state mobility.** The refund-filter widen is the admin escape hatch from `waiting_to_review` without claiming the money was collected. If a bot reports waiting_to_review but an operator later confirms the transfer actually failed at the bank, the admin flips to `failed` and the wallet refund fires in the same handler.
- **Entity convention unchanged.** `status_changed_type` is a free-form string (user_type from the JWT), not the 0/1/2 entity convention; "system" is reserved for fallback.

## Docs updated (docs/current-system.md @ b886cc4 post-W2)

- §2 Payout row — new fields `status_changed_by`, `status_changed_type` added to the field list with citation `@f44cf44`.
- §3.2 `/api/v1/payouts` bullet — expanded to note the admin tracking + widened refund filter.

No CLAUDE.md update this pass — CLAUDE.md's "Payout Management" section stays §9 DRIFT-9 territory.
