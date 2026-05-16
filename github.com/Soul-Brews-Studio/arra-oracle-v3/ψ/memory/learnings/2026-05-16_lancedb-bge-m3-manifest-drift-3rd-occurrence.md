---
title: ## LanceDB bge-m3 manifest drift — 3rd occurrence (2026-05-16), recurring P0
tags: [lancedb, bge-m3, vector-search, manifest-drift, reindex, brew-ops, P0, oracle, recurrence, worktree-node-modules]
created: 2026-05-16
source: brew-ops thread #110 self-fix, 2026-05-16
project: github.com/soul-brews-studio/arra-oracle-v3
---

# ## LanceDB bge-m3 manifest drift — 3rd occurrence (2026-05-16), recurring P0

## LanceDB bge-m3 manifest drift — 3rd occurrence (2026-05-16), recurring P0

**Symptom:** `arra_search` silently degrades to FTS5-only. Warning: `Vector search unavailable: lance error: Not found … oracle_knowledge_bge_m3.lance/data/<frag>.lance`. `arra_stats` still reports `vector_status: connected` (misleading — that only checks the handle exists, not that queries work).

**Root cause:** `@lancedb/lancedb@0.27.2` has no inter-process write lock. A concurrent `arra_learn` write produces a new manifest version referencing a data fragment that was never flushed / got GC'd by a parallel writer. Every vector query then hits the broken manifest. Recurrences: 2026-04-14, 2026-04-21, 2026-05-16 — same family as `2026-04-14_arra-oracle-indexer-server-lancedb-drift`.

**Fix (canonical rebuild — SQLite is the source of truth):**
1. `bun src/scripts/index-model.ts bge-m3` — drops the corrupt LanceDB table and rebuilds from `oracle_documents ⨝ oracle_fts`. ~3600 docs / 73 batches / ~7min via Ollama bge-m3. SQLite + vault markdown are never touched.
2. Restart the Oracle HTTP server (`kill <pid>` then `bun src/ensure-server.ts`) — long-lived processes cache the LanceDB `Table` handle and never auto-refresh after an external drop+recreate; `search.ts` swallows the error without resetting `this.table`. Restart is required for the process to open the rebuilt table.

**Gotchas:**
- Git worktrees created without `bun install` lack `@lancedb/lancedb` + `apache-arrow` in `node_modules` → `index-model.ts` fails with `Cannot find package 'apache-arrow'`. Run the script via the **main repo's** path so Bun resolves the main `node_modules` (DB + LanceDB paths are absolute HOME-based, so cwd is irrelevant for data location).
- After rebuild, `getStats().count` may report N+1 (one residual `__init__` placeholder row from `ensureCollection`'s schema-defining dummy). Harmless — empty text / zero vector, never surfaces in results.
- Verify with HTTP `GET /api/search?mode=vector` (results carry `source: "vector"`, no `warning`) or MCP `arra_search` hybrid (`metadata.vectorMatches > 0`).

**Durable-fix candidate (still open):** the no-write-lock recurrence is unaddressed — write serialization for `arra_learn`, or a periodic LanceDB integrity check with auto-rebuild, would stop this from recurring.

---
*Added via Oracle Learn*
