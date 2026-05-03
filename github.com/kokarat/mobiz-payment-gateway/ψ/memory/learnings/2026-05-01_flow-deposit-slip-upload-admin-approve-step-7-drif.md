---
title: Flow deposit-slip-upload-admin-approve step 7 drift: new fraud-block error paths
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, flow-drift, flow:deposit-slip-upload-admin-approve, step:7, deposit, fraud, slip]
created: 2026-05-01
source: docs/flows/deposit-slip-upload-admin-approve.md
project: github.com/kokarat/mobiz-payment-gateway
---

# Flow deposit-slip-upload-admin-approve step 7 drift: new fraud-block error paths

Flow deposit-slip-upload-admin-approve step 7 drift: new fraud-block error paths added before the §Step 8 atomic block but not yet reflected in §Error paths or §Sequence. Code at controllers/DepositController.go:817-845@a463f51 (a463f51 #361, 2026-05-02) blocks status→paid on slip-bearing deposits when caller user_type is not admin|user OR username is ""/"system" (closes the bot-route loophole on the shared UpdateDepositStatus handler). Code at controllers/DepositController.go:847-889@a463f51 (ef71420 #360, 2026-05-02) blocks status→paid when slip's receiver-account last-4 does not match deposit.PromptPayID last-4 (super_admin override via "[force-approve]" in notes; both fail-open when slip data is empty). Flow's Sequence diagram still shows the original Step 7 → Step 8 atomic block transition as if it were monolithic; Error paths section does not list the new 403 (slip-bearing-needs-human-admin) or 400 (slip-receiver-mismatch) responses. W9 pass added a [DRIFT] marker inline at Step 7's pointer description naming both new code blocks; the §Error paths body and the Sequence diagram need W8-style authoring to add: a "Step 7a: pre-paid fraud-block guards" sub-step, two new error-path bullets (one per guard), and possibly a postcondition note on the override-allowed branch. Queued for W4 / W8 revision. Bonus side-finding flagged in same edit: the prior pointer "controllers/DepositController.go:2049-2068@d2a2738" claimed to point at the UploadSlipAdmin 409-bypass but actually pointed at the Thunder retry loop — legacy line drift carried forward from yesterday's W9 hash bump (9ee63de). Re-anchored to :2146-2174@a463f51.

---
*Added via Oracle Learn*
