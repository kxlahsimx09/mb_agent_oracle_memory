---
title: Bot-first W8 cross-repo breadcrumb for flow:bot-maintenance-mode-window. The flo
tags: [technical-writer, repo:bank-bot, repo:cross, repo:mobiz-payment-gateway, current, flow, flow:bot-maintenance-mode-window, cross-repo-sync, cross-repo-sync-bot-first, mobiz-payment-gateway, maintenance, bank-status, reportStatus]
created: 2026-04-21
source: docs/flows/bot-maintenance-mode-window.md@a35dbf9 + mobiz controllers/BotConfigController.go (getBotConfig) + mobiz controllers/BankStatusController.go (reportStatus handler)
project: github.com/kokarat/bank-bot
---

# Bot-first W8 cross-repo breadcrumb for flow:bot-maintenance-mode-window. The flo

Bot-first W8 cross-repo breadcrumb for flow:bot-maintenance-mode-window. The flow crosses from bank-bot into mobiz-payment-gateway territory at steps 1 (GET /api/v1/bot/config/account config refresh that picks up maintenance_time) and steps 5 + 7c (POST /api/v1/bank-status/report with status=maintenance and role=maker/transfer/viewer). Bot owns: the isInMaintenanceWindow Bangkok-local time evaluation at app.js 103-124, the per-loop release-on-detection pattern across 7 sites, the pollLoop canonical teardown (bankModule.logout + resetBrowser + clearStorage) for maker/transfer role at app.js 1983-2003, the parallel viewer-loop branch for role=viewer with its own inMaintenance guard and singleton-null recovery at app.js 1057-1184. Mobiz owns: storage and admin-UI edit of the maintenance_time string on system_banks row, the GET /bot/config/account handler that returns it, the POST /bank-status/report handler that updates bank_status.status to maintenance, and the dispatcher-side gate that refrains from assigning queue items to banks whose status is not ready. No mobiz-side counterpart flow authored yet — when mobiz W8 runs a hypothetical bank-status-dispatcher-gate flow or similar that names status=maintenance as one of the non-ready states, it should file the symmetric breadcrumb and arra_trace_link into this flow W8 trace a0cb05b1-b369-4dad-b696-529484c3efca. Tagged cross-repo-sync-bot-first per convention established by scb-login and ktb-keepalive-session-rotation. Ratification thread 35 filed with five judgement calls. Contract points mobiz exposes to the bot: GET /api/v1/bot/config/account at mobiz-payment-gateway controllers/BotConfigController.go and POST /api/v1/bank-status/report at mobiz-payment-gateway controllers/BankStatusController.go.

---
*Added via Oracle Learn*
