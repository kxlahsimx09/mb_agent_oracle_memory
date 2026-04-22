---
title: New `scripts/bot-uptime.sh` (182 lines) reports per-Droplet systemd `ActiveState
tags: [technical-writer, repo:bank-bot, current, deployment, scripts, doctl, systemd, droplet-tags, bot-uptime, drift-2]
created: 2026-04-22
source: scripts/bot-uptime.sh@5cb8cb3; PR #88 / 75f0ae1 + c96594c
project: github.com/kokarat/bank-bot
---

# New `scripts/bot-uptime.sh` (182 lines) reports per-Droplet systemd `ActiveState

New `scripts/bot-uptime.sh` (182 lines) reports per-Droplet systemd `ActiveState` + `ActiveEnterTimestamp` + `NRestarts` + MainPID `ps etime`, plus a `BANK` column parsed from the Droplet's tags. Target-selection mirrors `restart-bot.sh`: all / explicit account list / `active` (reads `system_banks.status == 1` from MongoDB; needs `MONGODB_URI` + `MONGODB_DBNAME` env or `BACKEND_ENV=../backend/.env`). Bank code comes from whichever Droplet tag is not `bank-bot` and not `account-*` — uppercased for display, `-` when absent (older Droplets that predate the `create-bot.sh` tag convention can be retagged via `doctl compute droplet tag`). Fan-out parallelism: one ssh per target, results collected to a tempfile, printed sorted. Useful for: (1) long-uptime bots = memory drift candidates; (2) high-NRestarts bots = crash-looping; (3) confirming `restart-bot.sh` actually took effect across all targets. Exit code always 0 (informational). Now bumps DRIFT-2 ("deployment helpers not in CLAUDE.md") entry.

---
*Added via Oracle Learn*
