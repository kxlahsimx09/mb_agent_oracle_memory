---
title: #repo:arra-oracle-v3 #search #vector #brew-ops #lancedb #chromadb #gotcha #decis
tags: [repo:arra-oracle-v3, search, vector, brew-ops, lancedb, chromadb, gotcha, decision]
created: 2026-06-18
source: brew-ops campaign oraclevecfix, 2026-06-18
project: github.com/soul-brews-studio/arra-oracle-v3
---

# #repo:arra-oracle-v3 #search #vector #brew-ops #lancedb #chromadb #gotcha #decis

#repo:arra-oracle-v3 #search #vector #brew-ops #lancedb #chromadb #gotcha #decision

# Oracle "vector DEGRADED" false-alarm — cosmetic fix shipped (PR #2483 → alpha)

Follow-up to the `oraclevec` diagnostic (handoff `2026-06-18_07-53_oraclevec-verdict`): the index is HEALTHY (embedded LanceDB, vector_status=connected, 5392 docs). The "vector DEGRADED / FTS-only" line is a FALSE ALARM driven by stale `ChromaDB` labels + a latched cosmetic warning. Campaign `oraclevecfix` applied the 3 cosmetic fixes (NO index rebuild, NO search-behaviour change):

1. **Label rename** — stale `ChromaDB` labels that mislabel the DEFAULT LanceDB backend → `[Vector]` / "LanceDB vectors" / "vector index": `src/tools/search/definition.ts` (oracle_search desc), `handler.ts` + `vector.ts` (`[ChromaDB]`/`[ChromaDB ERROR]` log prefixes), `src/tools/stats.ts` (oracle_stats desc), `src/server/handlers.ts` (doc comment). Real `type:'chroma'` adapter code (adapters/chroma-mcp.ts, ChromaDBInternalEmbeddings, adapter enumerations) left UNTOUCHED — chroma is a genuine adapter option, not a stale label.
2. **De-latch `logLocalVectorDisabled`** (`src/vector/cpu-capabilities.ts`) — replaced the once-per-process `loggedDisable` boolean with last-reason tracking (logs on STATE TRANSITION only, no spam) + `noteLocalVectorEnabled()` re-arm wired into `handlers.ts` (the only caller of logLocalVectorDisabled on alpha; factory.ts was refactored to not log).
3. **Harden `localVectorIndexMissingReason`** — added `|| process.env.ORACLE_VECTOR_DB_PATH || LANCEDB_DIR` (+ VECTORS_DB_PATH for sqlite-vec) to mirror createVectorStore's default chain, so a preset omitting dataPath can't false-positive "directory is missing".

## Mechanics gotchas (durable)
- **`alpha` is the working trunk**, NOT `feat/all-prs-rebased` (now stale) and NOT `main` (pushing to main triggers a STABLE release + is blocked by `.claude/hooks/block-push-main.sh`). Recent PRs + the updated CLAUDE.md confirm: branch off `origin/alpha`, PR into `alpha`. The wt-c-oraclevecfix worktree was ~969 commits behind alpha — re-applied fixes on a fresh branch off `origin/alpha`, did NOT carry the stale diff.
- On `alpha`, `src/tools/search.ts` was split into `src/tools/search/{definition,handler,vector}.ts` — the stale `[ChromaDB]` labels MOVED there; a file-scoped `rg src/tools/search.ts` misses them. Always re-grep on the actual base branch.
- **`kxlahsimx09` cannot merge PRs on Soul-Brews-Studio/arra-oracle-v3** (GraphQL: "does not have the correct permissions to execute MergePullRequest"), even with CI green + MERGEABLE/CLEAN. Same perms class as the oracle-studio label limitation. Fork-based PRs: push to `fork` remote (kxlahsimx09/arra-oracle-v3), PR head `kxlahsimx09:<branch>` → base `Soul-Brews-Studio:alpha`. Merge must be done by a privileged account (orchestrator/owner).

## §3c re-sync note
The RUNNING checkout (inbox-watcher daemon + MCP server, primary `~/Code/.../arra-oracle-v3`) only picks up these labels on the next §3c re-sync (git merge --ff-only + daemon restart). Cosmetic + NON-URGENT — do NOT restart the daemon for this.

---
*Added via Oracle Learn*
