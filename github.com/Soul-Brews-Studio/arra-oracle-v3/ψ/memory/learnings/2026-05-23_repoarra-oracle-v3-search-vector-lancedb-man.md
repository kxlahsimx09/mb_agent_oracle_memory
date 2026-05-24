---
title: #repo:arra-oracle-v3 #search #vector #lancedb #manifest-drift #brew-ops #gotcha 
tags: [lancedb, vector-search, manifest-drift, stale-handle, brew-ops, repo:arra-oracle-v3, search, vector, gotcha, decision, thread-221, thread-115, verify-before-rebuild, p0]
created: 2026-05-23
source: brew-ops thread #221, 2026-05-23 — vector repair consult, verified-healthy verdict
project: github.com/soul-brews-studio/arra-oracle-v3
---

# #repo:arra-oracle-v3 #search #vector #lancedb #manifest-drift #brew-ops #gotcha 

#repo:arra-oracle-v3 #search #vector #lancedb #manifest-drift #brew-ops #gotcha #decision — LanceDB "fragment not found" is often a PER-PROCESS stale handle that self-heals — VERIFY before rebuilding (thread #221, 2026-05-23)

**Symptom:** orchestrator restarted the oracle server (PID 56464), then `arra_stats` reported `vector_status=degraded` with `lance error: Not found …oracle_knowledge_bge_m3.lance/data/…7a53084e….lance`, "persists 2 reads." Consult dispatched to brew-ops to backup→quiesce→rebuild the vector index (the #219 ~18min method).

**What was actually true (verified ~17:00 GMT+7, P-004):** vector was ALREADY healthy. Evidence:
- `arra_stats` `vector_status: connected` across 3 reads (post-#113/PR#68 this is a live server-side `health()` query probe, not a connect-time snapshot).
- `mode=vector` MCP search returned real bge-m3 results 3×; `mode=hybrid` 1× — all <150ms, no FTS fallback.
- Direct `curl /api/search?mode=vector&model=bge-m3` on the SHARED server (PID 56464) returned vector results — proves the shared path, not just my MCP process.
- On disk: cited fragment `7a53084e` is GONE from `data/` AND unreferenced by the current manifest (92 fragments, newest manifest 13:45 GMT+7, self-consistent). No writes since 15:46 (last_indexed) — quiescent + stable.
- Server log `~/.cache/soul-brews-startup/oracle-http.log` had EXACTLY ONE vector error, citing a DIFFERENT fragment (`…aeef8943…`) than the orchestrator saw (`7a53084e`), then recovered → tail shows successful scored vector results.

**Mechanism (the tell):** different processes citing different missing fragments = per-process stale dataset handles, NOT global on-disk corruption. After a fragment GC/compaction (the 13:44–13:45 manifest burst), each long-lived process (orchestrator's MCP session; HTTP server) briefly referenced a since-removed fragment from its pinned manifest version, then self-cleared on lazy handle refresh. Same class as the 2026-04-21 finding ("manifest vN referenced ~14 fragments GC'd by a parallel writer; no file lock in @lancedb/lancedb@0.27.2").

**Decision: did NOT rebuild.** A full vector rebuild on a HEALTHY index, racing the ~17 live `bun src/index.ts` MCP writers + HTTP server that all share one lancedb dir, IS the #115 concurrent-writer hazard — not its fix. "Quiesce writers" is infeasible without killing every agent pane. Reactive rebuild would risk causing the very drift it claims to repair.

**Lessons:**
1. Before any disruptive LanceDB rebuild, VERIFY current reality: fresh `arra_stats` + a real `mode=vector` query + `curl /api/search` on the shared server + on-disk fragment/manifest check + grep the server log for the LAST error timestamp. The premise of a stale degraded report may no longer hold.
2. A degraded read in ONE long-lived session (esp. one that pinned a pre-compaction manifest) ≠ global corruption. Have that session re-probe from a fresh handle first.
3. The durable fix is #115 Phase 2 (inter-process file-based advisory write lock) + Phase 3 (wire `health()` into MCP boot integrity check) — both still deferred. This is ~the 4th symptom occurrence; one-off rebuilds keep not holding (P-002). Dispatch #115, not another rebuild.

---
*Added via Oracle Learn*
