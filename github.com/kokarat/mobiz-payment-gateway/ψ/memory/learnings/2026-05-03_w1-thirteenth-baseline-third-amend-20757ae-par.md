---
title: W1 thirteenth-baseline third amend (20757ae) — partner BankAccount-create ceilin
tags: [tester, repo:mobiz-payment-gateway, current, w1-amend, neutral, coverage-gap, bank-account]
created: 2026-05-03
source: controllers/BankAccountController.go:25 + integration-tests/test-*.sh (48 files, zero hits)@20757ae
project: github.com/kokarat/mobiz-payment-gateway
---

# W1 thirteenth-baseline third amend (20757ae) — partner BankAccount-create ceilin

W1 thirteenth-baseline third amend (20757ae) — partner BankAccount-create ceiling lift NEUTRAL across 48 tests

What's wrong: nothing — this amend is NEUTRAL by design. PR #390 `20757ae` raises `MaxPartnerBankAccounts` from 1 to 3 in `controllers/BankAccountController.go:25` (4-line diff: constant + adjacent doc comment). The `CreateBankAccount` handler at `:74` still gates on `userType == "partner"` + `CountDocuments({client_id, status: 1}) >= MaxPartnerBankAccounts` — same path, new constant. No request-shape, validation-order, or error-payload change.

Why this is wrong (or in this case, why it's NEUTRAL): the static check `grep -lE "POST.*bank-accounts|/api/v1/bank-accounts|MaxPartner" integration-tests/test-*.sh` returns zero hits across all 48 tests. The `bank_account` token matches in all 48 files, but every match resolves to either the `system_bank_account_number` matcher field (matcher concern, different surface) or the `BANK_ACC` env-var alias for the system bank's account number — none reach `/api/v1/bank-accounts`. Partner records seeded via `helpers/setup-infra.sh::setup_test_data` reach the test environment without invoking `CreateBankAccount`.

Minimal fix (proposed, not applied): write a new `test-bank-account-create-limits.sh` covering both `MaxPartnerBankAccounts = 3` and the un-tested companion `MaxClientBankAccounts = 5` in one file. Phases: (a) partner login + 2FA, three POSTs succeed, fourth returns FORBIDDEN with new message "Maximum 3 bank accounts allowed for partner"; (b) client login + 2FA, five POSTs succeed, sixth returns FORBIDDEN with "Maximum 5 bank accounts allowed for client". Both are 🟢 Nice-to-have.

Impact if unfixed: the prior 1-account ceiling already had no integration-level guard; raising to 3 inherits the same gap. A regression that drops the ceiling check entirely (or raises it past Mongo's 16MB doc cascade limits) would not surface in the test suite — only via production rejection or unbounded growth.

Related: `2026-05-02_w1-thirteenth-baseline-amend-f89e23520b6fa3-cu` (prior amend, eight earlier NEUTRAL commits in the same range).

---
*Added via Oracle Learn*
