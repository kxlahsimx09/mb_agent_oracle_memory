---
title: `/withdrawal-queue` admin list search joined the shape-routing family at `4c4fa4
tags: [technical-writer, repo:mobiz-payment-gateway, current, withdrawal-queue, search-shape-routing, perf]
created: 2026-04-24
source: controllers/WithdrawalQueueController.go:103-148@4c4fa47, db/indexes.go:173-180@4c4fa47
project: github.com/kokarat/mobiz-payment-gateway
---

# `/withdrawal-queue` admin list search joined the shape-routing family at `4c4fa4

`/withdrawal-queue` admin list search joined the shape-routing family at `4c4fa47` (#299). The former 6-field unanchored `$or` regex (request_id + dest_account_number + dest_account_name + system_bank_account + system_bank_name + owner_name) is replaced by: trimmed <3 → skip; PAY/PLO/STL/DTR prefix → anchored `^prefix` on request_id only; digits ≥8 → anchored prefix on dest_account_number + system_bank_account; otherwise → case-insensitive substring on dest_account_name + owner_name (system_bank_name dropped entirely). The four source-collection prefixes are exhaustive because `EnqueueWithdrawal` mirrors request_id from ts_payouts / pullout_logs / settlements / direct_transfers. Backed by two new indexes in the same commit: sparse `{request_id:1}` (sparse because not every queue item has a request_id at enqueue) and `{created_date_bkk:-1}`. Same perf motivation as PRs #285 / #291 / #294 (deposits / payouts / settlements+topups).

---
*Added via Oracle Learn*
