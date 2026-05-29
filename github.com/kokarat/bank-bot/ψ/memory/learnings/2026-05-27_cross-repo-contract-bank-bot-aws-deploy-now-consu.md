---
title: Cross-repo contract: bank-bot AWS deploy now consumes the new backend endpoint P
tags: [technical-writer, repo:cross, cross-repo-sync, bank-bot, aws, cloud-provider, restart-bot-locator, deferred-link]
created: 2026-05-27
source: scripts/aws/create-bot.sh:527@13f61e0 ↔ mobiz routes/bot.go (PR #490)
project: github.com/kokarat/bank-bot
---

# Cross-repo contract: bank-bot AWS deploy now consumes the new backend endpoint P

Cross-repo contract: bank-bot AWS deploy now consumes the new backend endpoint PUT /api/v1/bot/cloud-provider (X-Bot-Secret handshake). bank-bot side landed in PR #125 / commit 13f61e0 (2026-05-28) — scripts/aws/create-bot.sh:516-545 PUTs {account_number, bank_code, cloud_provider:"aws"} at provision time so the admin dashboard "Restart Bot" button routes to the AWS instance locator instead of the default DigitalOcean one. Backend (mobiz-payment-gateway) side: the endpoint was added by mobiz PR #490 and is present at HEAD in routes/bot.go + BotConfigController/SystemBankController; mobiz's W2 baseline at this moment is 99ba05d (PR #486), which predates #490, so no mobiz W2 trace covers the endpoint yet. bank-bot W2 trace for this pass is 0a4e07b8-e952-4d2f-858d-f5b27f187b26 (chain head 163afddd → 0a4e07b8). No mobiz flow doc cites create-bot.sh or this endpoint, so the no-defer sibling-flow-doc-citation branch does not apply — this is a standard Step 2c DEFER: when mobiz's W2 next covers PR #490 (the cloud-provider endpoint + the restart-bot AWS-locator routing in SystemBankController), pg-writer should arra_trace_link(prev=<that mobiz W2 trace>, next=0a4e07b8) and note this bot-side consumer. The contract is satisfied on both sides today (no drift) — this breadcrumb is for chain navigation, not a drift escalation.

---
*Added via Oracle Learn*
