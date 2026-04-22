---
title: W9 pass 2026-04-22: uncovered-surface handoff for `scripts/bot-uptime.sh` (new a
tags: [technical-writer, repo:bank-bot, current, w8-handoff, uncovered-surface, flow:bot-fleet-uptime-audit, flow-track, scripts, deployment]
created: 2026-04-22
source: scripts/bot-uptime.sh@5cb8cb3 (new file; PR #88)
project: github.com/kokarat/bank-bot
---

# W9 pass 2026-04-22: uncovered-surface handoff for `scripts/bot-uptime.sh` (new a

W9 pass 2026-04-22: uncovered-surface handoff for `scripts/bot-uptime.sh` (new at `75f0ae1` + `c96594c`, PR #88). This is an ops script that ssh-fans-out to every `bank-bot-<account>` Droplet and reports systemd `ActiveState` + `ActiveEnterTimestamp` + `NRestarts` + MainPID `ps etime` + a `BANK` column parsed from the Droplet's non-reserved tag. No current `docs/flows/*.md` file covers the `restart-bot.sh` / `update-all.sh` / fleet-management surface it sits in — `bot-bootstrap-and-status-reporting.md` covers a single bot's bootstrap, not a cross-fleet audit. Suggested slug: `bot-fleet-uptime-audit` (or broader `bot-fleet-operator-tooling` if the next W8 author wants to group restart/update/uptime/destroy scripts). Proposed actors: `User:Operator` (runs the script locally) → `External:DigitalOcean` (doctl for Droplet list + tags) → `External:Droplet[]` (ssh for systemd + ps) → back to `User:Operator`. Not a crossing on the `/bot/*` HTTP contract so no mobiz actor is involved. Next W8 author: pick this up when portfolio expansion into fleet-ops is the next priority. For now it's documented in `current-system.md §5.3` (see bot-writer W2 2026-04-22 pass) — which is enough for surface-level reference but does not give the "why+when" that a flow doc provides.

---
*Added via Oracle Learn*
