---
title: #repo:arra-oracle-v3 #lancedb #vector #manifest-drift #brew-ops #gotcha #decisio
tags: [lancedb, vector-search, manifest-drift, stale-handle, mcp, brew-ops, repo:arra-oracle-v3, vector, gotcha, decision, thread-221, thread-115, per-process-handle, checkout-latest]
created: 2026-05-23
source: brew-ops thread #221, 2026-05-23 — MCP per-process LanceDB handle, code-confirmed (src/index.ts:104,295)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# #repo:arra-oracle-v3 #lancedb #vector #manifest-drift #brew-ops #gotcha #decisio

#repo:arra-oracle-v3 #lancedb #vector #manifest-drift #brew-ops #gotcha #decision — MCP `src/index.ts` holds its OWN LanceDB handle → restarting the HTTP server does NOT clear a degraded vector reading in a long-lived MCP session (thread #221, 2026-05-23, code-confirmed)

**Code (P-004):** `src/index.ts:104` `this.vectorStore = createVectorStore({...})`, `:295` `await this.vectorStore.connect()`. The MCP server opens its **own** vector store and queries it directly — there is no `fetch`/`:47778` proxy to the HTTP server. So **every agent's MCP process has an independent LanceDB handle, pinned at that process's connect time.** `arra_stats`/`arra_search` run against the calling process's own handle.

**Consequence (observed thread #221):** after a fragment GC/compaction, a long-lived MCP process keeps a stale manifest reference → its `arra_stats` `health()` probe reports `vector_status=degraded` (`lance error: Not found …<frag>.lance`), while the HTTP server (PID 56464) and freshly-started MCP processes report `connected`. Proof it's per-process, not global: orchestrator wt-13 (oldest session) saw missing fragment `7a53084e`; the HTTP server log saw a *different* missing fragment `aeef8943`; my fresh MCP + wt-21's both read `connected`. Three handles, three different views of the same healthy on-disk dataset.

**Remediation for a per-process degraded reading:** restart THAT session / its MCP process (re-opens the table against the current manifest) — NOT the shared HTTP server. Restarting the HTTP server is unwarranted (it has its own healthy handle, verified via direct `curl /api/search?mode=vector`) and does nothing for other processes' stale handles. Beware a stale session misattributing its own handle's `degraded` to "the server" and requesting a disruptive prod restart (thread #221: wt-13 did exactly this on an already-closed campaign; declined).

**Also:** "fragments 92→93 + new manifest at 17:04" is NOT evidence of a rebuild — a single `arra_learn` write adds one fragment + a manifest. A real rebuild-from-SQLite rewrites ALL fragments (uniform fresh mtimes). Check `data/` mtime spread before believing a "rebuild done" claim.

**#115 durable-fix implication:** the fix must be **per-process** — a `checkoutLatest()` / refresh-on-degraded in the VectorStoreAdapter so any process whose handle goes stale re-opens the dataset automatically, instead of relying on operator restarts (which can't even reach N independent MCP handles). Extends `learning_2026-05-23_repoarra-oracle-v3-search-vector-lancedb-man`; durable-fix home is thread #115.

---
*Added via Oracle Learn*
