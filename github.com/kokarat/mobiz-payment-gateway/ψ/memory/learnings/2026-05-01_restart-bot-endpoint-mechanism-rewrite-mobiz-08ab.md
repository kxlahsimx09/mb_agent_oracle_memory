---
title: Restart Bot endpoint mechanism rewrite (mobiz 08ab0b8 #357, 2026-05-01). The ope
tags: [technical-writer, repo:mobiz-payment-gateway, current, restart-bot, bot-ops, ssh, systemd, operator-action]
created: 2026-05-01
source: controllers/SystemBankController.go:1264-1334@08ab0b8 + services/botOpsService.go:1-232@08ab0b8
project: github.com/kokarat/mobiz-payment-gateway
---

# Restart Bot endpoint mechanism rewrite (mobiz 08ab0b8 #357, 2026-05-01). The ope

Restart Bot endpoint mechanism rewrite (mobiz 08ab0b8 #357, 2026-05-01). The operator UI's POST /api/v1/system-banks/:id/restart-bot now SSHes into the bank-bot droplet and runs `systemctl restart bank-bot && sleep 2 && systemctl is-active bank-bot` instead of issuing a DigitalOcean REST API VM reboot. Status code flipped from 202 Accepted (fire-and-forget) to 200 OK (synchronous, ~5s round trip; service confirmed active before reply). Failure-mode set widened: 503 Service Unavailable now fires when EITHER `DO_TOKEN` OR `SSH_PRIVATE_KEY` is missing (operator must fix the secret); 502 Bad Gateway covers any upstream failure including SSH dial timeouts and `systemctl` non-active output. DO_TOKEN scope reduced to `droplet:read` (used only for the IP lookup; no longer reboots droplets). New env knobs in services.BotOpsService: `SSH_PRIVATE_KEY` (PEM contents from k8s/secrets.yaml `ssh-private-key`), `SSH_PRIVATE_KEY_PATH` (file fallback read once at NewBotOpsService time, useful for local dev), `BOT_SSH_USER` (defaults to `root`). SSH client uses 15s connect timeout, 30s command timeout, `HostKeyCallback = ssh.InsecureIgnoreHostKey()` (bank-bot fleet trust is operator-managed; defense gain rejected vs ops burden). Stderr is folded into the error so the UI surfaces remote `permission denied` / `command not found` instead of a generic `exit status 1`. Public key was already on every droplet via DO's automatic SSH key injection at create time, so the rollout did NOT touch a single droplet; only k8s/secrets.yaml gained the `ssh-private-key` PEM. Mirrors `bank-bot/scripts/restart-bot.sh` deliberately so operators get the same fast-restart UX from the dashboard.

---
*Added via Oracle Learn*
