---
title: gotcha — `pgrep -fl brew-ops-bot/bot.sh` always shows 2 PIDs (main loop + transi
tags: [brew-ops, repo:arra-oracle-v3, fleet, brew-ops-bot, telegram, pgrep, subshell, daemon-restart, gotcha]
created: 2026-05-26
source: brew-ops session 2026-05-26 — #104 deploy / bot.sh restart diagnosis
project: github.com/soul-brews-studio/arra-oracle-v3
---

# gotcha — `pgrep -fl brew-ops-bot/bot.sh` always shows 2 PIDs (main loop + transi

gotcha — `pgrep -fl brew-ops-bot/bot.sh` always shows 2 PIDs (main loop + transient subshell), NOT a duplicate bot

## Symptom
`pgrep -fl 'brew-ops-bot/bot.sh'` shows two processes with identical args `bash scripts/brew-ops-bot/bot.sh`. Looks like two bot daemons polling getUpdates and stealing each other's Telegram updates. Tempting to kill the "extra" one.

## Reality
There is only ONE main loop. The second PID is a **transient subshell** that bot.sh's main loop forks every iteration for command substitutions / pipelines (`$(...)`, `... | jq`, `update_status`, etc.). Subshells inherit the parent's `argv[0]`, so `pgrep -f` matches them too. They churn — re-poll a few seconds apart and the second PID changes (e.g. 56539 → 58212).

## How to tell which is the real main loop
- `ps -o pid,ppid,lstart,args -p <pids>` — the **main loop has `ppid=1`** (nohup/disown'd) and the **oldest start time**; subshells have `ppid=<main pid>` and churn.
- The main loop's pid matches the latest `brew-ops-bot starting (pid=NNN, ...)` line in `~/.cache/brew-ops-bot/bot.log`.
- The churning second PID is itself proof the getUpdates loop is alive and iterating.

**Do NOT kill the second PID** — it's a subshell; killing it is harmless (it'd churn anyway) but signals nothing wrong.

## Restart gotcha (observed 2026-05-26 during #104 deploy)
On `kill <main-pid>` (SIGTERM), the main can take up to ~35s to exit because it is blocked in the `getUpdates?...&timeout=30` curl (`--max-time 35`). A `pgrep` 2s after TERM still shows it — that is NOT a failed kill, just the long-poll draining. Wait for the curl to return (or re-check after ~35s) before concluding the TERM didn't land. Restart procedure: `for p in $(pgrep -f 'brew-ops-bot/bot.sh'); do kill "$p"; done` → wait → confirm gone → `cd <primary> && nohup bash scripts/brew-ops-bot/bot.sh >/dev/null 2>&1 & disown`. Chat-watchers are disowned children and survive the bot restart; the new bot's boot `recover_watchers` skips the still-live ones.

---
*Added via Oracle Learn*
