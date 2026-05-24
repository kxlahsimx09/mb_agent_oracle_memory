---
title: brew-ops-bot (brewbot, @mb_blocker_bot, token 8254271662) — silent-death diagnos
tags: [brew-ops, repo:arra-oracle-v3, fleet, telegram, gotcha, brew-ops-bot, diagnosability]
created: 2026-05-24
source: brew-ops debug session 2026-05-24 — brewbot down investigation
project: github.com/soul-brews-studio/arra-oracle-v3
---

# brew-ops-bot (brewbot, @mb_blocker_bot, token 8254271662) — silent-death diagnos

brew-ops-bot (brewbot, @mb_blocker_bot, token 8254271662) — silent-death diagnosability gap + restart procedure.

#brew-ops #repo:arra-oracle-v3 #fleet #gotcha

OBSERVED 2026-05-24: brewbot was "not working at all" (3 user Telegram messages queued unanswered, incl. "/chats"). Root cause: the `scripts/brew-ops-bot/bot.sh` long-poll `getUpdates` process had DIED ~2026-05-23 15:14:53 and nothing restarted it. Telegram side was healthy (getMe ok, updates queued) — purely a dead process.

HOW TO TELL "dead" vs "stuck": `pgrep -fl 'brew-ops-bot/bot.sh'` returns nothing. Last `~/.cache/brew-ops-bot/bot.log` line was `editMessageText failed, recreating:` (empty resp) with NO following `shutting down (pid=...)` line — that trap-logged line only appears on clean INT/TERM, so its absence = uncaught error / SIGKILL, not a clean stop. Child chat-watchers it spawned kept running ~4h afterward (until their panes died), which rules out a machine reboot — only bot.sh itself died.

WHY THE CRASH CAUSE WAS INVISIBLE (the real gap): the documented start command in SKILL.md is `nohup bash scripts/brew-ops-bot/bot.sh > /dev/null 2>&1 & disown` — stderr → /dev/null. bot.sh runs under `set -u` (nounset) with NO ERR/EXIT trap, so a single unbound-variable reference in any `cmd_*` handler aborts the whole main loop, and the fatal `line NNN: VAR: unbound variable` message is discarded. The exact crashing variable for the 2026-05-23 death is therefore UNCONFIRMED (symptom localized to the update_status editMessageText→recreate path, bot.sh:211-250).

FIX APPLIED: restarted with stderr captured — `nohup bash scripts/brew-ops-bot/bot.sh >> ~/.cache/brew-ops-bot/bot.stderr.log 2>&1 & disown`. Confirmed: exactly one persistent poller (PPID 1; transient `bash bot.sh` children with PPID=<bot> are command-substitution subshells, NOT duplicate pollers — pid changes each check, harmless), queue drained (last-update-id advanced 733→737, getUpdates pending=0), stderr clean. On boot `main()` runs `recover_watchers` (re-spawns chat-watchers) + `update_status`, and queued plain-text messages get re-routed to the active chat (catch-up).

STRUCTURAL DEBT (not yet fixed): (1) start command should redirect stderr to bot.stderr.log, not /dev/null, so the next crash is diagnosable; (2) no supervisor/auto-restart — one unbound var kills brewbot until a human notices; (3) `set -u` + no error handling around `dispatch` makes the whole long-poll loop fragile to any single command handler bug.

---
*Added via Oracle Learn*
