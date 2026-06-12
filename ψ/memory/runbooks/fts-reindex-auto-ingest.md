---
title: Runbook — periodic FTS auto-ingest for the Oracle vault (com.soulbrews.fts-reindex)
tags: [brew-ops, repo:arra-oracle-v3, indexer, vault, fts5, reindex, launchd, runbook]
created: 2026-06-12
source: brew-ops thread #15 (orchestrator dispatch — build the auto-ingest job)
project: github.com/Soul-Brews-Studio/arra-oracle-v3
---

# Runbook — Oracle vault FTS auto-ingest (`com.soulbrews.fts-reindex`)

## Why this exists

The Oracle vault has **no watcher and no cron** of its own. The indexer is a
manual one-shot CLI, so a retro/handoff written **directly into `ψ/`** (editor,
`cp`, `git pull`) is invisible to search until someone reindexes by hand. Only
MCP writes (`arra_learn` / `arra_handoff`) embed at write-time. On 2026-06-11/12
this hid two orchestrator close-retros (build2, bankbot2) for a full day and the
next orchestrator's round-1 grounding missed both predecessors (thread #15;
learning `2026-06-12_gotcha-the-oracle-vault-has-no-watcher-and-no-cr`).

This job runs **STEP 1 only** (`bun src/indexer/cli.ts` — SQLite + FTS5,
seconds) on an interval so fresh vault files become FTS-searchable within ~one
interval. **STEP 2** (the ~84-min `index-model.ts` vector build) is **never
scheduled** — it stays manual/on-demand. Consequence by design: a brand-new file
is **FTS-discoverable within ~15 min, vector-discoverable after the next manual
STEP 2**. That is the accepted trade (hybrid search still finds it via FTS).

## What it runs

| Piece | Path |
|---|---|
| Wrapper | `arra-oracle-v3/scripts/fts-reindex.sh` |
| plist template | `arra-oracle-v3/scripts/launchd/com.soulbrews.fts-reindex.plist` |
| Installer | `arra-oracle-v3/scripts/install-launchd-fts-reindex.sh` |
| Rendered plist | `~/Library/LaunchAgents/com.soulbrews.fts-reindex.plist` |
| Job log | `~/.cache/fts-reindex/fts-reindex.log` |
| Heartbeat | `~/.cache/fts-reindex/last-run` (mtime = last tick, body = status) |
| Vault signature | `~/.cache/fts-reindex/indexed-sig` (change-detection baseline) |
| launchd stdout/err | `~/.cache/soul-brews-startup/fts-reindex.launchd.log` |

- **Interval:** `StartInterval` = **900s (15 min)** in the plist. Tunable —
  edit the plist `<integer>` and re-run the installer.
- Runs from the **MAIN** `arra-oracle-v3` checkout (the `_universal/ψ` discovery
  fix, commit `78933e3`) with `ORACLE_REPO_ROOT` = the vault git root
  `~/Code/github.com/kxlahsimx09/mb_agent_oracle_memory` (NOT `~/.arra-oracle-v2`,
  which holds only the `ψ` symlink → indexes 0 per-repo learnings). Both are
  baked into the plist `EnvironmentVariables` at install time.

## Guards (why a 15-min cron is safe + cheap)

1. **Single STEP-1 at a time** — atomic `mkdir` lock (`~/.cache/fts-reindex/lock.d`);
   a holder older than 20 min is treated as crashed and reaped. (launchd also
   coalesces same-Label jobs, so this is belt-and-suspenders.)
2. **Never overlaps a vector build** — skips the tick if `index-model.ts` is
   running. STEP 1 rewrites `oracle.db` rows; WAL (`busy_timeout=5000`) prevents
   "database is locked" but **not** a consistent snapshot for STEP 2's
   row-by-row pagination, so STEP 1 is *not* provably safe alongside STEP 2.
   Deferring a 15-min tick during an infrequent 84-min build is free.
3. **Change-detection** — computes a signature of the vault repo
   (`git rev-parse HEAD` + `cksum` of `git status --porcelain`) and skips the
   indexer when it matches the last successful index. This avoids the indexer's
   per-run **38 MB `oracle.db` backup + JSON/CSV export** during quiet periods;
   a successful run also prunes those auto-backups to the newest 20.

A reindex still keeps existing vectors valid: document ids are derived from the
source-file path (stable), not SQLite rowids, so STEP 1 re-using a path re-uses
the id — LanceDB entries do not orphan.

## Install / verify / disable

```bash
cd ~/Code/github.com/Soul-Brews-Studio/arra-oracle-v3
bash scripts/install-launchd-fts-reindex.sh        # idempotent (unloads first)

launchctl list | grep fts-reindex                  # is it scheduled?
cat ~/.cache/fts-reindex/last-run                  # last tick + status
tail -n 20 ~/.cache/fts-reindex/fts-reindex.log    # recent activity

# force a run now (bypasses change-detection; still honors the vector guard):
ARRA=$PWD ORACLE_REPO_ROOT=~/Code/github.com/kxlahsimx09/mb_agent_oracle_memory \
  bash scripts/fts-reindex.sh --force

# disable / re-enable:
launchctl unload ~/Library/LaunchAgents/com.soulbrews.fts-reindex.plist
launchctl load   ~/Library/LaunchAgents/com.soulbrews.fts-reindex.plist
```

## Is it dead? (the failure mode this job exists to kill)

A silently-dead scheduler would re-create "index looks fresh but isn't". Detect:

- **Heartbeat mtime** of `~/.cache/fts-reindex/last-run` should be **< ~2×
  interval** old (≈30 min). Staler ⇒ the job is not firing.
- `launchctl list | grep fts-reindex` should list it; a non-zero last-exit
  column means the indexer failed — see `fts-reindex.log` for the `FAIL rc=…`
  line + output tail.
- Note: `arra_stats.last_indexed` is `MAX(indexed_at)` over the docs table, so
  an `arra_learn` write alone bumps it. **Do not** use it to judge whether this
  job is alive — use the heartbeat.

Status values written to `last-run`: `OK <Indexed N documents>` (ran),
`SKIP unchanged` / `SKIP vector-build` / `SKIP lock` (intentional no-op),
`FAIL rc=<n>` (indexer error — investigate).

## Future hardening (not built — would need a brief)

- Telegram alert on `FAIL` (reuse `scripts/brew-ops-bot/` send path) and/or a
  detector that watches the heartbeat for staleness — turns "dead job" from a
  pull-check into a push-alert.
