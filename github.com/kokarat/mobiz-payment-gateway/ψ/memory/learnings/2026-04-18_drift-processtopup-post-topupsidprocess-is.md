---
title: drift — ProcessTopup (POST /topups/:id/process) is dead code; legacy two-phase a
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, dead-code, flow:topup-approve-mdr-distribution, topup, legacy, removal-candidate]
created: 2026-04-18
source: controllers/TopupController.go:1187-1380@252849e, routes/topup.go:30@252849e, git commit 1e1bee8 (2025-11-06)
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — ProcessTopup (POST /topups/:id/process) is dead code; legacy two-phase a

drift — ProcessTopup (POST /topups/:id/process) is dead code; legacy two-phase approval remnant.

`routes/topup.go:30@252849e` registers `POST /topups/:id/process` → `controllers.TopupController.ProcessTopup` (`:1187-1380@252849e`). Handler expects state `(status=1 AND processed≠true)` — a state that is **unreachable** in the current repo via any application code path.

**Evidence:**
- Git trace: commit `1e1bee8` (2025-11-06, "Fix critical topup fee distribution race conditions with MongoDB transactions") introduced `processTopupApproval` that atomically sets BOTH `status=1` AND `processed=true` in one `FindOneAndUpdate`. Before that commit, the flow was two-phase: `PUT /status=1` flipped status only, admin later called `POST /:id/process` to credit wallet.
- After `1e1bee8`, the two-phase `ProcessTopup` handler was not deleted.
- All `Status: 1` / `"status": 1` assignments in topup controllers at HEAD `252849e`:
  - `CreateTopup:291` → status=0
  - `CreateTopupWithSlip:1708` → status=0
  - `UpdateTopup:541-622` → does not touch status
  - `processTopupApproval:759` → status=1 + processed=true atomically
  - `processTopupRejection` → status=2
  - `CancelTopup:1941` → status=3
  - No other code path produces (status=1, processed=false).
- Not in `swagger_simple.json` (`/topups/.*/process` → 0 matches).

**Additional risk:** `ProcessTopup` does NOT distribute MDR (no partner distribution loop, no `mdr_shared` write, no `mdr_distribution` wallet_change_log). If ever reached via manual DB edit or legacy data, client wallet gets credited but partners silently lose their MDR share — exactly the bug `1e1bee8` was meant to prevent.

**Recommended fix (sequenced):**
1. Query DB for any topup matching `(status=1, processed=false)` — possible legacy data from pre-`1e1bee8` (pre-2025-11-06).
2. If hits: migrate each — either flip `processed=true` + backfill missing `wallets_change_logs` / partner MDR rows, or flag as `needs-manual-reconcile` for ops review.
3. Delete `routes/topup.go:30` route registration + `ProcessTopup` handler at `controllers/TopupController.go:1187-1380` + associated `topup:approve` permission binding for this path.

Ratified via Oracle thread #11 (2026-04-18 GMT+7) during W8 flow topup-approve-mdr-distribution. Queued for W4 pickup.

---
*Added via Oracle Learn*
