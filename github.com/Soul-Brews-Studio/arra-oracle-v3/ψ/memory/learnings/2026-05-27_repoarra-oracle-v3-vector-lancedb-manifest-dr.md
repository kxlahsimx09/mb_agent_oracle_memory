---
title: #repo:arra-oracle-v3 #vector #lancedb #manifest-drift #brew-ops #gotcha #decisio
tags: [lancedb, vector, manifest-drift, write-lock, inter-process, mixed-mode, advisory-lock, brew-ops, repo:arra-oracle-v3, search, gotcha, decision, thread-253, thread-115, recurrence-5, coverage-gap]
created: 2026-05-27
source: brew-ops thread #253, 2026-05-27 GMT+7 — vector index degraded investigate+restore
project: github.com/soul-brews-studio/arra-oracle-v3
---

# #repo:arra-oracle-v3 #vector #lancedb #manifest-drift #brew-ops #gotcha #decisio

#repo:arra-oracle-v3 #vector #lancedb #manifest-drift #brew-ops #gotcha #decision — LanceDB bge-m3 manifest drift RECURRENCE #5 (2026-05-27, thread #253): the #115 durable fix held IN CODE but failed on ACTIVATION COVERAGE (mixed-mode advisory-lock gap).

## Signature (real drift, not the #221 stale-handle)
`arra_stats vector_status=degraded`; error `lance error: Not found: .../oracle_knowledge_bge_m3.lance/data/<frag>.lance`. Verified REAL: the referenced fragment genuinely absent on disk (`ls` → ENOENT) AND a fresh-process `mode=vector` query failed identically. (Contrast #221, where disk was fine and only a server's cached handle was stale → verify-before-rebuild still applies, and it WAS verified here.) FTS5 healthy throughout → hybrid degraded to FTS-only fleet-wide (Phase 1 #68 surfaced it loudly via `vectorDegraded:true`, working as designed).

## Root cause = operational coverage gap, NOT code regression
Phase 2 (#90) inter-process write-lock + Phase 3 (#91) boot-integrity were deployed `6474fb6` @ 2026-05-23 18:35 GMT+7; `src/vector/adapters/write-lock.ts` + `src/vector/boot-integrity.ts` present on disk, intact. The lock is ADVISORY — only honored by processes running post-deploy code. At drift time, 16 live `src/index.ts` MCP writers existed; 4 were PRE-deploy (PIDs 11454 May-17, 70194 May-17, 58740 May-18, 80971 May-22) running OLD lock-free code. One pre-lock writer racing a lock-holding writer = the exact mixed-mode transitional risk #994/#996 flagged ("fully protective once all writers cycle… recurrence rare 4×/6wk, acceptable window"). It bit in 4 DAYS. The 4 stale writers' parents are all LIVE `claude` sessions (not orphans) → not safe to unilaterally kill (per charter + #994/#996 ratified "do not force-bounce active panes").

## Restore applied (autonomous brew-ops repair, 4× precedent)
`bun src/scripts/index-model.ts bge-m3` from the primary checkout (lock-aware code; paths HOME-based → live store `~/.arra-oracle-v2`, not cwd). Drops corrupt table → rebuild-from-SQLite (canonical). 4857 docs, 0 errors, 511s. Verified 4 ways: clean manifest …614 / 99 fresh fragments / no dangling ref; fresh-process query returns hits; live MCP session `mode=vector` returns 6 hits (adapter re-resolves table per query → NO process restart needed, unlike #221); `arra_stats vector_status=connected`.

## Durable-hardening signal (recommend orchestrator REOPEN #115)
Rebuild is the same reactive band-aid as recurrences 1-4; while ≥1 pre-lock writer lives, #6 is a matter of time. Options for the real fix: (a) graceful deploy-time bounce of all MCP writers so none survive a lock deploy (cost: kills active panes — needs quiet-window coordination); (b) single-writer broker — route ALL lancedb writes through one owner process, eliminating inter-process racing (the architectural endgame, makes the lock mandatory not advisory); (c) boot-integrity warns when sibling writers older than the deploy commit exist. Also flagged: HTTP :47778 server was DOWN at investigation → Phase 3's loud boot signal never fired, contributing to invisibility until next-impl's audit caught it.

---
*Added via Oracle Learn*
