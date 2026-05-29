---
title: mobiz bot-ops gained AWS support across #490 (83a2513) + #491 (a4b23fb), 2026-05
tags: [technical-writer, repo:mobiz-payment-gateway, current, bot-ops]
created: 2026-05-27
source: docs/current-system.md §3.4,§6.7 @a4b23fb
project: github.com/kokarat/mobiz-payment-gateway
---

# mobiz bot-ops gained AWS support across #490 (83a2513) + #491 (a4b23fb), 2026-05

mobiz bot-ops gained AWS support across #490 (83a2513) + #491 (a4b23fb), 2026-05-28. The admin Restart-Bot path (BotOpsService → botHostLocator) was DigitalOcean-shaped and failed on AWS-hosted bank-bots with CORS-on-error "Failed to fetch". Three stacked fixes in #490: (1) awsLocator now filters EC2 by tag:Account=<accountNumber> + tag:Role=bank-bot + instance-state-name=running and iterates every reservation/instance — was tag:Name=bank-bot-<acct>, which never matched because AWS bots are named multi-brand <brand>-<bankType>-<acct> (e.g. ampay-scb-4102508550) per scripts/aws/create-bot.sh, the root cause. (2) BotHost gained a User field (DO=root, AWS=ubuntu); sshExec signature changed to sshExec(host BotHost, command) and dials host.User with a fallback to s.sshUser (BOT_SSH_USER, default root). (3) NEW bot-secret endpoint PUT /api/v1/bot/cloud-provider records system_banks.cloud_provider (validated "digitalocean"|"aws", 400 otherwise, 404 if no bank matches account_number+optional bank_code) so the locator selector routes correctly — the admin UI never exposed cloud_provider, so AWS-provisioned banks defaulted to "" → DO locator. #491 then adds a sudo wrap: RestartBotByAccount wraps the "systemctl restart bank-bot && sleep 2 && systemctl is-active bank-bot" command in `sudo -n sh -c '<cmd>'` whenever the effective SSH user is non-root, because AWS Ubuntu's systemctl goes through polkit and fails interactive-auth over a non-TTY SSH session; new shellSingleQuote helper POSIX-single-quotes the command. DO bots SSH as root and skip the wrap (existing fleet unaffected). Documented at current-system.md §3.4 (/cloud-provider endpoint) + §6.7 (botOpsService.go sshExec/sudo wrap, botHostLocator.go BotHost.User + AWS tag-based locator; old tag:Name/first-instance claims marked SUPERSEDED).

---
*Added via Oracle Learn*
