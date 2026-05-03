---
title: System bank Restart Bot operator action (mobiz `ac7e95a` #346, 2026-05-01). New 
tags: [technical-writer, repo:mobiz-payment-gateway, current, system-bank, operator-action, bot-fleet-ops, digitalocean, rbac]
created: 2026-05-01
source: controllers/SystemBankController.go:1264-1334@ac7e95a + services/botOpsService.go:1-133@ac7e95a + routes/systembank.go:31-37@ac7e95a + seed/{resources_seed,roles_seed}.go@ac7e95a
project: github.com/kokarat/mobiz-payment-gateway
---

# System bank Restart Bot operator action (mobiz `ac7e95a` #346, 2026-05-01). New 

System bank Restart Bot operator action (mobiz `ac7e95a` #346, 2026-05-01). New `POST /api/v1/system-banks/:id/restart-bot` returns 202 Accepted once DigitalOcean's REST API queues a droplet reboot. Permission: dedicated `system-bank:restart-bot` (not overloaded onto `update`). Seeded onto `super_admin` and `admin` only — explicitly NOT exposed to client/sub-client/Customer Support since rebooting a fleet bot drops in-flight transactions. Implementation: new `services.BotOpsService` (in services/botOpsService.go, 133 lines) — `FindBotDroplet(accountNumber)` queries `/v2/droplets?tag_name=bank-bot&per_page=200` matching by name `bank-bot-<account>`, then `RestartBotByAccount` POSTs `{"type":"reboot"}` to `/v2/droplets/{id}/actions`. Fire-and-forget: 201 from DO = API success, never polls completion. Failure modes: 503 specifically when `DO_TOKEN` env var is unset (so frontend can show "configure DO_TOKEN" hint); 502 for any other DO error; 400 when the system_bank record has no `account_number` to resolve the droplet. AuditTrailMiddleware records every call automatically.

Architecture trade-off (worth remembering): DO API was preferred over backend-side SSH because it needs only one secret (`DO_TOKEN`) and avoids managing an SSH key + opening port-22 outbound on App Platform. Downside: action is "reboot droplet" (60–90 s) not `systemctl restart bank-bot` (~5 s). Operator action runs <10 times/day so latency was acceptable.

Migration `scripts/add_restart_bot_permission.go` upserts the new action onto `roles` collection in production DB and clears Redis `permissions:*` + `role:*` caches in lockstep so users see the permission on next API call without a backend restart. Run once after deploy.

---
*Added via Oracle Learn*
