---
title: Deposit approval at ed45b7e — approved_by fields + admin slip bypass
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - deposit
  - audit
  - admin
source: models/deposit.go:76-78@ed45b7e, controllers/DepositController.go:697-708,1951-1962@ed45b7e, services/transactionMatcher.go@ed45b7e
created: 2026-04-17
project: github.com/kokarat/mobiz-payment-gateway
---

# Deposit approval at ed45b7e — approved_by fields + admin slip bypass

## Pattern

Four related PRs (`#185`, `#186`, `#187`, `#190`) tightened the deposit approval audit + admin override story:

- **`models/deposit.go:76–78`** (`#187`): three new fields — `ApprovedBy primitive.ObjectID`, `ApprovedByType string` (`user`/`system`), `ApprovedAt time.Time`. Written on status transitions.
- **`DepositController.UpdateDepositStatus` lines 697–708** (`#186`/`#187`): the admin who performs the status change is read from JWT locals; falls back to `"system"` when absent. The wallet change-log note also prepends the `request_id` (aligns with payout path — see `2026-04-17_name-payout-wallet-change-log-request-id-prefix.md`).
- **`DepositController.UploadSlip` lines 1951–1962** (`#190`): admin `user_type ∈ {user, admin}` bypasses the `slip_trans_ref` uniqueness 400. Non-admins still hit "slip already used".
- **`services.transactionMatcher`** (`#185`): auto-approval filter changed from `status: {$in: ["pending", "checking"]}` to `status: "pending"` only. A deposit under manual slip review (`checking`) is no longer auto-matched; it stays for admin judgement.

## Why

Pre-delta, logs said every deposit was approved by `"system"` even when an admin clicked approve — no accountability. `#186` threads the real admin through. `#187` makes the audit fields first-class on the deposit record. `#185` prevents the matcher from undercutting a reviewer mid-review. `#190` lets admins re-upload slips during manual verification without hitting the anti-replay guard.

## How to apply

- Filter `ts_deposits` by `approved_by_type=system` vs `approved_by_type=user` to separate matcher-auto vs admin-approved deposits.
- The `slip_trans_ref` uniqueness is still a constraint for client uploads — don't assume the constraint is gone.
- Matcher behaviour for `status=checking` is now "wait for admin"; if you're writing a test that plants a `checking` deposit and expects auto-match, it will hang.
