---
title: SystemBank.cloud_provider field + provider-aware Restart Bot action (`7e239a5` #
tags: [technical-writer, repo:mobiz-payment-gateway, current, system-bank, cloud-provider, restart-bot, aws-migration, api-surface]
created: 2026-05-21
source: models/system_bank.go:90-94@7e239a5, controllers/SystemBankController.go:670-682,1318-1396@7e239a5
project: github.com/kokarat/mobiz-payment-gateway
---

# SystemBank.cloud_provider field + provider-aware Restart Bot action (`7e239a5` #

SystemBank.cloud_provider field + provider-aware Restart Bot action (`7e239a5` #454, 2026-05-22). New optional string column on `system_banks` records: values `"digitalocean"` | `"aws"`, empty defaults to `"digitalocean"` so existing rows need no migration. `PUT /api/v1/system-banks/:id` accepts the field and validates the lowercased+trimmed value before persisting; non-conforming values 400. The operator `POST /api/v1/system-banks/:id/restart-bot` now passes `bank.CloudProvider` through to `services.BotOpsService.RestartBotByAccount(account, provider)`, which dispatches to the matching `BotHostLocator` (DO API vs AWS EC2). The SSH + `systemctl restart bank-bot` step is unchanged and provider-neutral. `200 OK` response echoes `cloud_provider` alongside `host_name` / `host_id`. The DO-side `DO_TOKEN env var is not set` sentinel still routes to 503; the AWS path has no equivalent 503 sentinel (credential failure surfaces as a generic config-load error → 502 in the controller).

---
*Added via Oracle Learn*
