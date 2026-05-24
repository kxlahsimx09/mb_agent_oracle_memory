---
title: `POST /api/v1/deposit/create` floors `amount` to whole baht (`7e239a5` #454, 202
tags: [technical-writer, repo:mobiz-payment-gateway, current, deposit, api-surface, input-normalisation, matcher-invariant, signature-ordering]
created: 2026-05-21
source: controllers/DepositRequestController.go:156-165@7e239a5
project: github.com/kokarat/mobiz-payment-gateway
---

# `POST /api/v1/deposit/create` floors `amount` to whole baht (`7e239a5` #454, 202

`POST /api/v1/deposit/create` floors `amount` to whole baht (`7e239a5` #454, 2026-05-22). After signature validation passes, the controller calls `req.Amount = math.Floor(req.Amount)`. Decimal portions are silently dropped (`100.02 → 100`, `100.99 → 100`); if the floored amount drops below 1 the request 400s with `"amount must be at least 1 THB after rounding decimals"`. Placement is load-bearing: signature is HMAC'd over the original amount (possibly decimal), so flooring before verify would 401 every legitimate decimal request; the controller verifies as-is, then overwrites `req.Amount` for everything downstream (rate-limit accounting, balance check, QR generation, persisted row). Rationale: bank statement matcher only sees whole-baht transfers and PromptPay QRs are integer THB, so a decimal deposit cannot reconcile downstream — flooring at create-time pulls the normalisation onto the writer. Scope: client-facing deposit-create only; `POST /payout/create`, admin deposit endpoints in §3.2, and topups are unchanged. Existing decimal deposits in MongoDB are not migrated.

---
*Added via Oracle Learn*
