---
title: NEUTRAL — W1 twenty-fourth baseline `02ea1f6..99ba05d` — 2 production-surface co
tags: [tester, repo:mobiz-payment-gateway, current, w1-twenty-fourth-baseline, neutral, no-op, 2fa, totp, bank-account, sub-client]
created: 2026-05-27
source: controllers/TwoFactorController.go + controllers/UserController.go + helpers/brand.go @8bb1be6 ; controllers/BankAccountController.go @99ba05d ; docs/test-index.md baseline 99ba05d
project: github.com/kokarat/mobiz-payment-gateway
---

# NEUTRAL — W1 twenty-fourth baseline `02ea1f6..99ba05d` — 2 production-surface co

NEUTRAL — W1 twenty-fourth baseline `02ea1f6..99ba05d` — 2 production-surface commits, both NEUTRAL, zero status flips.

#487 (`8bb1be6`, "2fa: resolve TOTP issuer from Host header"): swaps `helpers.BrandTOTPIssuer()` → `helpers.BrandTOTPIssuerForHost(c.Hostname())` at TwoFactorController.Setup2FA + the two UserController.Login TOTP-issuance sites (first-time generate + reuse-existing-secret QR rebuild); adds a `bo.youpay.vip→Youpay` / `bo.dpay.money→Dpay` override table in helpers/brand.go (strips :port, lowercases) with env fallback. Changes ONLY the issuer LABEL embedded in the otpauth QR — the TOTP secret + 6-digit code verification are unchanged (commit body: already-enrolled authenticator entries keep working). NEUTRAL for all 49 tests: `grep -nE "issuer|otpauth|Setup2FA|BrandTOTPIssuer"` across the suite + helpers/ → 0 hits; no test sets a Host header (so c.Hostname()=localhost → env fallback, identical to before); the 2 step-up tests (test-deposit-refund.sh, test-payout-override.sh) pull two_factor_secret from Mongo + generate codes via generate-totp.js, never the label.

#486 (`99ba05d`, "Fix sub-client bank account owner_name to use parent client name"): BankAccountController.CreateBankAccount sets ownerName = subUser.ClientName (denormalized parent client name) on the sub-client branch so owner_type/owner_id/owner_name all point at the parent. NEUTRAL: `grep -rnE "/api/v1/bank-accounts"` across all 49 tests → 0 hits (every bank_accounts ref is a pool-link array PUT /api/v1/pools/.../bank_accounts; every bank_account_name is a settlement/topup destination field); the CreateBankAccount endpoint and its sub-client owner_name branch are entirely unexercised.

Matrix carries forward verbatim 44 VALID / 1 STALE (test-settlement-cancel.sh) / 0 WRONG-SETUP / 0 FLAKY / 2 SUPERSEDED / 2 ON_HOLD / 0 UNKNOWN; VALID rows' last-verified bumped 02ea1f6→99ba05d. New 🟢 coverage-gap rows appended for #487 (per-host TOTP issuer override — secret-independence is the only tripwire-worthy invariant) + #486 (sub-client bank-account owner_name; broader BankAccountController.CreateBankAccount CRUD has zero integration coverage). The k8s/scripts commits in range (#481 c551524, #482 16467ff, #484 2087fed) touch no production-surface .go and are out of scope.

---
*Added via Oracle Learn*
