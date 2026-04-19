---
title: drift — topup reject branch has no structured audit trail.
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, followup, flow:topup-approve-mdr-distribution, reject-audit-gap, topup, accountability]
created: 2026-04-18
source: controllers/TopupController.go:1121-1183@252849e
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — topup reject branch has no structured audit trail.

drift — topup reject branch has no structured audit trail.

`controllers/TopupController.go:1121-1183@252849e` (`processTopupRejection`, entered via `PUT /topups/:id/status` with `status: 2`) writes only:
- `status: 2`
- `approved_by: <admin username>` — **reused for rejection, misleading at query time**
- `approved_by_name: <admin username>`
- `updated_at`
- `notes` (optional, not required)

Missing:
- Dedicated rejection timestamp (`rejected_at`, `rejected_date_bkk`) — today only `updated_at` is bumped
- Dedicated reviewer fields (`rejected_by`, `rejected_by_name`) distinct from approval fields
- Mandatory `rejection_reason` body field
- No `transactions` row (trivially correct — no wallet moved — but no ops-queryable audit trail either)
- No `wallets_change_logs` / `status_change_logs` row to make rejection events queryable independently of the topup row itself

**Impact:** accountability gap. "Which admin rejected which topups today and why?" requires joining on `topups.status=2 AND updated_at BETWEEN ...` and hoping the admin remembered to fill `notes`. Same accountability concern ratified for `deposit-slip-upload-admin-approve` thread #6(c) and `payout-request` thread #8(c).

**Recommended fix:**
- Persist `rejected_by`, `rejected_by_name`, `rejected_at`, `rejected_date_bkk`, `rejection_reason` on the non-approve branch
- Mandatory `reason` body field when `status == 2` (return 400 if empty)
- Stop reusing `approved_by` / `approved_by_name` for rejections
- Optional: insert a lightweight audit row (either `wallets_change_logs` with `amount: 0` + `operation: "topup_rejected"` + `reference_id: <topupID>`, or a new `status_change_logs` collection)

~30 LoC. Ratified via Oracle thread #11 (2026-04-18 GMT+7) during W8 flow topup-approve-mdr-distribution. Queued for W4 pickup.

---
*Added via Oracle Learn*
