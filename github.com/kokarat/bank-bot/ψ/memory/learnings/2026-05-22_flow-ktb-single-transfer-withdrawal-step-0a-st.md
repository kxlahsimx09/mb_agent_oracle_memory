---
title: Flow `ktb-single-transfer-withdrawal` Step 0a + Step 10 drift (Class C, cross-re
tags: [technical-writer, repo:bank-bot, repo:cross, repo:mobiz-payment-gateway, current, drift, flow-drift, cross-repo-sync, flow:ktb-single-transfer-withdrawal, ktb, balance-mapping, pg-writer-handoff]
created: 2026-05-22
source: docs/flows/ktb-single-transfer-withdrawal.md@6231444 + app.js:1564,1780@20289a3
project: github.com/kokarat/bank-bot
---

# Flow `ktb-single-transfer-withdrawal` Step 0a + Step 10 drift (Class C, cross-re

Flow `ktb-single-transfer-withdrawal` Step 0a + Step 10 drift (Class C, cross-repo): PR #110 / commit 20289a3 (2026-04-30) swapped the `api.updateBalance` argument order inside `processSingleTransfer` (the KTB single-transfer path), not just SCB. At the two KTB balance-push sites — HEAD app.js:1564 (Step 0a, post-login first push) and app.js:1780 (Step 10, post-transfer push) — the call changed from `updateBalance(acc, code, summary.accountBalance || summary.availableBalance, summary.availableBalance)` to `updateBalance(acc, code, summary.availableBalance, summary.accountBalance || summary.availableBalance)`. Net: backend `balance` ← cash-available ("ยอดเงินสดที่ใช้ได้"); backend `available_balance` ← account-total ("ยอดเงินในบัญชี"). Wire format unchanged; field semantics swapped — identical to the SCB swap the prior W9 (2026-05-01) documented.

This CORRECTS the prior pass's scb-dual-control change-log assertion "KTB unchanged": the swap is in the shared `processSingleTransfer` function, so KTB's reported balance fields swapped too. Cross-repo impact: mobiz dispatcher's `bank.AvailableBalance` headroom check now resolves to KTB's account total (same direction as SCB). The ktb-single-transfer flow's Step claim ("push balance after login / post-transfer") is unchanged; only which value lands in which backend field swapped — marked inline as `[DRIFT-ktb-balance-arg-swap]` at Step 0a and referenced from Step 10. Sibling mobiz doc to verify: `mobiz/docs/flows/payout-request.md` (system_banks.balance / available_balance field semantics). Surfaced by bot W9 b74e745..6231444; mobiz W9 cannot detect this because no mobiz code changed.

---
*Added via Oracle Learn*
