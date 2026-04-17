---
title: Arra-Oracle Indexer and Server Disagree on LanceDB Path and Collection
type: learning
tags:
  - technical-writer
  - repo:arra-oracle-v2
  - cross
  - oracle-shadow
  - indexer-behavior
  - server-behavior
  - lancedb
  - drift
  - gotcha
related:
  - 2026-04-14_oracle-indexer-folder-as-type
  - 2026-04-14_principle-code-is-truth-docs-are-claims
  - 2026-04-14_principle-patterns-over-intentions
source: >
  src/indexer/cli.ts@HEAD (arra-oracle-v2),
  src/indexer/index.ts@HEAD,
  src/vector/factory.ts@HEAD,
  src/config.ts@HEAD,
  src/scripts/index-model.ts@HEAD.
  Verified 2026-04-14 by running `bun run index` vs `bun run server` on dev01.
created: 2026-04-14
project: github.com/Soul-Brews-Studio/arra-oracle-v2
---

# Arra-Oracle Indexer and Server Disagree on LanceDB Path and Collection

The default indexer (`bun run index` → `src/indexer/cli.ts`) writes LanceDB data to a **different path and different collection name** than the HTTP server reads from. A freshly-indexed vault therefore renders as "No Embeddings Yet" in Oracle Studio's 3D orbital view until the bge-m3-specific indexer is run.

## Evidence

Two call paths resolve LanceDB config differently:

### 1. `bun run index` (the default CLI)

```ts
// src/indexer/cli.ts:7,31
import { DB_PATH, CHROMADB_DIR } from '../config.ts';
const config: IndexerConfig = {
  ...,
  chromaPath: CHROMADB_DIR,   // = ~/.chromadb (hardcoded via const.ts)
};
```

```ts
// src/indexer/index.ts:83
this.vectorClient = createVectorStore({ dataPath: this.config.chromaPath });
```

```ts
// src/vector/factory.ts:73-75 (lancedb branch)
const dbPath = config.dataPath || process.env.ORACLE_VECTOR_DB_PATH || LANCEDB_DIR;
```

Because `config.dataPath` is **truthy and first in the precedence chain**, `ORACLE_VECTOR_DB_PATH` is silently ignored. Collection name also falls back to the default `COLLECTION_NAME` (= `oracle_knowledge`), no suffix.

**Result:** `~/.chromadb/oracle_knowledge.lance/`

### 2. `bun run server` (the HTTP server on :47778)

The server resolves the store via the model registry at `src/vector/factory.ts:146-150`:

```ts
'bge-m3': {
  collection: 'oracle_knowledge_bge_m3',
  model: 'bge-m3',
  dataPath: LANCEDB_DIR,        // = ~/.arra-oracle-v2/lancedb
}
```

**Result:** Server expects `~/.arra-oracle-v2/lancedb/oracle_knowledge_bge_m3.lance/`

### The mismatch

| Side | Path | Collection |
|---|---|---|
| `bun run index` (CLI) | `~/.chromadb/` | `oracle_knowledge` |
| `bun run server` (HTTP) | `~/.arra-oracle-v2/lancedb/` | `oracle_knowledge_bge_m3` |

Two dimensions drift: directory **and** collection name. Setting `ORACLE_VECTOR_DB_PATH=/Users/dev01/.arra-oracle-v2/lancedb` and `ORACLE_VECTOR_COLLECTION=oracle_knowledge_bge_m3` in `.env` does **not** fix the indexer, because the indexer CLI never consults those env vars (it passes a hardcoded path directly to `createVectorStore`).

## Observed symptom

1. Fresh install or vault cleanup.
2. `bun run index` prints: `[LanceDB] Connected at /Users/dev01/.chromadb`, `Collection 'oracle_knowledge' ready`, `Indexed 48 documents` — looks healthy.
3. `bun run server` starts, logs `[VectorDB:lancedb] ✓ Connected but collection empty` — the server is looking at a *different* collection.
4. Studio's Memory orbital shows **"No Embeddings Yet. The 3D map requires vector embeddings from LanceDB. Run a vector index to populate the map."**
5. `/api/map3d` errors with `lance error: Not found: /Users/dev01/.arra-oracle-v2/lancedb/oracle_knowledge_bge_m3.lance/...` — proving the server path is the right one; the indexer wrote to the wrong place.

## Workaround (confirmed working 2026-04-14)

A second, registry-aware indexer exists: `src/scripts/index-model.ts`. It uses the same `EMBEDDING_MODELS` registry the server uses, so path and collection align.

```bash
# Step 1 — populate SQLite + FTS5 (metadata layer)
cd ~/.arra-oracle && bun run index

# Step 2 — populate LanceDB at the canonical path with bge-m3 embeddings
bun src/scripts/index-model.ts bge-m3

# Step 3 — start HTTP server
bun run server
```

Step 2 reads rows from SQLite (joined through `oracle_fts`), embeds each via Ollama `bge-m3`, and writes to `~/.arra-oracle-v2/lancedb/oracle_knowledge_bge_m3.lance/` — which is exactly where the server looks.

After this sequence, Studio orbital correctly renders 48 nodes (41 principle chunks + 7 learning chunks from 5 vault files, granular-split by `###`/`##` headers and bullets per `parser.ts`).

Recommended alias for day-to-day work:

```bash
alias oracle-reindex='cd ~/.arra-oracle && bun run index && bun src/scripts/index-model.ts bge-m3 && cd -'
```

## Why this happens (root cause)

Two facts collide:

1. `src/indexer/cli.ts` was written against an older vector layout where LanceDB data lived at `~/.chromadb` under a single default collection. The name `CHROMADB_DIR` + `chromaPath` is vestigial from the chroma-vector-store days.
2. The registry (`getEmbeddingModels()` in `src/vector/factory.ts`) was added later to support dual/multi-index search (nomic, qwen3, bge-m3) and correctly pins `dataPath: LANCEDB_DIR`. The server was updated to use it (`getVectorStoreByModel('bge-m3')`). **The default CLI indexer was not updated.**

This is a textbook **P-004 drift** (Code is Truth, Documents are Claims): the env-var docblock in `factory.ts:40-47` claims `ORACLE_VECTOR_DB_PATH` configures the LanceDB path, but in the indexer's code path the explicit `config.dataPath` takes precedence and the env var is never read.

It's also **P-002 in action** (Patterns Over Intentions): the intent was "one indexer, one store, one collection." The actual pattern the code exhibits is "two indexers writing to two stores with different names." The pattern is what runs; the intent is what a reader assumes.

## Suggested upstream fix (out of scope for technical_writer)

Two minimal changes would reconcile the two paths without breaking backward compatibility:

1. **`src/indexer/cli.ts`** — use the model registry when an embedding model is configured:

   ```ts
   import { EMBEDDING_MODELS } from '../vector/factory.ts';
   const modelKey = process.env.ORACLE_EMBEDDING_MODEL || 'bge-m3';
   const preset = EMBEDDING_MODELS[modelKey];
   const config: IndexerConfig = {
     ...,
     chromaPath: preset?.dataPath || CHROMADB_DIR,
     collectionName: preset?.collection,   // plumb this into createVectorStore
   };
   ```

2. **`src/vector/factory.ts`** — flip precedence so env vars can override `config.dataPath` when present (or at least log a clear warning when `config.dataPath` silently overrides a set env var).

Filing as a learning per the `technical_writer` charter (`.agent/skills/technical-writer/SKILL.md` §Non-goals: "I never modify source files"). If `system_architect` or the Oracle maintainer wants to tighten this, the evidence chain is here.

## Connection to tagging convention

This learning is tagged `#repo:arra-oracle-v2` — a scope outside the usual mobiz-payment-gateway / target-repo pair. The AGENTS.md §7a 3-layer convention assumes one of those two; I'm extending it to cover the tooling layer (arra-oracle itself) with `#cross` as the system-phase tag because this drift affects both `#current` and `#target` agent work equally.

If this pattern recurs (learnings about Oracle/maw/studio infrastructure), we should add a formal "infrastructure" phase value to AGENTS.md §7a. For now: one-off tag extension, noted here.

## Open questions for future writers

- Does `bun src/scripts/index-model.ts bge-m3` need to run *after* every `bun run index`, or is once enough if only SQLite content changes? (Hypothesis: once enough — vector embeddings are keyed by document id, re-indexing SQLite without new/removed docs doesn't require re-embedding.)
- Does `arra_learn` write to LanceDB or only SQLite? A quick `grep` of `src/tools/learn.ts` for `vectorStore|addDocument|ensureVectorStoreConnected` returned no matches, so **SQLite-only** appears to be the answer — meaning `arra_learn` writes are immediately searchable via `arra_search` FTS but do not appear in Studio's orbital until a `bun src/scripts/index-model.ts bge-m3` run. Worth verifying end-to-end.
- Are the other model indexes (`nomic`, `qwen3`) wired up in the server's fallback logic, or is `bge-m3` the only collection the server actively serves? (Server uses `getVectorStoreByModel('bge-m3')` as default — `nomic` and `qwen3` presumably serve dual-index queries, but the orbital view appears to be bge-m3-only.)
