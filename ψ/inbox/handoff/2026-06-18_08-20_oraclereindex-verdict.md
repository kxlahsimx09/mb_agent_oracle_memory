# Oracle nightly reindex — VERDICT: **(A) Scheduled at 03:00 Asia/Bangkok AND succeeding**

Read-only diagnostic, campaign `oraclereindex` (brew-ops), 2026-06-18 GMT+7. Confirms the prior `oraclevec` signal: the `oracle_knowledge_bge_m3.lance` ~03:03 mtime **IS** the scheduled nightly `reindex:full`, not an unrelated trigger.

## Schedule mechanism (NOT cron / NOT pm2 — a systemd USER timer)
- **No crontab** (`crontab -l` / root: "no crontab"), **no pm2** (`pm2: command not found`), no `/etc/cron.d` entry, no GH Action. Schedule lives in **systemd user units**:
- `~/.config/systemd/user/oracle-reindex.timer`:
  ```
  [Unit] Description=Nightly Oracle full reindex (03:00 Asia/Bangkok)
  [Timer] OnCalendar=*-*-* 03:00:00
          Persistent=true
          RandomizedDelaySec=300
  [Install] WantedBy=timers.target
  ```
  Status: `enabled`, `active (waiting) since Mon 2026-06-15 16:25:57 +07`. **Next trigger: Fri 2026-06-19 03:01:17 +07.**
- **Timezone = Asia/Bangkok (+07), NOT UTC.** systemd `OnCalendar` evaluates in system TZ; `timedatectl` = `Asia/Bangkok (+07)`, and `list-timers` shows trigger `... 03:01:17 +07`. So **03:00 GMT+7**. `RandomizedDelaySec=300` adds 0–5min jitter → actual starts 03:01–03:03. `Persistent=true` = catch-up if host was down.
- `~/.config/systemd/user/oracle-reindex.service` (Type=oneshot):
  - `ExecStart=/home/ubuntu/.bun/bin/bun run reindex:full`
  - `WorkingDirectory=/home/ubuntu/Code/.../arra-oracle-v3` (the §3c PRIMARY checkout, not a worktree)
  - `After=ollama.service` (Ollama = embedding backend; `ollama.service` enabled)
  - `ExecStartPost=/usr/bin/systemctl --user restart oracle-http.service` (restarts HTTP API after each reindex — this is what recovers the API from manifest-drift)
  - `TimeoutStartSec=6h`
- **What `reindex:full` runs** (primary checkout `package.json`):
  `"reindex:full": "bun src/indexer/cli.ts && bun src/scripts/index-model.ts bge-m3"`
  → step 1 rebuilds **FTS5** (SQLite) from the vault; step 2 rebuilds the **bge-m3** LanceDB vector collection. **Only bge-m3** vectors are rebuilt — see caveat.

## Run evidence — last 3 nights, ALL SUCCEED (journal = full available history; timer re-armed 06-15 16:25)
| Night (GMT+7) | Started | Done | Indexed | Errors | Result |
|---|---|---|---|---|---|
| 2026-06-16 | 03:02:14 | 06:02:14 | 5220 docs | 0 batches | Finished ✓ |
| 2026-06-17 | 03:01:14 | 06:24:37 | 5280 docs | 0 batches | Finished ✓ |
| 2026-06-18 | 03:03:14 | 06:27:51 | 5390 docs | 0 batches | Finished ✓ |

- `systemctl --user status oracle-reindex.service` (last run): `ExecStart ... (code=exited, status=0/SUCCESS)`, `Main PID ... status=0/SUCCESS`, `ExecStartPost ... status=0/SUCCESS`. Log tail: `=== Done === / Indexed: 5390 docs / Errors: 0 batches / Time: 12253.9s`. Runtime ~3h24m/night (Ollama embeds ~0.4 docs/s).
- **Doc count climbs monotonically 5220 → 5280 → 5390** = the index genuinely advances each night.
- **bge_m3.lance dir mtime `2026-06-18 03:03:37`** lines up exactly with the 03:03:14 run start → **the prior `oraclevec` 03:03 mtime is confirmed as the nightly `reindex:full`.** (Refutes "it's something else.")
- `arra_stats`: `total_documents:5393, fts_indexed:5393, vector_status:connected, fts_status:healthy, last_indexed:2026-06-18T00:53:44Z` (=07:53 GMT+7 — an incremental `arra_learn` write AFTER the 06:27 run, i.e. the index also advances live on top of the nightly full rebuild).

## Caveat (NOT a failure — flag for owner)
Nightly job rebuilds **FTS5 + bge-m3 only**. The other two LanceDB collections are stale: `oracle_knowledge_qwen3.lance` mtime 2026-06-15 15:21 (a restore event), `oracle_knowledge.lance` (nomic/default) mtime 2026-04-14. If search ever routes to `model=qwen3` or `model=nomic`, those vectors are NOT refreshed by the nightly run. bge-m3 is the default search model so day-to-day search is fine. No action needed unless owner wants qwen3/nomic kept current — would mean extending `reindex:full` with `index-model.ts qwen3` / `nomic` (do NOT apply without owner OK; each adds ~3h runtime).

## Bottom line
Nightly `reindex:full` is real, scheduled at **03:00 Asia/Bangkok** (systemd user timer, +0–5min jitter), and has **succeeded cleanly the last 3 nights (exit 0, 0 errors, doc count rising)**. No fix required.
