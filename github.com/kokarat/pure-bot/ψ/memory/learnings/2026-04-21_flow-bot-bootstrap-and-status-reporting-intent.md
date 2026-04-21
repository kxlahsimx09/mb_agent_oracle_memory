---
title: flow — bot-bootstrap-and-status-reporting — intent at a glance. After the drople
tags: [technical-writer, repo:bank-bot, current, flow, flow:bot-bootstrap-and-status-reporting, bootstrap, bank-status, reportStatus, pollLoop, reverse-engineered, ratification-pending, s4]
created: 2026-04-21
source: docs/flows/bot-bootstrap-and-status-reporting.md@9dc902f (bank-bot); no mobiz sibling
project: github.com/kokarat/pure-bot
---

# flow — bot-bootstrap-and-status-reporting — intent at a glance. After the drople

flow — bot-bootstrap-and-status-reporting — intent at a glance. After the droplet's process supervisor starts the bot (systemd via scripts/setup-droplet.sh), the bot must authenticate to mobiz-payment-gateway with its shared BOT_SECRET, retrieve the bank-account config + credentials, prepare a Playwright browser session, and drive its own bank_status.status row through a state machine (offline → online/maintenance/error → offline) so the gateway dispatcher assigns queue items only while a verified-ready bot is listening. The flow spans the full bot lifetime: init phase (env validation → GET /bot/config with 5x5s then 5min retry ladder → loadBankModule → ensureBrowser → initial POST /bank-status/report status=offline → optional viewer-loop spawn for SCB dual-control), pollLoop steady state (5min config refresh → maintenance/online/offline status transitions tied to pre-claim login readiness), and SIGTERM/SIGINT shutdown (final offline report + process.exit). Per-bank login mechanics are intentionally out of scope (covered by ktb-login-with-otp, scb-dual-control-withdrawal, ktb-single-transfer-withdrawal §Step 0a). This is a bot-first flow — no mobiz-payment-gateway W8 counterpart exists at HEAD.

---
*Added via Oracle Learn*
