---
title: W9 pass 2026-05-23: flows touched by 9aebabb..bf73072 (new commits 15a54a4 idemp
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow-track, w9, pointer-refresh, partial-coverage, idempotency, multi-brand]
created: 2026-05-22
source: docs/flows/deposit-qr-request.md + docs/flows/payout-request.md + docs/flows/deposit-slip-upload-admin-approve.md @15a54a4
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 pass 2026-05-23: flows touched by 9aebabb..bf73072 (new commits 15a54a4 idemp

W9 pass 2026-05-23: flows touched by 9aebabb..bf73072 (new commits 15a54a4 idempotency-v2 + 3ee8018 brand-env; k8s commits out of flow territory). Outcome: 3 flows refreshed Class-B, 5 flows deferred (>5-flow fast-fix threshold split). REFRESHED: (1) deposit-qr-request.md — DepositRequestController pointers shifted by idempotency insertion: CreateDeposit entry 86→105, signature 152→215, persist InsertOne 360→423, SSE 369→432, success-response 372-412→435-474; hash @7e239a5→@15a54a4; added a new Step-2 subpoint for the idempotency-v2 required-header gate at :114-150. (2) payout-request.md — PayoutRequestController Step2 82-178→85-282, Step3 283-336→320-410, Step4 351-453→412-490, Step5 455-478→492-513 (@c7b2232→@15a54a4); its one callbackService pointer 329-421→319-411 (@f16d602→@3ee8018, -10). (3) deposit-slip-upload-admin-approve.md — client UploadSlip pointers +62 from idempotency: entry 806→868, Step2 re-anchored 888-894→907-951 (cleared pre-existing drift), Step5 913-956→975-1008 + 958→1020, Step6 964-974→1026-1036 (@7e239a5→@15a54a4); admin DepositController [DRIFT] block left untouched. DEFERRED (uniform Class-B, not bumped): callbackService.go -10 line shift (3ee8018 deleted the callbackUserAgent/callbackWebhookSource const block, 694→684 lines, all pointers below ~91 shift -10) across deposit-auto-expire-pending, deposit-auto-match-from-statement, payout-admin-cancel, payout-auto-cancel-pending-timeout, payout-confirm-completed; plus main.go Class-A hash bumps (@2f35356→@3ee8018, line-stable) in deposit-auto-expire-pending + payout-auto-cancel-pending-timeout. Deferred because those callbackService pointers are embedded in dense [DRIFT]/regression-candidate prose with mixed live+historical @hash citations per line where blind token-replacement risks corrupting the audit trail; safer for a focused follow-up. No Class C/D/E/F. docs/flows/.baseline LEFT at 9aebabb (partial coverage). Extends W9 PR #458.

---
*Added via Oracle Learn*
