---
title: `GetAllDeposits` admin list gained `?account_number=` query param at `5cdd0b9` (
tags: [technical-writer, repo:mobiz-payment-gateway, current, deposit, list-filter, custom_bank_account_number, index]
created: 2026-05-02
source: controllers/DepositController.go:214,349-353@5cdd0b9, scripts/create_custom_bank_account_index.go@88c7810
project: github.com/kokarat/mobiz-payment-gateway
---

# `GetAllDeposits` admin list gained `?account_number=` query param at `5cdd0b9` (

`GetAllDeposits` admin list gained `?account_number=` query param at `5cdd0b9` (#382, 2026-05-03). Filter scopes by `ts_deposits.custom_bank_account_number` (the customer's account, not the system bank account) using anchored prefix regex `^<input>` via `regexp.QuoteMeta`. Validation: trim → require `len(trimmed) >= 3 && isAllDigits(trimmed)`. Inputs shorter than 3 digits or carrying non-digits are silently ignored. Backed by sparse btree index `{custom_bank_account_number:1}` on `ts_deposits` shipped in companion `88c7810` (#383, 2026-05-03) — script `scripts/create_custom_bank_account_index.go` is idempotent and was already executed against production. Filter exists primarily to back the /deposit page's customer-bank-account input which previously could only filter rows already on screen.

---
*Added via Oracle Learn*
