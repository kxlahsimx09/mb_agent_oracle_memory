---
title: Brew-ops-bot can silently miss Codex Telegram replies if watcher startup failure
tags: [brew-ops, brew-ops-bot, telegram, codex, watcher, auto-push, startup-failure, pr-95]
created: 2026-05-25
source: brew-ops debug, PR #95
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Brew-ops-bot can silently miss Codex Telegram replies if watcher startup failure

Brew-ops-bot can silently miss Codex Telegram replies if watcher startup failure is not propagated.

Observed 2026-05-25 on `next-writer/20260525-083721`: `/new next-writer codex` created a Codex pane and Codex wrote `agent_message` responses to `~/.codex/sessions/...08-37-47...jsonl`, but Telegram received nothing. Bot log showed `watcher script not executable: .../codex-watcher.sh (engine=codex)`, and no `watch.next-writer_20260525-083721.pid` existed. The user-facing `/new` response still claimed `auto-push เปิดอยู่` because `start_watcher_for` returned success implicitly after logging the failure.

Fix shape: `start_watcher_for` should validate readability, not executable bit, because it invokes watchers via `bash`; it must return non-zero if the watcher is unreadable or exits immediately, and `/new`/`/chat`/`/relaunch`/`/watch on` must surface that failure instead of claiming auto-push is active. PR: kxlahsimx09/arra-oracle-v3#95.

---
*Added via Oracle Learn*
