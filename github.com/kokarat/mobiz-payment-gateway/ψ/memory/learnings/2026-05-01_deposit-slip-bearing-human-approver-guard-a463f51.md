---
title: Deposit slip-bearing human-approver guard (a463f51 #361, 2026-05-02). DepositCon
tags: [technical-writer, repo:mobiz-payment-gateway, current, deposit, fraud, slip, security, auth, bot-auth, audit-trail]
created: 2026-05-01
source: controllers/DepositController.go:817-845@a463f51
project: github.com/kokarat/mobiz-payment-gateway
---

# Deposit slip-bearing human-approver guard (a463f51 #361, 2026-05-02). DepositCon

Deposit slip-bearing human-approver guard (a463f51 #361, 2026-05-02). DepositController.UpdateDepositStatus now blocks status→paid when deposit.slip_uploaded_at is non-zero AND the caller's resolved user_type is not "admin"|"user" OR the username is "" or "system". Failed callers get 403 with bilingual TH/EN message and structured payload {request_id, caller_user_type, caller_username, required_user_type:"admin or user"}. Background: POST /api/v1/deposits/:id/status (admin route under JWTAuthMiddleware) and POST /api/v1/bot/deposit/:id/status (bot route under BotAuthMiddleware, registered routes/deposit.go:42) share the same UpdateDepositStatus handler. The bot middleware does NOT populate user_type/username, so the handler defaults to "system"/"system" and was previously able to flip slip-bearing deposits to paid with approved_by_type=system and no human review of the slip. Production scan on 90 d surfaced 61 paid+slip deposits with empty approved_by, plausibly via this path. Operator policy after the 2026-05-02 fraud incident: every deposit that has a slip uploaded MUST be approved by a real admin user — no auto-approve via bot endpoint, scheduler, or any path where the JWT context is empty. Slip-less deposits keep existing behaviour because the bot is the legitimate approver for auto-match deposits. This guard runs BEFORE the receiver-mismatch check (#360) in the handler, so the bot path returns 403 even when the slip's receiver matches; #361 catches the missing audit trail, #360 catches the actual fraud mechanism. Composes with #360.

---
*Added via Oracle Learn*
