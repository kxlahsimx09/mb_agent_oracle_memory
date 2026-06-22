---
title: drift — DRIFT-18 bank-fee ledger wallet + manual fee settlement (financial) undocumented
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - wallet
  - mdr
  - drift
created: 2026-06-17
source: controllers/WalletController.go:1079-1363 + models/wallets.go:20-25 + routes/wallet.go:27-29 + controllers/DashboardController.go:505,540 @ 03d6383
related:
  - 2026-06-17_decision-range-a011daf-03d6383-w1-sized-escalate
project: github.com/kokarat/mobiz-payment-gateway
---

# DRIFT-18 — Bank-fee ledger wallet + manual fee settlement, undocumented (financial-critical)

`03d6383` #538 "Bank-fee ledger wallet + fee reconciliation readout (manual fee settlement)" (2026-06-15, +309 LOC). Recorded as deferred drift in the 2026-06-17 W2 pass (current-system.md §9 DRIFT-18). **Financial — CC `code_reviewer` on the W1 PR that documents it.**

Evidence (post-change @ 03d6383):
- New singleton **system fee-ledger wallet**: `owner_type="system"`, new bool field `IsFeeExpense` on `models/wallets.go:20-25`. The money is an *expense* ledger (already paid to the bank as transfer fees), NOT spendable float.
- Three super-admin endpoints (`routes/wallet.go:27-29`):
  - `POST /wallets/fee-wallet` → `EnsureFeeWallet()` — idempotently creates the singleton.
  - `GET /wallets/fee-reconciliation` → `GetFeeReconciliation()` — `outstanding = Σ(bank_statements.match_status="fee" all-time) − fee-wallet balance`; optional `start_date`/`end_date` narrows to `period_fee`. Returns fee_incurred, fee_moved, outstanding, fee_wallet_exists/id.
  - `POST /wallets/fee-settlement` → `FeeSettlementTransfer()` — atomic move between owner wallet (`is_owner`) and fee ledger; CAS-guarded debit (no overdraft unless `allow_overdraft=true`); **dual `wallets_change_logs` entries with NEW operations `fee_settlement` / `fee_reversal`** (direction `to_fee`/`to_owner`); rolls back the debit if the credit fails.
- `DashboardController` excludes `is_fee_expense` wallets from system-balance + network-total sums (`controllers/DashboardController.go:505,540`, filter `{is_fee_expense:{$ne:true}}`) to avoid double-counting money already paid to the bank.

Doc impact: extends the documented `wallets_change_logs` operation enum (CLAUDE.md §Wallet Change Log — currently lists add/subtract/freeze/unfreeze/set/topup/mdr_distribution) with `fee_settlement` + `fee_reversal`. Folds into the W1-sized backlog; no current-system.md §3/§4/§6 coverage yet.
