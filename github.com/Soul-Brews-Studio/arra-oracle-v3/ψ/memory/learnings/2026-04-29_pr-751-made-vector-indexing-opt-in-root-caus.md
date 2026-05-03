---
title: ## PR #751 Made Vector Indexing Opt-In — Root Cause for "No Embeddings Yet" Afte
tags: [arra-oracle, indexer, lancedb, bge-m3, workflow-change, pr-751, studio-map, no-embeddings, ollama]
created: 2026-04-29
source: brew-ops diagnosis on dev01, 2026-04-29
project: github.com/soul-brews-studio/arra-oracle-v3
---

# ## PR #751 Made Vector Indexing Opt-In — Root Cause for "No Embeddings Yet" Afte

## PR #751 Made Vector Indexing Opt-In — Root Cause for "No Embeddings Yet" After 2026-04-19

**TL;DR:** PR #751 (`refactor(indexer): separate vector indexing into dedicated script`, merged 2026-04-19 06:06 +0700, commit `ee3d586`) intentionally split `bun run index` into two steps. After this, `bun run index` writes **only SQLite + FTS5** — vectors require a separate `bun src/scripts/index-model.ts` run. Anyone who upgrades past `ee3d586` and continues running only `bun run index` will see Studio's 3D map render "No Embeddings Yet" until they run the second step.

**This is a workflow break, not a bug.** The commit body says it explicitly:

> "Vector refresh is now a deliberate separate run:
>   bun src/indexer/cli.ts           # SQLite + FTS only
>   bun src/scripts/index-model.ts   # vectors (opt-in)"

**Why the split was made:** to fix the path/collection drift documented in `2026-04-14_arra-oracle-indexer-server-lancedb-drift.md`. The old `cli.ts` hardcoded `chromaPath: CHROMADB_DIR` (= `~/.chromadb`) which silently overrode `ORACLE_VECTOR_DB_PATH`. `src/scripts/index-model.ts` uses the `EMBEDDING_MODELS` registry (same source the server uses), so path + collection always align.

## Diagnosing the symptom on a live machine (verified 2026-04-29 dev01)

Three filesystem signals tell you which side of #751 you are on:

| Path | Mtime meaning |
|---|---|
| `~/.chromadb/oracle_knowledge.lance/` recent | old (pre-#751) indexer ran recently — pre-upgrade behavior |
| `~/.arra-oracle-v2/lancedb/oracle_knowledge_bge_m3.lance/` mtime ≈ server start time, dir empty | server-bootstrapped empty collection — vectors never populated post-upgrade |
| Both populated but server still empty | actual drift bug (different root cause) |

Verify with:
```bash
curl -s http://localhost:47778/api/map3d | jq '.total'   # 0 = empty
curl -s http://localhost:47778/api/health | jq '.version'
```

## Fix

```bash
cd /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3
bun src/scripts/index-model.ts bge-m3
```

Reads from SQLite (joined via `oracle_fts`), embeds each chunk through Ollama `bge-m3`, writes to `~/.arra-oracle-v2/lancedb/oracle_knowledge_bge_m3.lance/`. After completion, refresh Studio map page — embeddings appear.

Re-run this whenever vault content changes — `bun run index` alone no longer maintains vector parity.

## Suggested ergonomics fix

`package.json` should expose a combined alias so the two-step is discoverable:

```json
"scripts": {
  "reindex": "bun src/indexer/cli.ts && bun src/scripts/index-model.ts bge-m3"
}
```

Then `bun run reindex` matches the mental model users had pre-#751.

---
*Added via Oracle Learn*
