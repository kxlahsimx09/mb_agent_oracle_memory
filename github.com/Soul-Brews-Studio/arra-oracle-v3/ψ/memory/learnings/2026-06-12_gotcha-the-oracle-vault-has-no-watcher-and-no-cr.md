---
title: GOTCHA — the Oracle vault has NO watcher and NO cron; fresh ψ/ files are invisib
tags: [brew-ops, repo:arra-oracle-v3, indexer, vault, fts5, gotcha, reindex, no-watcher, last-indexed, grounding]
created: 2026-06-12
source: brew-ops thread #15 dispatch — vault reindex + grounding hardening (2026-06-12)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# GOTCHA — the Oracle vault has NO watcher and NO cron; fresh ψ/ files are invisib

GOTCHA — the Oracle vault has NO watcher and NO cron; fresh ψ/ files are invisible to search until a MANUAL reindex.

Tags: #brew-ops #repo:arra-oracle-v3 #indexer #vault #fts5 #gotcha #reindex

**Symptom (2026-06-12, thread #15):** retros written directly into the vault (build2 2026-06-11, bankbot2 2026-06-12) returned 0 FTS hits a full day after being committed+pushed. The orchestrator's round-1 grounding missed both predecessor sessions because of it.

**Root cause:** `src/indexer/cli.ts` (SQLite+FTS5) and `src/scripts/index-model.ts` (vector) are MANUAL one-shot CLIs. There is no `fs.watch` in `src/indexer`, no crontab entry, nothing in `scripts/` invokes the indexer, and launchd has only `com.soulbrews.worktree-janitor` (unrelated). So any file written into ψ/ by editor/cp/git is NOT ingested until someone runs the indexer by hand. ONLY MCP writes — `arra_learn`, `arra_handoff` — insert into oracle.db at write-time and are therefore immediately searchable.

**The misleading bit:** `arra_stats.last_indexed` is computed as `MAX(indexed_at)` over the oracle_documents table (src/tools/stats.ts), NOT a "last full scan" timestamp. So an `arra_learn` write bumps last_indexed and makes the index LOOK fresh while direct-to-vault files sit unscanned. Don't trust last_indexed as proof the vault was scanned.

**Cheap durable fix (recommended, not yet built — needs a brief):** a periodic launchd job running just STEP 1 `bun src/indexer/cli.ts` (FTS rebuild is seconds) against `ORACLE_REPO_ROOT=mb_agent_oracle_memory` every ~5–15 min — same launchd pattern as the worktree-janitor already in this repo. Keep the ~84-min vector STEP 2 manual/nightly. Complementary: orchestrator SKILL.md now mandates session-close handoffs via `arra_handoff` (MCP, embeds immediately), which closes the handoff leg regardless of the scanner (commit 24b6794).

**Reindex run facts refreshed (2026-06-12):** correct procedure unchanged (main checkout w/ the _universal/ψ fix 78933e3; `ORACLE_REPO_ROOT` = vault git root, NOT ~/.arra-oracle-v2; back up oracle.db + lancedb/oracle_knowledge_bge_m3.lance first; never two index-model.ts at once). Discovered **12** project-first ψ/ dirs now (was 9 on 2026-05-30). Healthy full count after reindex: **5067** docs = 2476 learning + 2550 retro + 41 principle (resonance). STEP 1 "Smart delete: 0 stale docs (preserving arra_learn)" → MCP-written learnings are preserved across reindex.

---
*Added via Oracle Learn*
