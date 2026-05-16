---
title: ## thread #113 Phase 1 — LanceDB manifest drift is now visible instead of silent
tags: [brew-ops, repo:arra-oracle-v3, search, vector, lancedb, manifest-drift, decision, thread-113, gotcha]
created: 2026-05-16
source: brew-ops thread #113 Phase 1, fork PR #68, 2026-05-16
project: github.com/soul-brews-studio/arra-oracle-v3
---

# ## thread #113 Phase 1 — LanceDB manifest drift is now visible instead of silent

## thread #113 Phase 1 — LanceDB manifest drift is now visible instead of silent

**Decision (brew-ops, 2026-05-16):** thread #113 (parent campaign #108) asked for a durable mitigation of recurring LanceDB manifest drift. `@lancedb/lancedb@0.27.2` has no inter-process write lock — concurrent `arra_learn` writes drift a manifest ~every 1-2 weeks (2026-04-14/04-21/05-16). Shipped direction (3) — kill the silent-failure class — as fork PR kxlahsimx09/arra-oracle-v3#68. Deferred directions (1)+(2) as Phase 2/3.

**Three swallow points found + fixed:**
1. `src/tools/search.ts` `vectorSearch()` caught the `lance error: Not found …` and `return []` — a degraded backend was indistinguishable from a genuine zero-result query. Now re-throws.
2. `handleSearch()`'s try/catch was already written *expecting* a throw; the swallow inside `vectorSearch` was the bug. Now sets a real warning + `metadata.vectorDegraded: true` (machine-readable).
3. `arra_stats` (`src/tools/stats.ts`) reported `ctx.vectorStatus`, captured **once** at MCP startup via `getStats()`→`countRows()`. A drifted manifest still answers `countRows()` (count lives in manifest metadata) while `search()` throws on the missing fragment — so stats stayed `connected` while every query fell back. This is exactly why thread #110 sat undetected. Now does a live `vectorStore.health()` probe → `vector_status: "degraded"` + `vector_error`.

**New:** `LanceDBAdapter.health()` — a real `search()` probe (zero query vector, no Ollama round-trip) that exercises the fragment-read path drift breaks. Optional on `VectorStoreAdapter`; callers fall back to `getStats()`/`vectorStatus` when absent. `LanceDBAdapter.addDocuments` now serializes concurrent in-process writes via a promise chain.

**Honest limit:** Phase 1 makes drift *loud*, not *impossible*. Root cause is *inter-process* concurrency — multiple MCP server instances (one per `claude` pane) + the HTTP server all write `~/.arra-oracle-v2/lancedb/`. An in-process mutex cannot serialize across processes. Drift will still occur, but is now visible in `arra_stats` + every `arra_search` response immediately.

**Open (thread #113 Phase 2/3):**
- Phase 2 (direction 1): file-based inter-process advisory write lock (`<dbPath>/.arra-write.lock`, O_EXCL + stale detection + bounded retry) — the true root-cause fix.
- Phase 3 (direction 2): wire `health()` into MCP startup as an integrity check; keep rebuild operator-invoked (`index-model.ts` ~7 min, P-003 External Brain), do not auto-run.

**How to apply:** when debugging "vector search returns nothing," check `arra_stats.vector_status` — `degraded` + `vector_error` now means manifest drift; rebuild with `bun src/scripts/index-model.ts bge-m3` then restart the HTTP server. If `arra_search` metadata has `vectorDegraded: true`, the backend errored (not empty).

---
*Added via Oracle Learn*
