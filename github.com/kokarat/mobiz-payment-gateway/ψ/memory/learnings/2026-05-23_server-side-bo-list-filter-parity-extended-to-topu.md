---
title: Server-side BO list-filter parity extended to topups and payouts (both mirror De
tags: [technical-writer, repo:mobiz-payment-gateway, current, api-surface, topup, payout, bo-filter, pagination]
created: 2026-05-23
source: controllers/TopupController.go:435-468@7909917, controllers/PayoutController.go:247-248@f512e34
project: github.com/kokarat/mobiz-payment-gateway
---

# Server-side BO list-filter parity extended to topups and payouts (both mirror De

Server-side BO list-filter parity extended to topups and payouts (both mirror DepositController.GetAllDeposits). TopupController.GetAllTopups (7909917 #472) gained start_date/end_date (YYYYMMDD → created_date_bkk integer window, start+"000000"..end+"235959"), amount (exact ParseFloat match), bank_account (exact match on client_bank_account_number, the customer's transfer-from account), system_bank_account (exact match on system_bank_acc_no). PayoutController.GetAllPayouts (f512e34 #476) gained account_number (anchored prefix regex on dest_bank_account_number, the customer's destination account: if len>=3 && isAllDigits then {$regex:"^"+QuoteMeta}, no $options:i, digits-only, 3-char min to keep the index scan bounded). Both fixes address the same class of bug: the BO page applied these filters client-side over the current page only, so matches on later pages silently disappeared and the table footer/pagination disagreed with the visible filtered rows (topup symptom: header "แสดง 1 รายการ" vs pagination "1-100 จาก 172"). Topup account fields use exact match (raw digit strings, indexed) while payout uses anchored prefix regex (mirrors the deposit account_number filter). Documented in current-system.md §3.2 topups + payouts rows.

---
*Added via Oracle Learn*
