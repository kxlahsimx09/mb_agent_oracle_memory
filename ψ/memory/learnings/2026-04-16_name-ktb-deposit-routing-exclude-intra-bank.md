---
name: KTB deposit routing — exclude intra-bank candidates via SelectBankForDeposit(excludeBankCode)
description: As of 4720f20 (2026-04-16), SelectBankForDeposit accepts an excludeBankCode parameter. DepositRequestController sets it to "ktb" when the request's bankCode is KTB — intra-bank KTB→KTB transfers disable the recipient-name field and break statement reconciliation.
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - deposit
  - bank-rotation
  - bank-bot
source: services/bankRotation.go:40-56,190-195 @ 3b7e0f1; controllers/DepositRequestController.go:197-204 @ 3b7e0f1
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

# KTB deposit routing — exclude intra-bank candidates

## Fact

`services.BankRotationService.SelectBankForDeposit(clientID, amount, excludeBankCode)` now accepts a third parameter (`4720f20`, PR #160). When non-empty, the internal Mongo filter adds `bank_code != strings.ToLower(excludeBankCode)`. If the filtered query returns zero candidates the service transparently re-runs the unfiltered rotation and logs a warning — so a pool containing only the excluded bank still serves the request.

Caller: `controllers.DepositRequestController.CreatePaymentRequest` sets `excludeBankCode = "ktb"` whenever `strings.EqualFold(req.BankCode, "KTB")`.

## Why

KTB Business auto-matches intra-bank (KTB→KTB) transfers and disables the recipient-name field on the payer's side. Our SCB statement-reconciliation path expects that field and breaks without it — we hit the same class of incident on the payout side with 0170679675 → 0170689786 on 2026-04-11.

Payout rotation (`SelectBankForPayout`) is **unchanged**: the destination is specified by the client, rotation never picks it.

## How to apply

- Any new deposit-creation caller must decide whether to pass `excludeBankCode`; empty string preserves the legacy least-used rotation. Passing any non-empty value silently scopes the pool.
- Do not use `excludeBankCode` as a permission gate — the fallback path defeats it. If a pool must **never** produce an intra-bank selection, that invariant belongs elsewhere (client config, explicit rejection at the request parser).
- When extending the rule to other banks (BAY, SCB, etc.) add test cases to `tests/bank_rotation/exclude_bank_code_test.go` — the `ExcludeKtbFallbackWhenPoolOnlyKtb` case pins the fallback contract.

## Trace

commit `3b7e0f1` (specifically `4720f20` #160) → docs/current-system.md §6.2 → resolution PR #173
