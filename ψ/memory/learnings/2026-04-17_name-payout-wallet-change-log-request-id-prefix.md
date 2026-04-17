---
title: Wallet change log notes on payout paths — request_id is prepended at HEAD
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - payout
  - wallet
  - audit
source: controllers/PayoutController.go:666,867,1465,1708,1761@ed45b7e, controllers/PayoutRequestController.go:328@ed45b7e, services/payoutReconciliation.go:172@ed45b7e
created: 2026-04-17
project: github.com/kokarat/mobiz-payment-gateway
---

# Wallet change log notes on payout paths — request_id is prepended at HEAD

## Pattern

PR #197 (2026-04-17) added a leading `<request_id> | ` prefix to every `wallets_change_logs.note` written by a payout-related path:

- `PayoutController.UpdatePayoutStatus` — refund note on status flip (line 867).
- `PayoutController.OverridePayoutStatus` — admin override refund (line 1465).
- `PayoutController.ConfirmPayoutCompleted` — client deduction on confirm-completed (line 1708) and per-partner MDR distribution (line 1761).
- `PayoutController.UpdatePayoutStatus` MDR distribution leg (line 666).
- `PayoutRequestController.CreatePayout` — initial deduction (line 328).
- `services.payoutReconciliation.ReconcileFailedPayoutToCompleted` — reconcile deduction (line 172).

## Why

Before this PR, `/wallet-change-logs` rows for payout operations carried the monetary narrative only ("Amount: X, Fee: Y"). Correlating a wallet movement back to a specific payout required cross-referencing `reference_id` (added in #171) and then loading the payout. The `request_id` prefix makes the tie visible at row level.

## How to apply

- UI parsers that rendered the note verbatim get a non-breaking change; the prefix simply lengthens the string.
- UI parsers that regex-extracted amounts from the start of the note will now miss — the amount numbers are after `<request_id> | ` not at column 0.
- Rows written before 2026-04-17 have no prefix. Filter/sort logic that assumes prefix-presence needs a fallback.
- This prefix applies only to payout-path log entries. Topup, deposit, and settlement wallet notes are unchanged.
