---
title: UploadSlipAdmin hardening — three independent-but-related fixes shipped 2026-04-
tags: [technical-writer, repo:mobiz-payment-gateway, current, deposit, upload-slip, thunder, admin-bypass, slip-duplicate-of, body-limit, defensive-coding]
created: 2026-04-18
source: controllers/DepositController.go:1851-2060@37dfb26 + main.go:48-52@37dfb26
project: github.com/kokarat/mobiz-payment-gateway
---

# UploadSlipAdmin hardening — three independent-but-related fixes shipped 2026-04-

UploadSlipAdmin hardening — three independent-but-related fixes shipped 2026-04-18 turn slip-upload from a failure-fragile path into a best-effort one.

Before: Thunder verify timeout/failure → 500 (slip lost). Admin re-uploading a known-duplicate slip → 500 (MongoDB unique index on `slip_trans_ref` rejected the write even though admin bypass was logically intended). Images >4 MB → rejected at Fiber `BodyLimit` default with "Request body too large" before controller ever ran.

After (at HEAD `37dfb26`, cumulative across three PRs):

1. `#219` `1d39193` — Thunder verify wrapped in `defer recover()` + retry-up-to-2 loop. On panic or final retry failure, `verifyResult` becomes `{success: false, error: <msg>}` and the slip is still saved with `status = "checking"` for manual admin verification. Thunder is now best-effort, not blocking.
2. `#221` `68f82f5` — (a) request context timeout 30s → 90s (`context.WithTimeout(context.Background(), 90*time.Second)`). (b) admin-bypass-duplicate path now **clears `transRef`** before the `$set` (so `slip_trans_ref` is not written) and records the collision in a new `slip_duplicate_of` field (string, prior deposit's `request_id`). This was the actual root cause of the admin-500: the bypass check ran, but the subsequent update still tried to write the duplicate `slip_trans_ref` value and the unique index rejected it.
3. `#222` `dbf2f4e` — response `data` object now echoes `duplicate_of` (the `slip_duplicate_of` value) so the admin UI can render "this slip duplicates <request_id>" alongside Thunder's `verify_result`.
4. `#226` `37dfb26` — Fiber `BodyLimit` raised 4 MB → 10 MB in `main.go:51` to match the ingress `proxy-body-size`; slip images >4 MB now reach the controller. Note: the `RequestSizeLimiter(1MB)` Fiber middleware in the global chain is not reconciled with this — filing as [UNVERIFIED] in §1 for a follow-up read. Likely `RequestSizeLimiter` excludes multipart bodies or is superseded by `BodyLimit` for multipart — not yet confirmed.

New field on `Deposit`: **`slip_duplicate_of`** (string, request_id of the earlier deposit whose `slip_trans_ref` collided with this one). Written only by admin-bypass path; empty for non-duplicate uploads and for non-admin uploads. Not indexed. Semantically pairs with the existing `slip_trans_ref` (unique) and `slip_image` fields.

Response shape change (trivial but client-visible): `POST /deposits/:id/upload-slip` success body `data` now always carries `duplicate_of: <string or "">`.

Observations:
- The three PRs landed in rapid succession (19:23, 19:45, 20:14 GMT+7 2026-04-18) clearly in response to an operational incident. No retro was filed at the time; the fix pattern suggests the incident was "admin tried to re-upload a duplicate, 500, slip lost" — all three PRs address different surfaces of that single failure.
- `slip_duplicate_of` is not yet declared in the `Deposit` struct comment block (`models/deposit.go`) visible in prior baselines. Likely a freshly-added field; worth verifying the struct field for bson tag + JSON tag on the next baseline pass.

---
*Added via Oracle Learn*
