---
title: drift — flow:deposit-slip-upload-admin-approve (c) reject branch does not write 
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, followup, flow, deposit-slip-upload-admin-approve, admin-action, audit-log, rejection, compliance, deposit]
created: 2026-04-18
source: controllers/DepositController.go:784-794,1127-1180@c5270b3 + thread #6
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — flow:deposit-slip-upload-admin-approve (c) reject branch does not write 

drift — flow:deposit-slip-upload-admin-approve (c) reject branch does not write approved_by / approved_by_type / approved_at audit fields.

Location: controllers/DepositController.go:784-794 (paid branch — DOES write audit fields) versus :1127-1180 (non-paid / reject branch — does NOT) @ c5270b3.

What happens: when an admin updates a deposit's status, the paid-branch atomically writes `approved_by`, `approved_by_type`, `approved_at` reviewer audit fields onto the `ts_deposits` row alongside the wallet credit + MDR distribution. The non-paid branch (reject path; e.g., admin rules "this slip is forged" on a `checking` deposit) writes only `status`, `updated_at`, and free-text `notes` — none of the structured reviewer fields are set. So a rejected deposit does NOT carry a queryable record of WHO rejected it, WHEN, or WHY (beyond optional notes).

Why it's a gap: same accountability concern as flow:payout-request question (c). Reject of a `checking` deposit is an admin decision that today leaves no structured audit trail. An ops review of "why was deposit X rejected and by whom?" today requires `wallets_change_logs` cross-reference (which only records the wallet refund, not the rejection decision) plus the optional free-text `notes` field (which may be empty). Compliance / dispute investigation is brittle.

Cross-reference: payout-request flow has the SAME structural gap — `confirm-completed` admin endpoint persists `confirmed_completed_{at,by,by_username,reason}` but the rejection branch (generic `UpdatePayoutStatus`) does not. Both flows should be fixed together for consistency.

Human ruling (2026-04-18, Oracle thread #6): drift / coverage gap; fix later.

Recommended fix: in the non-paid branch of UpdateDepositStatus, persist `rejected_by`, `rejected_by_type`, `rejected_at` reviewer audit fields. Make `reason` (currently optional `notes`) MANDATORY when source status = `checking` AND target = rejected (since that's the admin-decision case; pending → rejected from the matcher path remains optional `notes` for backward compat). ~25 LoC. Pairs symmetrically with the paid branch.

Bigger picture: a `#decision` learning may be worth filing for the team — "all admin rejections of human-curated states should carry structured reviewer audit fields" as a cross-cutting compliance rule. That would force payout (c) and deposit (c) to be fixed together. Mention in W4 follow-up.

Source: docs/flows/deposit-slip-upload-admin-approve.md@&lt;ratification-commit&gt; §Resolved questions (c) + controllers/DepositController.go:784-794,1127-1180@c5270b3
W8 root trace: 4b076751-86c5-42b6-ba5a-e3dfea9ea6b3
Ratification thread: #6
Queued for: W4 reconciliation pass; recommend bundling with flow:payout-request (c) (`2026-04-18_drift-flowpayout-request-c-confirm-completed`).

---
*Added via Oracle Learn*
