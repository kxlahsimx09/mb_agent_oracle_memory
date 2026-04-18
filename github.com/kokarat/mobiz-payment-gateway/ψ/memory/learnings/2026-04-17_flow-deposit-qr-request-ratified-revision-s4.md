---
title: flow — deposit-qr-request — ratified revision (S4 → S2 via Oracle threads #4 + #
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, deposit-qr-request, ratified, revision, deposit, callback, promptpay, bank-bot, actor-correction]
created: 2026-04-17
source: docs/flows/deposit-qr-request.md@ed45b7e (HEAD of branch docs/flow-deposit-qr-request, pre-commit) + threads #4, #5
project: github.com/kokarat/mobiz-payment-gateway
---

# flow — deposit-qr-request — ratified revision (S4 → S2 via Oracle threads #4 + #

flow — deposit-qr-request — ratified revision (S4 → S2 via Oracle threads #4 + #5).

Intent: clients (not merchants) integrate with the gateway to take money from their end-users via a PromptPay QR; the gateway rotates a system bank, returns transfer instructions, matches the payer's transfer against scraped bank statements via bank-bot, then credits the client's wallet and fires one signed `deposit.completed` callback. In this repo's data model, `Merchant` is the business-level parent record that groups one or more `Client` integrations (`clients.merchant_id → merchants._id`); only `Client` holds API credentials and is the actor on the create endpoint. `Merchant` is attached to the deposit record for billing at persistence time but never authenticated against.

Ratification outcomes (2026-04-17):
- Thread #4: actor rename Merchant → Client applied throughout doc + mermaid diagram. Happy-path 8-message structure confirmed. Ext-marked merchant↔payer and payer↔bank hops kept high-level per user preference (not split into sub-flows).
- Thread #5: `pending_review` matcher branch is silent-by-design — no callback fires on the interstitial state. Client signal is the eventual `deposit.completed` (after admin resolution) or `deposit.expired` (if `expires_at` passes first).

Evidence sites (verifying actor = Client):
- `middlewares/apiKeyCheck.go:33-36` — FindOne on `clients` collection by `api_key`; stores `client` in c.Locals.
- `controllers/DepositRequestController.go:215-291` — parent Merchant is looked up from `client.MerchantID` *after* auth, only to attach MerchantID/MerchantName to the deposit record.

Doc at `docs/flows/deposit-qr-request.md@<post-revision>` — W8 revision trace `8e9817e9-2e7f-4d71-900c-092a3416b700`, chained to root `64ef2dc5-7a6b-45f4-8ab6-3fe49e9202a0`. Claim strength is now **S2** (human-ratified thread). No code behaviour change in this pass; provenance upgrade only.

---
*Added via Oracle Learn*
