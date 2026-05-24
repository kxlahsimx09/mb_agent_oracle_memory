---
title: W9 pass 2026-05-22: flow `deposit-slip-upload-admin-approve` touched by commit 7
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow-track, flow:deposit-slip-upload-admin-approve]
created: 2026-05-21
source: docs/flows/deposit-slip-upload-admin-approve.md
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 pass 2026-05-22: flow `deposit-slip-upload-admin-approve` touched by commit 7

W9 pass 2026-05-22: flow `deposit-slip-upload-admin-approve` touched by commit 7e239a5 (PR #454, c7b2232..7e239a5). Outcome: A=0, B=4 line-relocations on the DepositRequestController.go pointers (Step 1 UploadSlip 794→806; Step 2 storage upload 876-882 → 888-894; Step 5 dup check + UpdateOne 901-944 → 913-956 and the previously-c5270b3 PublishDepositEvent at :946 → :958@7e239a5; Step 6 success response body 952-962 → 964-974), C/D/E/F=0. All shifts are the +12 displacement below HEAD :167 from the amount-floor block insertion. None of the slip-upload semantics changed.

---
*Added via Oracle Learn*
