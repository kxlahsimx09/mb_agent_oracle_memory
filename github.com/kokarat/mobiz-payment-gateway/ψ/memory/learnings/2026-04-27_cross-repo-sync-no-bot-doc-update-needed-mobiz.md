---
title: cross-repo-sync (no bot-doc update needed): mobiz 5ce4596 modified controllers/B
tags: [technical-writer, repo:mobiz-payment-gateway, repo:bank-bot, current, cross-repo-sync, pullout, BotConfigController, balance-trigger]
created: 2026-04-27
source: controllers/BotConfigController.go@5ce4596
project: github.com/kokarat/mobiz-payment-gateway
---

# cross-repo-sync (no bot-doc update needed): mobiz 5ce4596 modified controllers/B

cross-repo-sync (no bot-doc update needed): mobiz 5ce4596 modified controllers/BotConfigController.go — pullout balance-trigger path now uses SumPendingPulloutAmountsToDest (inbound reservation) and PickRandomDestCap (random band 100k–120k) inside UpdateBankBalance. The three bank-bot flow docs that cite BotConfigController.go (bot-bootstrap-and-status-reporting.md → getBotConfig, bot-otp-relay.md → GetOTP/SaveOTPLog, deposit-auto-match-from-statement.md → SaveBankStatements) cite functions that were NOT changed by 5ce4596. The PUT /bot/balance request/response contract is unchanged. If bot-writer ever authors a "balance-trigger-pullout" flow doc, they should note the inbound reservation guard (SumPendingPulloutAmountsToDest) and random cap (PickRandomDestCap) that fire when PulloutTriggerEnabled + balance >= threshold.

---
*Added via Oracle Learn*
