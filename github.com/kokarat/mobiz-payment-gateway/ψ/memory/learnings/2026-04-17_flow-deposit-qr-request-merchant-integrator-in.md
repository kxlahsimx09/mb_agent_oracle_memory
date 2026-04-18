---
title: flow — deposit-qr-request — merchant-integrator intent: take money from an end-u
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, deposit-qr-request, reverse-engineered, ratification-pending, deposit, callback, bank-rotation, promptpay, bank-bot]
created: 2026-04-17
source: docs/flows/deposit-qr-request.md@ed45b7e
project: github.com/kokarat/mobiz-payment-gateway
---

# flow — deposit-qr-request — merchant-integrator intent: take money from an end-u

flow — deposit-qr-request — merchant-integrator intent: take money from an end-user via the gateway's rotating system bank accounts, without the merchant handling any bank credentials. One HTTP request creates a PromptPay QR (or TRANSFER bank-info packet) tied to a gateway-owned account; one HTTP callback eventually confirms the transfer matched. Everything between those two calls is the gateway's problem.

Actor-level summary (8 messages, cross-repo with bank-bot):
1. Merchant → Gateway: POST /api/v1/deposit/create (API-key auth + JWT signature replay guard)
2. Gateway self: atomic bank rotation (system_banks.deposit_count++), PromptPay EMV gen, ts_deposits insert with status=pending + expires_at
3. Gateway → Merchant: 200 OK with qrcode payload + promptpayNumber (or bank info for TRANSFER channel)
4. Merchant → Payer: out-of-band (merchant UI displays QR)
5. Payer → Bank: transfer via PromptPay / manual
6. External BankBot → Gateway: POST /api/v1/bot/bank-statements (scrape loop)
7. Gateway self: MatchNewStatements → finalizeDeposit (paid, wallet credit, MDR fee split to partners)
8. Gateway → Merchant: POST callback (deposit.completed, signed + retried)

Terminal states for the ts_deposits row: paid (happy path), expired (expires_at hit before statement, scheduler/deposit_expiry.go 1-min tick), cancelled (admin/client action), checking (slip uploaded — distinct admin-approval sub-flow), pending_review (ambiguous matcher — no callback until admin resolves).

W8 root trace: 64ef2dc5-7a6b-45f4-8ab6-3fe49e9202a0. Claim strength: S4 (reverse-engineered). Ratification thread: Oracle thread #4. Open ambiguity thread #5: pending_review is silent by design or missing-feature?

Doc: docs/flows/deposit-qr-request.md @ed45b7e.

---
*Added via Oracle Learn*
