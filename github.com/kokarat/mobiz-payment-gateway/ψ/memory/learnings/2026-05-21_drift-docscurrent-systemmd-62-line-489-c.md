---
title: #drift — docs/current-system.md §6.2 (line ~489) cites `DepositRequestController
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, decision_required, bankRotation, stale-function-name, workflow-4-queue]
created: 2026-05-21
source: docs/current-system.md:489@c7b2232 vs controllers/DepositRequestController.go:86,208-220@7e239a5
project: github.com/kokarat/mobiz-payment-gateway
---

# #drift — docs/current-system.md §6.2 (line ~489) cites `DepositRequestController

#drift — docs/current-system.md §6.2 (line ~489) cites `DepositRequestController.CreatePaymentRequest` as the caller that sets `excludeBankCode = "ktb"`. The actual function at HEAD is `DepositRequestController.CreateDeposit` (controllers/DepositRequestController.go:86 — sole exported create handler). The cited line range `:197-204` is now generic transaction-ID generation — the KTB-exclude branch is at `:208-220` (post-2026-05-22 HEAD). Pre-existing drift discovered during 7e239a5 W2 pass; predates this commit (the rename happened in an earlier PR that touched the function but not this doc bullet). Surface-area: bullet text + `// verified` line range. Not security-sensitive. Queue for Workflow 4 drift reconciliation — fast-fix-disqualified for this pass because the change is unrelated to the in-range commit.

---
*Added via Oracle Learn*
