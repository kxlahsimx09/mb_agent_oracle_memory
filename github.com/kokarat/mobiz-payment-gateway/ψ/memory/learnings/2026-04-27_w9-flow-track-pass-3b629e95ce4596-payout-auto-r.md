---
title: W9 flow-track pass 3b629e9..5ce4596: payout-auto-reconcile-from-statement.md — 4
tags: [flow-track, payout, bank-statement, W9, pointer-relocation]
created: 2026-04-27
source: W9 pass 3b629e9..5ce4596
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 flow-track pass 3b629e9..5ce4596: payout-auto-reconcile-from-statement.md — 4

W9 flow-track pass 3b629e9..5ce4596: payout-auto-reconcile-from-statement.md — 4 Class B pointer relocations, all in BotConfigController.go (+12 line shift). Affected steps: Step 3 (func header 532→544), Step 4 (dedup+insert 567→579, goroutine kick 671→683), Step 5 (early HTTP response return c.JSON 679→691). All clean: no semantic drift, only line shifts caused by 5ce4596 inserting 12 lines into UpdateBankBalance (PickRandomDestCap + SumPendingPulloutAmountsToDest). #flow-track

---
*Added via Oracle Learn*
