---
title: Deposit slip-receiver-mismatch fraud block (ef71420 #360, 2026-05-02). DepositCo
tags: [technical-writer, repo:mobiz-payment-gateway, current, deposit, fraud, slip, security, thunder-verify]
created: 2026-05-01
source: services/slipFraudCheck.go@ef71420 + controllers/DepositController.go:847-889@a463f51
project: github.com/kokarat/mobiz-payment-gateway
---

# Deposit slip-receiver-mismatch fraud block (ef71420 #360, 2026-05-02). DepositCo

Deposit slip-receiver-mismatch fraud block (ef71420 #360, 2026-05-02). DepositController.UpdateDepositStatus now blocks status→paid when the slip's receiver proxy account does not match deposit.promptpay_id at the last-4-digits level. Comparison helper services/slipFraudCheck.go:VerifySlipReceiverMatchesDeposit fails-open if either side has fewer than 4 digits (legacy data, Thunder verify failure). Mismatch returns 400 with bilingual TH/EN message and a structured payload {slip_receiver_last4, deposit_promptpay_last4, override_hint}. super_admin can override by including the literal "[force-approve]" (case-insensitive) in notes; every override logs as "[Deposit] FRAUD OVERRIDE", every block as "[Deposit] FRAUD BLOCK". Standard admins, including the auto-approver, cannot bypass. Motivation: 90-day production scan of 8,736 slip-uploaded paid deposits found 905 (~10.36%, ~1.07M THB direct loss) where the slip's receiver did not match the deposit's promptpay destination — clients transferred to a third-party account, uploaded that genuine slip, Thunder verify confirmed slip authenticity, money never reached the platform's system_bank. Admin-escalated cases: DEP17775523528PE8D7 (slip last4 5111 vs promptpay 2556), DEP1777551533U75UBL (4702 vs 0571). Auto-match path (bank-bot scrape → matcher) untouched; UploadSlipAdmin untouched; only the credit transition is gated. Out-of-scope follow-ups: retroactive scan + refund of historical 905 cases, sender-verification (custom_bank_*) soft warning, frontend operator UI surface of structured response.

---
*Added via Oracle Learn*
