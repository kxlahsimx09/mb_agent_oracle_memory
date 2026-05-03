---
title: Slip receiver mask-aware position compare (mobiz #364, eac6c55, 2026-05-02). PR 
tags: [technical-writer, repo:mobiz-payment-gateway, current, deposit, slip-fraud, v2-receiver-mismatch, promptpay, natid-mask]
created: 2026-05-01
source: services/slipFraudCheck.go:48-117@eac6c55
project: github.com/kokarat/mobiz-payment-gateway
---

# Slip receiver mask-aware position compare (mobiz #364, eac6c55, 2026-05-02). PR 

Slip receiver mask-aware position compare (mobiz #364, eac6c55, 2026-05-02). PR #360's last-4-digit compare (services/slipFraudCheck.go::VerifySlipReceiverMatchesDeposit) was producing false positives on PromptPay NATID slips with middle-4 masks — BBL renders 0-7055-6xxxx-70-2 and the digits-only-last-4 collapses to 6702 instead of the real 4702. Fix: when stripPromptpayFormatting(slip) and stripPromptpayFormatting(deposit) — keep digits + mask glyphs x/X/* — share the same length AND the slip carries a mask, switch to position-by-position compare skipping mask positions. Falls back to legacy last-4 path when the slip is fully unmasked OR when lengths differ (different ID type, MSISDN vs NATID where positional alignment is unsafe). Reproduced on DEP1777664433X6DFUK (2 พ.ค. 2026) — same NATID promptpay 0705566004702 on both sides, original last-4 incorrectly rejected.

---
*Added via Oracle Learn*
