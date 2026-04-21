---
title: Settlement list + export search filter now includes request_id (PR #246, commit 
tags: [technical-writer, repo:mobiz-payment-gateway, current, settlement, search-filter, request-id, admin-list, export]
created: 2026-04-20
source: controllers/SettlementController.go:417-425,1294-1300@68accc6
project: github.com/kokarat/mobiz-payment-gateway
---

# Settlement list + export search filter now includes request_id (PR #246, commit 

Settlement list + export search filter now includes request_id (PR #246, commit 68accc6, 2026-04-20). Previously the `?search=` $or filter on `GetAllSettlements` only covered entity_name, client_name, client_bank_account_number, system_bank_account_number; full settlement ids like STL1776603711I7WNHY returned zero results because request_id was not in the $or. Same gap existed on `/export`, which only matched entity_name + notes. The fix prepends `{request_id: {$regex: search, $options: i}}` to both $or arrays so paste-searching the settlement id now works for admin list and CSV export paths. No schema change, no other endpoints affected; other queue-source search endpoints (payouts, deposits, direct-transfers) were already id-searchable and did not need the fix.

---
*Added via Oracle Learn*
