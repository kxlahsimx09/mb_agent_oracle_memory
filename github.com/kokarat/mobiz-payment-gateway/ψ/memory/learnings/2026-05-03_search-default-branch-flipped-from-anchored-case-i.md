---
title: Search default-branch flipped from anchored case-insensitive ref_code to shape-r
tags: [technical-writer, repo:mobiz-payment-gateway, current, deposit, payout, bank-statement, search, shape-routing, ref_code, case-sensitive, perf, ixscan, 46fab46, 2caec4c, pr-386]
created: 2026-05-03
source: controllers/DepositController.go:334-358@46fab46 + controllers/PayoutController.go:214-235@2caec4c + controllers/BankStatementController.go:148-176@46fab46
project: github.com/kokarat/mobiz-payment-gateway
---

# Search default-branch flipped from anchored case-insensitive ref_code to shape-r

Search default-branch flipped from anchored case-insensitive ref_code to shape-routed case-sensitive at 46fab46+2caec4c (#386, 2026-05-03), reversing the case-insensitivity contract added in #293 (deposit) and never present on payout. The default branch in GetAllDeposits / GetAllPayouts now matches `^[A-Za-z0-9_\-]+$` to decide ID-like vs free-text: ID-like fires anchored ^prefix on `ref_code` case-sensitive only (single field, hits `ref_code_1` index — `ts_deposits` since #300, `ts_payouts` newly via scripts/create_payout_ref_code_index.go); free-text fires case-insensitive substring across name fields only (`client_name`+`notes` for deposits; `bank_reference`+`client_name`+`dest_bank_account_name` for payouts). `$options:"i"` defeats `ref_code_1` even with `^prefix` — production explain on a 28-char `DENMARKPAY…` deposit prefix went 131ms COLLSCAN → 0ms IXSCAN, and on payouts 37ms COLLSCAN → 0ms IXSCAN. Trade-off: clients whose `ref_code` was stored in a different case than the search input no longer match (the #293 absorption is undone for ID-like input); the new contract is "indexed perf wins over case-forgiveness for ID-shape input, free-text path stays case-insensitive". Same pattern landed simultaneously on bank-statements `?search=` (`buildBankStatementFilter`): all-digits → `account_number` anchored prefix only (+ `dest_account_last4` exact when len==4); non-digits → text-fields-only (`description`+`dest_account_name`+`raw_text`); the prior 5-field fan-out that regex-scanned numeric fields with Thai-name input is gone.

---
*Added via Oracle Learn*
