---
name: DirectTransfer approve path — enqueue before status flip, reject self-transfer at create
description: As of c5d89cf (2026-04-16, PR #170), CreateDirectTransfer rejects self-transfers (dest == source bank+account) at 400, and ApproveDirectTransfer enqueues synchronously before flipping status to "approved". Enqueue failure leaves the transfer in pending_approval with the real error, no zombie rows.
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - direct-transfer
  - withdrawal-queue
source: controllers/DirectTransferController.go:86-101,506-560 @ 3b7e0f1
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

# DirectTransfer approve path — enqueue before status flip

## Fact

Two invariants landed on 2026-04-16 in `DirectTransferController`:

1. `CreateDirectTransfer` rejects self-transfers up front:
   ```go
   if strings.EqualFold(input.DestBankCode, systemBank.BankCode) &&
       input.DestBankAccountNumber == systemBank.AccountNumber {
       return 400 "Destination account cannot be the same as the source system bank"
   }
   ```
2. `ApproveDirectTransfer` calls `services.EnqueueWithdrawal(params)` **before** flipping status to `approved`. Any enqueue error (insufficient balance, unsupported source type, duplicate, outstanding withdrawal limit) surfaces as a 400 with the real reason, and the transfer stays in `pending_approval`. If the status update fails after the enqueue succeeded, the queue row is rolled back so nothing is left orphaned. Telegram notification remains async.

## Why

DTR1776285027RZE1H2 on 2026-04-16: admin created a direct transfer whose `dest_bank_account_number` equalled the source `systemBank.AccountNumber` (same SCB 4122414317 on both sides). Create accepted it, approve flipped status to "approved", then the async enqueue goroutine failed because the bank's `AvailableBalance` (281.40) was less than the transfer amount (50,000). API returned 200, admin saw "Approved", no row in `withdrawal_queue`. Ops had to cancel the zombie transfer by hand three minutes later.

## How to apply

- Any new approve-style endpoint that transitions state and also enqueues must enqueue FIRST, flip status SECOND. Handing the enqueue to a goroutine whose error only reaches the log is the anti-pattern.
- If the enqueue depends on balance, the balance check inside the enqueue function (`bank.AvailableBalance >= params.Amount` in `EnqueueWithdrawal`) is the authoritative gate; don't silently drop its error.
- Any new transfer-style endpoint (settlement, topup, future types) should add the same self-transfer guard if source and destination are user-choosable and live on the same side of the ledger.
- Telegram notifications and similar out-of-band broadcasts should stay async — a Telegram outage must not block a legitimate approval.

## Trace

commit `3b7e0f1` (specifically `c5d89cf` #170) → docs/current-system.md §2 (DirectTransfer row) → resolution PR #173
