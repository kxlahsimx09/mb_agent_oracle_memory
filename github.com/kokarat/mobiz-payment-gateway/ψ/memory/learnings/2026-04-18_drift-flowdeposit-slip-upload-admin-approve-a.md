---
title: drift — flow:deposit-slip-upload-admin-approve (a) admin-only transRef duplicate
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, followup, flow, deposit-slip-upload-admin-approve, admin-action, audit-log, deposit, support-workflow]
created: 2026-04-18
source: controllers/DepositController.go:1954-1973@c5270b3 + thread #6
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — flow:deposit-slip-upload-admin-approve (a) admin-only transRef duplicate

drift — flow:deposit-slip-upload-admin-approve (a) admin-only transRef duplicate bypass with no audit/log.

Location: controllers/DepositController.go:1954-1973 @ HEAD-when-doc-was-authored c5270b3 (still current behaviour at 2026-04-18 HEAD).

What happens: when a slip is uploaded for a deposit, the controller checks for slip-duplicate (`transRef` already attached to another deposit). The client-facing code path returns HTTP 409 on duplicate. The admin path (when `user_type IN ["user", "admin"]`) silently bypasses the duplicate check — admins can attach the same slip to multiple `ts_deposits` rows. No log, no audit row, no warning surfaced to ops.

Why it exists: support-workflow concession. When ops staff are reconciling a confused customer/payer case, they may need to mark multiple deposits as paid using the same slip image (e.g., one slip covers two split deposits). Removing the bypass would block legitimate ops work.

Why it's a gap: when the bypass fires it leaves no trail. An auditor reviewing "why are there 3 deposits for the same transRef?" cannot tell:
- Was this an admin's deliberate reconciliation (bypass triggered), or
- Did duplicate-check code have a bug at the time, or
- Was this an attack (an admin account compromise replaying slips)?

The information is currently scattered in admin's verbal context only.

Human ruling (2026-04-18, Oracle thread #6): drift / coverage gap; fix later.

Recommended fix: keep the admin bypass behaviour (don't break ops workflow) but emit BOTH (a) a `WARN` log line naming the bypassed `transRef`, the conflicting deposit ids, and the admin's username, AND (b) an `audit_logs` row with action="slip_dup_admin_bypass", actor=admin user id, target=deposit id list. ~20 LoC. Audit win without behaviour change.

Source: docs/flows/deposit-slip-upload-admin-approve.md@&lt;ratification-commit&gt; §Resolved questions (a) + controllers/DepositController.go:1954-1973@c5270b3
W8 root trace: 4b076751-86c5-42b6-ba5a-e3dfea9ea6b3
Ratification thread: #6
Queued for: W4 reconciliation pass.

---
*Added via Oracle Learn*
