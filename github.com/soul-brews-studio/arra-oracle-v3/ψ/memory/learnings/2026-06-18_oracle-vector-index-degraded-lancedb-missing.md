---
title: "Oracle vector index DEGRADED / lancedb missing / soul-brews-core returns 0" is 
tags: [search, vector, lancedb, fts5, false-alarm, brew-ops, observability, degraded-warning]
created: 2026-06-18
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# "Oracle vector index DEGRADED / lancedb missing / soul-brews-core returns 0" is 

"Oracle vector index DEGRADED / lancedb missing / soul-brews-core returns 0" is a FALSE ALARM — verified read-only, 2026-06-18 (campaign oraclevec). Ground truth: vector + hybrid + FTS all work. Evidence: arra_stats vector_status=connected, fts_status=healthy, 5392 docs / 41 principles; `arra_search query="soul-brews-core" type=principle limit=20` returns 20 (NOT 0); pure `mode=vector` semantic paraphrase returns 20 embedding-ranked hits (model bge-m3) with the exact semantic match on top. Backend is embedded LanceDB (NOT ChromaDB — that wording in Charter §2 and src/tools/search.ts:26,392 is STALE). All three collections exist on disk: ~/.arra-oracle-v2/lancedb/oracle_knowledge{,_bge_m3,_qwen3}.lance.

Why the scary text prints anyway: the warning is observability-only (src/vector/runtime-status.ts:19-24 literally says so — "search handlers keep FTS5 as the always-on floor"). Source: src/vector/cpu-capabilities.ts:62-83 localVectorIndexMissingReason()+logLocalVectorDisabled(); the latter is LATCHED via loggedDisable (logs ONCE per process, never clears), so one transient miss during the nightly reindex (lancedb.write-locks churn) leaves a permanently-misleading line. The MCP arra_search path (src/tools/search.ts:383-399) doesn't even pre-gate — it runs vectorSearch() directly.

Root cause of a historical "0" on soul-brews-core: FTS5 hyphen-as-NOT-operator (`soul-brews-core` → `soul NOT brews NOT core`), now FIXED by tokenization in buildFtsQuery (src/server/handlers.ts:42-53) which splits on /[\p{L}\p{N}_]+/. Most agents simply repeated a stale log line without re-running (confabulation).

Rule: NEVER repeat the "vector DEGRADED" log line without re-running arra_search mode=vector. The fix is cosmetic (rename [ChromaDB]→[Vector] labels, de-latch the warn); a real index rebuild is NOT warranted. #repo:arra-oracle-v3 #search #vector #brew-ops #false-alarm #lancedb #fts5

---
*Added via Oracle Learn*
