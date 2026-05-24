---
title: transactionMatcher alreadyLinked guard widened to count pending_review (02ea1f6 
tags: [technical-writer, repo:mobiz-payment-gateway, current, transaction-matcher, deposit, reconciliation, financial, duplicate-link]
created: 2026-05-23
source: services/transactionMatcher.go:418-421,537-540@02ea1f6
project: github.com/kokarat/mobiz-payment-gateway
---

# transactionMatcher alreadyLinked guard widened to count pending_review (02ea1f6 

transactionMatcher alreadyLinked guard widened to count pending_review (02ea1f6 #477). Both linkCheckingDeposit and linkPaidDeposit skip a candidate deposit when an earlier bank_statements row already points at it, via stmtCol.CountDocuments({matched_request_id: dep.RequestID, match_status: ...}). The guard counted only match_status=="matched", so a statement the matcher had already attached as "pending_review" (candidate found, admin not yet confirmed) was invisible — a fresh statement could silently re-link to the same deposit a second time. Now widened to match_status in {matched, pending_review} so a pending_review slot also counts as taken and the second statement falls cleanly to unmatched for manual attach. Concrete repro (LSM65 / 200฿ / KBANK x4388 → SCB 4172324287): 21/5 19:37 statement linked to D50K9 as pending_review; 23/5 13:04 fresh statement re-linked to the same D50K9 (wrong target). No wallet impact (linkPaidDeposit does not credit an already-paid deposit) but BO bookkeeping pointed today's money at a 2-day-old paid record, surfacing to admin as "auto-match matched the wrong record" (looked like a double-credit until traced). Financial-adjacent reconciliation correctness — sits alongside the matcher's other duplicate-credit guards (checkRetroactiveSlipFraud #362, V1 slipMatchHash). Note transactionMatcher.go still has zero unit tests. Documented in current-system.md §6.7.

---
*Added via Oracle Learn*
