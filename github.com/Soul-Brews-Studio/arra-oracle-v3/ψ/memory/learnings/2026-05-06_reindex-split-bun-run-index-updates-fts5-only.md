---
title: **Reindex split: `bun run index` updates FTS5 only, NOT vector embeddings** (`So
tags: [brew-ops, repo:arra-oracle-v3, oracle, indexer, fts5, bge-m3, lancedb, gotcha]
created: 2026-05-06
source: brew-ops session 2026-05-05 — surfaced when reindexing after architect handoff retro 20.53
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **Reindex split: `bun run index` updates FTS5 only, NOT vector embeddings** (`So

**Reindex split: `bun run index` updates FTS5 only, NOT vector embeddings** (`Soul-Brews-Studio/arra-oracle-v3` package.json scripts).

Two scripts; their names are misleading at a glance:

| Script | What it does | Use when |
|---|---|---|
| `bun run index` (= `bun src/indexer/cli.ts`) | FTS5 + SQLite ingest only. Logs "Skipping vector indexing (SQLite-only mode)". | Quick keyword-search refresh after new retros/learnings land. Cheap (~10s for ~3k docs). |
| `bun src/scripts/index-model.ts bge-m3` | Rebuilds bge-m3 vector index in LanceDB. **Drops the collection first, re-embeds every doc** — not incremental. | After `bun run index`, when you also want semantic / Thai↔EN cross-language search to find the new docs. Slow (~5 min for ~3k docs at ~10/sec). |
| `bun run reindex:full` | Both, sequentially. | The "I want everything searchable, no thinking" path. |

**Symptom of the gotcha**: `arra_search mode:hybrid` returns 0 vector matches for a freshly-added retro. FTS5 finds it; vector doesn't. Diagnostic: `arra_search mode:vector ...` — if also 0 matches, vector index is stale.

**Why it surprises**: the script literally named "index" sounds complete; only `reindex:full`'s name hints at the split. `bun run index` even prints `Run 'bun src/scripts/index-model.ts bge-m3' to populate vector embeddings.` at the end — easy to miss.

**How to apply**: when a user says "reindex" + just wants new retro searchable → ask whether they need vector or FTS-only. If unsure, use `bun run reindex:full` (slow but comprehensive). Don't assume `bun run index` covers vector.

---
*Added via Oracle Learn*
