---
title: LanceDB manifest-drift durable fix — Phase 2 (inter-process write lock) shipped 
tags: [lancedb, vector, manifest-drift, write-lock, inter-process, decision, drift, brew-ops, repo:arra-oracle-v3, search, thread-115, pending-soak]
created: 2026-05-23
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# LanceDB manifest-drift durable fix — Phase 2 (inter-process write lock) shipped 

LanceDB manifest-drift durable fix — Phase 2 (inter-process write lock) shipped as fork PR #90, PENDING merge + soak.

Context: `@lancedb/lancedb@0.27.2` has no cross-process write lock. Root cause of the recurring manifest drift (4 occurrences: 2026-04-14 / 04-21 / 05-16 / 05-23) is N writers in SEPARATE processes (HTTP server + MCP instances + indexer) sharing one lancedb dir racing a manifest — a writer commits a manifest version that references a data fragment another writer hasn't flushed; every vector query then hits the broken manifest and silently falls back to FTS5. Phase 1 (#68, merged) made it LOUD (in-process writeChain mutex + health() probe + vectorDegraded surfacing) but an in-process mutex structurally cannot cover the inter-process race.

Phase 2 (fork PR #90, base feat/all-prs-rebased): new `src/vector/adapters/write-lock.ts` — a file-based inter-process advisory lock (atomic mkdir token + {pid,host,token,acquiredAt,op} owner descriptor). Held in LanceDBAdapter around every manifest-mutating op: table.add, createTable, dropTable. Reads stay lock-free. Embedding runs OUTSIDE the lock (slow + read-only). Keyed per-collection beside the lancedb dir (`${dbPath}.write-locks/<collection>.lock`) so bge-m3/qwen3 writes don't block each other. Bounded timeoutMs (15s default) + jittered backoff: on timeout the writer fails loud and degrades to FTS5 (tools/learn.ts + indexer/storage.ts already catch a write rejection and keep the canonical SQLite/FTS row) — no HTTP-path deadlock. Stale locks (dead holder pid via process.kill(pid,0), or held past staleMs=30s) reclaimed via atomic rename so only one waiter wins the steal; release is token-guarded so a stolen lock is never deleted by its predecessor. Same-host by design (one node, AGENTS §11a).

Operational note (P-002/P-003): do NOT reactively rebuild on a `vector_status=degraded` signal if vector queries are still functional (verify with mode=vector → real matches, 0 FTS fallback) — a reactive rebuild races the live writers, which is the hazard itself. The degraded signal is Phase 1 working. Reactive rebuild only when queries actually fail.

Phase 3 (separate, NOT yet opened): wire health() into server/MCP boot as an integrity check that NAMES the rebuild command — NO auto-rebuild (P-003, operator-invoked; ~7min would block startup + race writers).

Effectiveness is UNVERIFIED until #90 merges + soaks under real concurrent writers. Tracked on thread #115 (msgs 277/285/990/991).

---
*Added via Oracle Learn*
