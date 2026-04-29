---
title: W9 pass 2026-04-24: flow `withdrawal-queue-dispatch-and-claim` touched by commit
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow-track, flow:withdrawal-queue-dispatch-and-claim]
created: 2026-04-24
source: docs/flows/withdrawal-queue-dispatch-and-claim.md
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 pass 2026-04-24: flow `withdrawal-queue-dispatch-and-claim` touched by commit

W9 pass 2026-04-24: flow `withdrawal-queue-dispatch-and-claim` touched by commits 4fe2493..7557402 (specifically 4c4fa47 #299). Outcome: A: 0, B: 7 line-relocations, C: 0, D: 0, E: 0, F: 0. All pointers to `controllers/WithdrawalQueueController.go` shifted +36 lines after the `ListQueue` search-shape-routing refactor inserted 34 lines into the function body (plus 2 import lines). Hash bumped 29a57c1 → 4c4fa47 on 7 pointers (Dequeue/MarkSuccess/MarkFailed/MarkWaitingToReview/ClaimItems/CancelItem/FetchProcessingItems/SetTransactionID + UploadScreenshot regions). No semantic drift — ClaimByBank, batch_id mirror, MarkSuccess body, UploadScreenshot body, CancelItem status-guard all unchanged.

---
*Added via Oracle Learn*
