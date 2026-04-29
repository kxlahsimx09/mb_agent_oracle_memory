---
title: install-preventive-restart.sh installs a bank-bot-restart.timer + bank-bot-resta
tags: [technical-writer, repo:bank-bot, current, deployment, scripts, preventive-restart, systemd, ktb, scb]
created: 2026-04-27
source: scripts/install-preventive-restart.sh@368c907
project: github.com/kokarat/bank-bot
---

# install-preventive-restart.sh installs a bank-bot-restart.timer + bank-bot-resta

install-preventive-restart.sh installs a bank-bot-restart.timer + bank-bot-restart.service unit pair on bot Droplets to auto-restart the bank-bot service on a schedule (Playwright/Chrome memory drift causes idle-but-online symptoms after ~2h). Per-bank-type timer: KTB gets a BKK-business-hours OnCalendar schedule (07:00–19:00 every 2h, RandomizedDelaySec=15m jitter); all other banks get a 2h interval timer, 24/7. A TimeoutStopSec=60 drop-in gives the bot up to 60s graceful shutdown on SIGTERM. Argument style mirrors restart-bot.sh: takes account numbers (not IPs), discovers IPs via doctl, builds account→bank-code map from MongoDB, parallel SSH/SCP with per-account result file and pass/fail summary table. PR #102 (ca6a2b2) initial; PR #105 (368c907) refactored argument style from IP-based to account-number-based. Rollback: systemctl disable --now bank-bot-restart.timer + rm unit files + daemon-reload.

---
*Added via Oracle Learn*
