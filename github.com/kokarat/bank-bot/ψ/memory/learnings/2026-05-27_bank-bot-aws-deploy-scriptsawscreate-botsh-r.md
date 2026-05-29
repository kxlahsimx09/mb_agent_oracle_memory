---
title: bank-bot AWS deploy: `scripts/aws/create-bot.sh` registers cloud_provider on the
tags: [technical-writer, repo:bank-bot, current, aws, deployment, scripts, cloud-provider, restart-bot-locator]
created: 2026-05-27
source: scripts/aws/create-bot.sh:516-545@13f61e0
project: github.com/kokarat/bank-bot
---

# bank-bot AWS deploy: `scripts/aws/create-bot.sh` registers cloud_provider on the

bank-bot AWS deploy: `scripts/aws/create-bot.sh` registers cloud_provider on the bank record after provisioning (PR #125 / 13f61e0, 2026-05-28). After launching the EC2 instance and (optionally) associating an EIP, the script makes a best-effort `PUT /api/v1/bot/cloud-provider` to the backend with body `{account_number, bank_code, cloud_provider:"aws"}` and an `X-Bot-Secret` header — the same auth handshake the bot runtime uses, so no admin token is required at deploy time. The purpose: the admin dashboard's "Restart Bot" button reads `cloud_provider` to decide which locator to use; without this, an AWS-hosted bot would be looked up via the default DigitalOcean locator and the restart would fail (Failed to fetch / CORS). The call is gated on `API_URL` and `BOT_SECRET` both being set, and a non-200 (e.g. network blip or the bank account currently inactive) is non-fatal — the instance is already up, and the script prints a copy-paste `curl` rerun recipe for the operator. Importantly this endpoint is invoked directly via `curl` from the shell script, NOT through `core/api.js`, so it is the only `/api/v1/bot/*` endpoint the repo touches that does not appear in the §4.1 runtime-client table; documented instead in docs/current-system.md §5.3 (aws/create-bot.sh row) and §6 (AWS EC2 external integration). The DigitalOcean `do/create-bot.sh` has no equivalent because DigitalOcean is the default locator. Backend endpoint was added by mobiz-payment-gateway PR #490 (present at HEAD in routes/bot.go + BotConfigController/SystemBankController).

---
*Added via Oracle Learn*
