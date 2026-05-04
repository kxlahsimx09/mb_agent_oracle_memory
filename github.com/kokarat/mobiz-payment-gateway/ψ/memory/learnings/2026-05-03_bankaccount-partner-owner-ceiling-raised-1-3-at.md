---
title: BankAccount partner-owner ceiling raised 1 → 3 at `controllers/BankAccountContro
tags: [technical-writer, repo:mobiz-payment-gateway, current, bank-account, partner, settlement]
created: 2026-05-03
source: controllers/BankAccountController.go:22-25@20757ae
project: github.com/kokarat/mobiz-payment-gateway
---

# BankAccount partner-owner ceiling raised 1 → 3 at `controllers/BankAccountContro

BankAccount partner-owner ceiling raised 1 → 3 at `controllers/BankAccountController.go:25@20757ae` (PR #390, 2026-05-03). Motivation per the commit body: partners now need to settle to multiple destination banks (different sub-accounts for different markets / withdrawal cadences); the prior "max 1 settlement account" gate forced partners to consolidate or rotate accounts manually. The raise is a one-line constant bump — the wider `CreateBankAccount` path is untouched: 2FA verify still runs, Purpose validation unchanged, IsDefault toggling unchanged. The cap is enforced by a `collection.CountDocuments({owner_type, owner_id})` against `bank_accounts` then `if totalAccounts >= maxAccounts { 403 }` — counter scope is per (owner_id, owner_type), no status filter, so pending + approved + rejected all consume the partner's slot count. Constants live as package-level `controllers.MaxClientBankAccounts` (=5, unchanged) and `controllers.MaxPartnerBankAccounts` (=3, this change). Affects only partner-owned rows; client cap of 5 unchanged. The 403 body echoes `{limit, current}` so the UI can show the operator the exact ceiling.

---
*Added via Oracle Learn*
