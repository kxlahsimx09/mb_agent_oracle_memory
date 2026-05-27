---
title: gotcha — chat-watcher.sh dies permanently on claude cold-start and bot.sh never 
tags: [brew-ops, repo:arra-oracle-v3, fleet, chat-watcher, brew-ops-bot, telegram, jsonl, cold-start, silent-fail, respawn, gotcha]
created: 2026-05-26
source: brew-ops session 2026-05-26 — chat-watcher 124045 silent-dead diagnosis + respawn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# gotcha — chat-watcher.sh dies permanently on claude cold-start and bot.sh never 

gotcha — chat-watcher.sh dies permanently on claude cold-start and bot.sh never auto-respawns it

## Symptom
A Telegram chat goes silent: the agent in its tmux pane is alive and writing JSONL, the user sends messages, but nothing is pushed back to Telegram. `pgrep -fl chat-watcher.sh` shows no watcher for that chat; no `watch.<chat>.pid` and no `last-line.<chat>` state file exist.

## Root cause (observed 2026-05-26, chat brew-ops/20260526-124045, pane %157)
On spawn, chat-watcher.sh waits up to `JSONL_WAIT_SECONDS` (default **180s**) for claude's first JSONL write (chat-watcher.sh:150-166), then `log "JSONL dir never appeared — bailing"; exit 1`. claude cold-start with the large CLAUDE.md is **slower than 180s** — the JSONL dir appeared at +7min (watcher started 12:41:05, bailed 12:44:26, dir mtime 12:48). **180s is still insufficient** even though it was already bumped up from the original 30s.

The structural gap: **bot.sh spawns chat-watchers on-demand only (bot.sh:314 `nohup bash "$watcher_script" ...`) and has no logic to detect+respawn a watcher that bailed.** So a bailed watcher stays dead until manually respawned — the chat is silently broken for as long as the operator doesn't notice.

## Fix recipe (manual, no code change)
1. Confirm pane alive + JSONL now exists: `tmux list-panes -a -F '#{pane_id} #{pane_current_path}'`, `ls -dla ~/.claude/projects/*<ts>*`.
2. (optional backfill) Seed `~/.cache/brew-ops-bot/last-line.<role>_<ts>` with `<full_jsonl_path>|<line>`. State format is `<jsonl_path>|<line_count>` (chat-watcher.sh:45,175-188). On start it resumes ONLY if `saved_path == current_jsonl` exactly (else logs "saved state stale — priming at EOL", no backfill). To push only the latest reply, seed `<line>` = line# of the last human prompt − 1 (find via `jq -rc 'input_line_number as $n|[$n,.type,(.role//"-")]|@tsv'`). `extract_text` (chat-watcher.sh:134-142) pushes only `.type=="assistant"` entries with non-empty `.message.content` text, so tool-call-only turns are correctly skipped.
3. Respawn from the PRIMARY checkout (§3c — the daemon runs from `~/Code/.../arra-oracle-v3`, not a worktree): `nohup bash ~/Code/github.com/Soul-Brews-Studio/arra-oracle-v3/scripts/brew-ops-bot/chat-watcher.sh %<pane> <role>/<ts> </dev/null >/dev/null 2>&1 & disown`.
4. Verify: log shows "resumed from saved state: line N" + "pushed assistant turn", `watch.<chat>.pid` reappears.

## Diagnostic
Find silently-dead watchers: list worktree panes (`tmux list-panes -a`) vs running watchers (`pgrep -fl chat-watcher.sh`); a pane with no matching watcher is silently broken.

## Durable-fix candidates (code change, needs PR + human approval)
(A) raise `JSONL_WAIT_SECONDS` well past claude+large-CLAUDE.md cold-start (≥ ~480s); (B) have bot.sh re-check `watch.*.pid` liveness on each active-chat poll and respawn a bailed watcher; (C) on incoming user message to a chat, ensure-watcher before delivering. Same silent-fail class as the maw-wake / inbox-watcher silent-fail trio.

---
*Added via Oracle Learn*
