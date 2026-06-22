## VERDICT: (B) FALSE ALARM — Oracle vector index is NOT degraded

**Campaign `oraclevec` / brew-ops, read-only diagnostic, 2026-06-18.**
The claim *"Oracle vector index is DEGRADED (FTS-only / lancedb file missing); `arra_search query=\"soul-brews-core\" type=principle limit=20` returns 0"* is **FALSE**. Vector, hybrid, and FTS search all work. The owner was right: the warning text is cosmetic/misleading over a functional search.

### Backend reality
- The running Oracle uses **embedded LanceDB** (NOT ChromaDB — the Charter §2 and several code strings say "ChromaDB" but that wording is stale). Evidence: `ORACLE_DATA_DIR=/home/ubuntu/.arra-oracle-v2`, `VECTOR_URL` empty, no `vector-server.json` → embedded mode. `src/vector/adapters/lancedb.ts` is the live adapter; `src/vector/factory.ts` defaults `type='lancedb'`.
- On disk all three model collections EXIST and are actively maintained:
  - `/home/ubuntu/.arra-oracle-v2/lancedb/oracle_knowledge.lance` (nomic/default)
  - `/home/ubuntu/.arra-oracle-v2/lancedb/oracle_knowledge_bge_m3.lance` (default model, mtime 2026-06-18 03:03 — nightly reindex)
  - `/home/ubuntu/.arra-oracle-v2/lancedb/oracle_knowledge_qwen3.lance`
- `arra_stats` → `vector_status: "connected"`, `fts_status: "healthy"`, 5392 docs (41 principle / 2691 learning / 2660 retro), `fts_indexed: 5392`, `last_indexed 2026-06-18T00:15Z`, version `26.4.20-alpha.9`.

### EVIDENCE — real query I/O (vectors demonstrably work)
1. **Reported query reproduced → 20 results, NOT 0.** `arra_search query="soul-brews-core" type=principle limit=20` → `total:20`, metadata `{mode:hybrid, ftsMatches:40, vectorMatches:2, sources:{fts:20,vector:0,hybrid:0}, searchTime:324}`. All 41 `soul-brews-core` principles are indexed and returned. The "0" does not reproduce.
2. **Pure semantic (`mode:vector`) works — embedding-ranked, no token overlap.** `arra_search query="how should an agent treat stored guidance that conflicts with the current situation" mode=vector limit=10` → `vectorMatches:20`, model `bge-m3`, top hit = the *exact* semantic match P-003 sub: *"When stored guidance conflicts with the current situation, the agent may override it, but must write a new learning explaining why."* with cosine distances populated. This is a paraphrase FTS5 could not rank — proves the vector leg is live and correct.
3. Hybrid `soul-brews-core` shows `vectorMatches:2` because a bare tag-token is semantically weak as an embedding query (correct behavior); FTS5 carries it since the tag literally appears in the docs. Both legs ran. Not a degradation.

### Root cause of the reported "0"
Not the vector index. The candidates and verdicts:
- (i) "no principle docs indexed" → FALSE (41 principles, 20 returned).
- (iii) type filter → not the cause (returns 20 with the filter on).
- (iv) vector index down → FALSE (vector mode returns 20 ranked hits).
- (ii) **FTS5 hyphen-as-NOT-operator on `soul-brews-core`** → the only mechanism that yields 0, and it is now FIXED. `buildFtsQuery` (`src/server/handlers.ts:42-53`) and the MCP `sanitizeFtsQuery` tokenize on `/[\p{L}\p{N}_]+/gu` (hyphen = separator) → `"soul" OR "brews" OR "core"`, each token quoted. Unsanitized, FTS5 reads `soul-brews-core` as `soul NOT brews NOT core` → ~0 hits. So a historical 0 most plausibly came from a pre-sanitization build; current code returns 40 FTS matches.
- Most likely in practice: agents **repeated an unverified/stale log line** rather than re-running the query (exactly the confabulation/cargo-cult pattern the owner flagged). The current binary returns 20.

### The warning's source lines (and why it's cosmetic)
- `src/vector/cpu-capabilities.ts:62-77` `localVectorIndexMissingReason()` → returns `"local LanceDB directory is missing"` / `"local LanceDB collection is missing (<name>)"` by `fs.existsSync(${dataPath}/${collection}.lance)`.
- `src/vector/cpu-capabilities.ts:79-83` `logLocalVectorDisabled()` → `console.warn("[Vector] Local vector search disabled: <reason>. Falling back to FTS5-only results.")`. **LATCHED** via the `loggedDisable` flag (line 80): it logs ONCE per process and never clears — so one transient miss (e.g. mid-reindex; `lancedb.write-locks/` mtime 2026-06-18 07:15 shows active reindex churn) leaves a permanently-misleading "disabled" line in the log even after vectors recover.
- `src/server/handlers.ts:121-124` (HTTP `/search` path) sets `warning="<reason>; falling back to FTS5-only results"` from the same gate.
- `src/vector/runtime-status.ts:25-39` `getVectorRuntimeStatus()` → `vectorMode:'disabled'`; feeds `/health` (`src/routes/health/health.ts:13`) and the dashboard "Degraded" badge (`src/dashboard.html:1007`). This one re-evaluates live, so it self-heals.
- The codebase itself documents the intent (`runtime-status.ts:19-24`): *"intentionally observability-only: search handlers keep FTS5 available as the always-on floor even when this reports disabled/proxied."* The MCP `arra_search` path (`src/tools/search.ts:383-399`) does NOT pre-gate at all — it just runs `vectorSearch()` and only warns if it throws.
- Stale-label confusion that fueled the false alarm: `src/tools/search.ts:392` logs vector errors as `"[ChromaDB]"` and `:26` describes the tool as "FTS5 keywords + ChromaDB vectors" — both wrong; the backend is LanceDB.

### Latent fragility (not active today)
`localVectorIndexMissingReason` reads `config.dataPath` directly with NO `|| LANCEDB_DIR` fallback, whereas `createVectorStore` (`factory.ts:80-82`) DOES default to `LANCEDB_DIR`. Today every preset sets `dataPath: LANCEDB_DIR` (`factory.ts:148-168`) so the gate passes — but any future preset that omits dataPath would false-positive "directory is missing" while the real adapter works.

### Proposed fix (cosmetic, PR-able — NO index rebuild; rebuild is owner-gated and NOT warranted, index is healthy)
1. Rename stale `[ChromaDB]`/"ChromaDB vectors" labels → `[Vector]`/"LanceDB vectors" in `src/tools/search.ts:26,392` (and the Charter §2 wording). This is the single change that would have prevented this entire false-alarm chain.
2. (Optional) Make `logLocalVectorDisabled` re-evaluate / de-latch, so a transient mid-reindex miss doesn't leave a sticky misleading log line after recovery.
3. (Optional) Harden `localVectorIndexMissingReason` to apply the same `|| LANCEDB_DIR` default `createVectorStore` uses.

**Action:** treat the "vector DEGRADED" log line as noise; do not repeat it. Search is fully functional. Items 1-3 are safe cosmetic PRs if desired.
