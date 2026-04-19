---
title: drift — flow:payout-request (c) confirm-completed exists but no confirm-failed f
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, followup, flow, payout-request, waiting-to-review, admin-action, audit-log, rbac, api-symmetry]
created: 2026-04-18
source: routes/payout.go:31@4e84ad5 + controllers/PayoutController.go:498-910,1566-1870@4e84ad5 + thread #8
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — flow:payout-request (c) confirm-completed exists but no confirm-failed f

drift — flow:payout-request (c) confirm-completed exists but no confirm-failed for waiting_to_review resolution.

Location: routes/payout.go:31 (confirm-completed only) + controllers/PayoutController.go:1566-1870 (ConfirmPayoutCompleted) + controllers/PayoutController.go:498-910 (UpdatePayoutStatus — generic path admins must use for the failure branch) @ 4e84ad5.

Asymmetry: When an admin resolves a `waiting_to_review` payout by ruling that the bank DID transfer (forward branch), they call PUT /api/v1/payouts/:id/confirm-completed which:
- Requires `Reason` field (validated mandatory)
- Persists 4 dedicated reviewer audit fields (confirmed_completed_at, confirmed_completed_by, confirmed_completed_by_username, confirm_completed_reason)
- Writes wallets_change_logs with semantic operation="payout_confirm_completed"
- Distributes MDR atomically inside the same session txn
- Has a CAS double-confirm guard (rejects if confirm_completed_reason is non-empty)
- Publishes specific SSE event "confirmed_completed"

When the same admin rules the bank did NOT transfer (rejection branch), they fall back to PUT /api/v1/payouts/:id/status which:
- Reason is optional `notes` (free text, not validated)
- Persists only 2 generic fields (status_changed_by, status_changed_type) — same fields used for any status change including pending→processing
- Writes wallets_change_logs with operation="add" (the same generic op used for manual balance adjustments — not semantically distinguishable from a non-admin event)
- No MDR (refunds wallet instead, which is correct)
- No CAS guard against two admins racing to flip waiting_to_review→failed
- Publishes generic SSE event "updated"

Evidence this is a coverage gap not intentional asymmetry:
1. PR #208 (waiting_to_review backend, 2026-04-17) added the status + bot endpoint but only added admin-side resolution for the forward branch. PR #211/#212/#213/f44cf44 (2026-04-17–18) extended confirm-completed (allow waiting_to_review, log username, fix double-deduction); the rejection branch was not touched.
2. UpdatePayoutStatus's status validation list now includes "waiting_to_review" (line 519) — the value was added to enable the generic path, but no audit fields were paired alongside.
3. UpdatePayoutStatus uses operation="add" for refunds where every other refund path in the codebase uses semantic operations like "payout_refund", "settlement_refund". The generic "add" here is inconsistent.
4. CLAUDE.md status-code convention pairs 1=Approved/Completed with 2=Rejected/Failed, and settlements expose is_approved={0,1,2} suggesting approve/reject is a bilateral first-class concept across the system. Payout's waiting_to_review resolution is the only place this bilateral pattern is broken.

Human ruling (2026-04-18, Oracle thread #8): coverage gap, fix later.

Recommended fix (two options, pick by appetite):

Option A (lighter, ~30 LoC): Validate-only fix in UpdatePayoutStatus — when source status = waiting_to_review AND target status = failed, require the Reason field and persist confirmed_failed_{at,by,by_username,reason} audit fields; change operation in wallets_change_logs from "add" to "payout_confirm_failed". Generic endpoint surface unchanged; audit win realised.

Option B (full symmetry, ~150 LoC): Add a paired PUT /api/v1/payouts/:id/confirm-failed route mirroring confirm-completed's shape — mandatory Reason, dedicated confirmed_failed_* fields, CAS guard against re-confirmation, semantic operation="payout_confirm_failed", specific SSE event "confirmed_failed", specific callback event. Generic UpdatePayoutStatus stays for legacy admin-status flips but the canonical waiting_to_review resolution becomes the paired endpoints.

Source: docs/flows/payout-request.md@a91cb76 §Resolved questions (c) + routes/payout.go:31@4e84ad5 + controllers/PayoutController.go:498-910,1566-1870@4e84ad5
W8 root trace: ba99f3b3-6e59-4348-8878-f180a1fee17e
Ratification thread: #8
Queued for: W4 reconciliation pass; affects RBAC + admin UX so loop in security_auditor + frontend team if Option B is chosen.

---
*Added via Oracle Learn*
