---
title: flow `deposit-slip-upload-admin-approve` — Class-C drift on the ADMIN alt-entry 
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow-track, flow-drift, drift, flow:deposit-slip-upload-admin-approve, deposit, slip, thunder]
created: 2026-05-22
source: docs/flows/deposit-slip-upload-admin-approve.md, controllers/DepositController.go:2084-2340@9aebabb
project: github.com/kokarat/mobiz-payment-gateway
---

# flow `deposit-slip-upload-admin-approve` — Class-C drift on the ADMIN alt-entry 

flow `deposit-slip-upload-admin-approve` — Class-C drift on the ADMIN alt-entry (W9 pass 2026-05-22, range 2f35356..9aebabb, PR #460). `UploadSlipAdmin` (controllers/DepositController.go, now 2134-2340@9aebabb) was rewritten: it no longer calls Thunder at upload, and the admin-only duplicate-transRef 409-bypass is gone (no transRef exists at upload time). It is now status-aware (pending stays pending → Thunder deferred to the escalation scheduler; non-pending → checking + slip_verify_status=queued + immediate services.ProcessSlipVerification). Steps 3/4 (synchronous Thunder) of this flow's §Sequence no longer apply to the admin alt-entry; a new admin endpoint POST /deposits/:id/reverify-slip (DepositController.go:2084-2132@9aebabb) re-queues Thunder. [DRIFT] added at §Implementation pointers Step-5 admin-alt-entry note + a §Alternate-entry callout (pointers left at prior shorts per W9 Class C). IMPORTANT: the CLIENT path (DepositRequestController.UploadSlip, Steps 1/2/5/6) is UNCHANGED by #460 — only the admin path drifted, so the flow's main client-path sequence still holds (no Class-F downgrade). §Sequence + §Alternate-entry + §Error-paths "Thunder verification fails"/"Duplicate slip" branches need W8 rewrite for the admin path. Pairs with the deposit-auto-expire-pending W9 drift from the same pass. Outcome for this flow: A:0 B:0 C:1 D:0 E:0 F:0.

---
*Added via Oracle Learn*
