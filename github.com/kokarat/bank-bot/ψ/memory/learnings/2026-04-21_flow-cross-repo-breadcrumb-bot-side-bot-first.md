---
title: flow cross-repo breadcrumb (bot side, bot-first) — flow:bot-bootstrap-and-status
tags: [technical-writer, repo:bank-bot, repo:cross, repo:mobiz-payment-gateway, current, flow, flow:bot-bootstrap-and-status-reporting, cross-repo-sync, cross-repo-sync-bot-first, mobiz-payment-gateway, bootstrap, bank-status, reportStatus]
created: 2026-04-21
source: docs/flows/bot-bootstrap-and-status-reporting.md@9dc902f + mobiz controllers/BotConfigController.go getBotConfig + mobiz controllers/BankStatusController.go report (file-level cross-ref; no mobiz W8 counterpart at HEAD)
project: github.com/kokarat/bank-bot
---

# flow cross-repo breadcrumb (bot side, bot-first) — flow:bot-bootstrap-and-status

flow cross-repo breadcrumb (bot side, bot-first) — flow:bot-bootstrap-and-status-reporting crosses from bank-bot into mobiz-payment-gateway territory at Steps 2 (GET /bot/config/:account) and 5/8a/8b/8c/9b (POST /bank-status/report). The bot owns the entire client-side state machine — retry ladder, pollLoop cadence, status-message text, role tagging (maker/approver/viewer/transfer) — while mobiz-payment-gateway owns the handlers that persist the config read and the status row used by its dispatcher. This is a bot-first flow: no mobiz counterpart flow doc exists at HEAD. When mobiz W8 eventually runs on a slug like `bot-config-handshake` or `bank-status-heartbeat`, it should file the symmetric breadcrumb and arra_trace_link(prev=null, next=3a87af12-47a1-4761-b408-f837e5c7f4f4) or capture the cross-repo link in its own breadcrumb body. Contract points the bot consumes from mobiz-payment-gateway: (1) GET /api/v1/bot/config/{account_number} with X-Bot-Secret header — response body includes bank_code, system_bank_id, credentials, maintenance_time; handler at mobiz controllers/BotConfigController.go getBotConfig. (2) POST /api/v1/bank-status/report with body {account_number, bank_code, status, message, role} — status values used by the bot are offline/online/maintenance/error; role values are maker/approver/viewer/transfer; handler at mobiz controllers/BankStatusController.go report. Bot W8 trace: 3a87af12-47a1-4761-b408-f837e5c7f4f4. Mobiz W8 trace: not yet authored. Precedent: ktb-login-with-otp (PR #80) also shipped as cross-repo-sync-bot-first.

---
*Added via Oracle Learn*
