---
title: hotfix — #543 bank-fee ledger wallet restricted to super_admin (DRIFT-18 update, access-control)
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - wallet
  - mdr
  - rbac
  - drift
created: 2026-06-17
source: routes/wallet.go:27 + controllers/WalletController.go:166-172,357-363,883-887 @ 0e12db0
related:
  - 2026-06-17_drift-18-bank-fee-ledger-wallet
project: github.com/kokarat/mobiz-payment-gateway
---

# #543 — Bank-fee ledger wallet is now super_admin-only (DRIFT-18 follow-up, access-control)

`0e12db0` #543 "hotfix(wallet): restrict bank-fee ledger wallet to super_admin" (2026-06-17). Recorded as a DRIFT-18 status update in the 2026-06-17 W2 amend pass (current-system.md §9 DRIFT-18). **Access-control / info-disclosure — CC `security_auditor` on the W1 PR that documents it.**

Problem: PR #538 (DRIFT-18 — the `is_fee_expense` bank-fee ledger wallet + `/fee-reconciliation`) left the ledger readable by **any user holding `wallet:view`**, so non-super-admin admins could see the owner's MDR profit/expense figures. The fee-ledger is owner-financial data and must be super_admin-only.

Fix (post-change @ 0e12db0):
- **Route guard** — `GET /wallets/fee-reconciliation` changed from `RequirePermission(helpers.PermView("wallet"))` → `RequireRole(helpers.RoleSuperAdmin)` (`routes/wallet.go:27`). (`POST /wallets/fee-wallet` + `POST /wallets/fee-settlement` were already super_admin-only.)
- **List filter** — `GetAllWallets` (`controllers/WalletController.go:166-172`) and `ExportWallets` (`:883-887`) inject `filter["is_fee_expense"] = {$ne: true}` when `!isSuperAdmin(c)`, hiding the ledger wallet from non-super-admin list + CSV export.
- **Direct fetch** — `GetWalletByID` (`:357-363`) returns **`404` "Wallet not found"** (deliberately not 403, to avoid disclosing existence) when `wallet.IsFeeExpense && !isSuperAdmin(c)`.

Doc impact: tightens the DRIFT-18 surface — the fee-ledger endpoints/visibility are now uniformly super_admin-gated. Folds into the same W1-sized backlog; baseline held at `a011daf`.
