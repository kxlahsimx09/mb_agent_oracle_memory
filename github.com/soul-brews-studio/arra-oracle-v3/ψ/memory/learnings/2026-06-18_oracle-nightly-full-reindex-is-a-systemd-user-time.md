---
title: Oracle nightly full reindex is a systemd USER timer (NOT cron, NOT pm2) — verifi
tags: [repo:arra-oracle-v3, indexer, vector, brew-ops, reindex, lancedb, bge-m3, fts5, systemd-timer, cron, schedule, ollama]
created: 2026-06-18
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Oracle nightly full reindex is a systemd USER timer (NOT cron, NOT pm2) — verifi

Oracle nightly full reindex is a systemd USER timer (NOT cron, NOT pm2) — verified A/succeeding 2026-06-18.

WHERE THE SCHEDULE LIVES: `~/.config/systemd/user/oracle-reindex.timer` → `oracle-reindex.service`. There is NO crontab (`crontab -l` = "no crontab" for ubuntu AND root), NO pm2 (`pm2: command not found`), no `/etc/cron.d` entry, no GH Action. If asked "is the nightly reindex scheduled?", check `systemctl --user list-timers --all | grep oracle` FIRST — it's a user timer, so plain `systemctl list-timers` (system scope) misses it.

SCHEDULE: timer `OnCalendar=*-*-* 03:00:00`, `Persistent=true`, `RandomizedDelaySec=300`. TZ = **Asia/Bangkok (+07), NOT UTC** (systemd OnCalendar uses system TZ; `timedatectl`=Asia/Bangkok). Jitter → actual start 03:01–03:03 GMT+7. So "03:00" means 03:00 Bangkok.

WHAT IT RUNS: service `ExecStart=bun run reindex:full` in the PRIMARY checkout `~/Code/.../arra-oracle-v3` (not a worktree); `After=ollama.service`; `ExecStartPost=systemctl --user restart oracle-http.service` (this post-step is what recovers the HTTP API from LanceDB manifest-drift after each rebuild); `TimeoutStartSec=6h`. `reindex:full` = `bun src/indexer/cli.ts && bun src/scripts/index-model.ts bge-m3` → rebuilds FTS5 + **bge-m3 vectors ONLY**.

CAVEAT: qwen3 + nomic/default LanceDB collections are NOT rebuilt nightly (stale mtimes). Only bge-m3 (the default search model) is refreshed. Fine for default search; flag if qwen3/nomic search is needed.

RUN-SUCCESS CHECK (how to confirm it fired+succeeded): `systemctl --user status oracle-reindex.service` (look for `status=0/SUCCESS`) and `journalctl --user -u oracle-reindex.service -o short-iso | grep -E 'Starting|=== Done ===|Indexed:|Errors:|Finished'`. Healthy run logs `=== Done === / Indexed: N docs / Errors: 0 batches`, runs ~3h (Ollama ~0.4 docs/s), doc count climbs night-over-night. Verified 06-16/06-17/06-18 all exit 0, 0 errors, 5220→5280→5390 docs.

CONFIRMS the `oraclevec` signal: `oracle_knowledge_bge_m3.lance` ~03:03 mtime == the nightly reindex:full start (timer triggered 03:03:14, dir mtime 03:03:37), NOT an unrelated write.

---
*Added via Oracle Learn*
