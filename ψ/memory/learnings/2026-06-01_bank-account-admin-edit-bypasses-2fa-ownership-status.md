---
title: bank-account UpdateBankAccount gains admin branch bypassing 2FA + ownership + pending-status guards (#509)
tags: [technical-writer, repo:mobiz-payment-gateway, current, bank-account, rbac, w2, track-commit]
created: 2026-06-01
source: controllers/BankAccountController.go:748-965@88506f3
related:
  - 2026-06-01_drift-16-finance-api-deferred-to-w1
project: github.com/kokarat/mobiz-payment-gateway
---

`88506f3` (#509, 2026-06-01) adds an `isAdmin := user_type == "admin"` branch to
`UpdateBankAccount`. Before, the handler rejected any `user_type` other than
`partner`/`client`/`sub-client`, so super_admin could not fix typos on approved
accounts or correct rejected ones — `DeleteBankAccount` already had an admin
branch; Update was the missing half.

The admin branch bypasses three owner-side guards:

1. **2FA verification** — RBAC already gates the `bank-account:update` route and
   the admin has no per-account 2FA secret to verify against.
2. **Ownership check** (`owner_type`/`owner_id` must match the caller).
3. **"only `pending` accounts can be updated"** status guard — admin can patch
   `approved`/`rejected` rows.

Owner-side semantics are unchanged for partner/client/sub-client. The
partner-only-settlement Purpose rule and the duplicate-account `CountDocuments`
check were switched to read `owner_type`/`owner_id` off the **account row** (not
the caller), so the same code paths run for admin and owner updates without
diverging.

Security-relevant (2FA + ownership bypass for a money-destination row) — CC'd
`security_auditor` on the W2 PR (#507 amend). Documented in `docs/current-system.md`
§3.2 bank-accounts row.
