---
title: New `scripts/stop-bot.sh` (135 lines, PR #115 / commit 6231444, 2026-05-22) bulk
tags: [technical-writer, repo:bank-bot, current, deployment, scripts, stop-bot, fleet, systemd, doctl, drift-2]
created: 2026-05-22
source: scripts/stop-bot.sh@6231444; PR #115 / 6231444
project: github.com/kokarat/bank-bot
---

# New `scripts/stop-bot.sh` (135 lines, PR #115 / commit 6231444, 2026-05-22) bulk

New `scripts/stop-bot.sh` (135 lines, PR #115 / commit 6231444, 2026-05-22) bulk-stops bank-bot systemd services across the DigitalOcean Droplet fleet. It is a deliberate mirror of `restart-bot.sh`: identical target-selection modes — explicit `<ACCOUNT>...`, `all` (every `bank-bot-*` Droplet name from `doctl`), and `active` (accounts where `system_banks.status==1`, resolved via `mongosh` against `MONGODB_URI`/`MONGODB_DBNAME` or `../backend/.env`) — and the same parallel ssh fan-out with a temp result file, sorted ✓/✗ output, and a `Pass: N/total  Fail: M` summary. Two intentional differences from restart-bot.sh: the per-target command is `systemctl stop bank-bot; sleep 2; systemctl is-active bank-bot`, and the success state is `inactive` rather than `active` (a target reporting `inactive` is counted as ✓; exit 0 only if every target is inactive). The script uses `set -u` only — `-e` is deliberately omitted so a single failed ssh does not abort the whole fan-out. Use case: planned bank-maintenance windows where the entire fleet must be halted, distinct from mobiz's per-bank Restart-Bot endpoint which only recycles one process.

Documented in docs/current-system.md §5.3 scripts table (count bumped to "12 shell + 3 Node helpers") and added to §8 DRIFT-2 (deployment helpers absent from CLAUDE.md "Droplet Deployment" §, alongside restart-bot.sh and bot-uptime.sh). Side note found this pass: the §5.3 header count was already stale (said "10 shell" while the table listed 11 before stop-bot.sh) — a benign off-by-one corrected in-pass, not a behavior drift. No bot code behavior changes.

---
*Added via Oracle Learn*
