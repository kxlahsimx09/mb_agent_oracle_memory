---
title: **Two operational gaps found during the thread-219 reindex (2026-05-23), both ab
tags: []
created: 2026-05-23
source: brew-ops thread #219 — full reindex + vault↔index reconciliation
---

# **Two operational gaps found during the thread-219 reindex (2026-05-23), both ab

**Two operational gaps found during the thread-219 reindex (2026-05-23), both about the index drifting from a from-scratch rebuild:**

**(1) `_universal/` is NOT scanned by the batch reindexer.** `arra_learn` writes to `<vault>/<projectDir>/ψ/memory/learnings/` where `projectDir = (resolvedProject || '_universal')` (`src/tools/learn.ts:528`). But the batch indexer only scans the root `ψ/memory/learnings/` + project-first host dirs via `discoverProjectPsiDirs` (github.com/gitlab.com/bitbucket.org only — `src/indexer/discovery.ts:13-38`). It does **not** scan top-level `_universal/`. So any learning that lands in `_universal/` is **index-only** — present solely because `arra_learn` live-indexed it at write time; a from-scratch `bun src/indexer/cli.ts` would NOT recover it. 2026-05-23 state: 11 learnings on disk in `_universal/`, 8 indexed (7 real, incl. 5 orchestrator-pattern learnings from 2026-05-21 + this investigation's own), 4 test-pattern junk unindexed. These show up as "orphans" in any file-vs-index reconciliation.

**(2) A learning's `project` can silently fail to resolve → falls back to `_universal/`.** `project = normalizeProject(projectInput) || extractProjectFromSource(source) || detectProject(ctx.repoRoot)` (`learn.ts:515`). When all three return null (project arg not forwarded by the MCP transport / not in the running server's tool schema / server cwd not a known repo), the write silently lands in `_universal/` with NO `project:` frontmatter — even though the caller passed `project=...`. Observed live 2026-05-23: an `arra_learn(project=github.com/Soul-Brews-Studio/arra-oracle-v3)` call wrote to `_universal/ψ/memory/learnings/...` with no project frontmatter.

**Likely contributor: the live oracle HTTP server is a stale long-running process.** `bun src/server.ts` (PID 5859, serving :47778) had been running since **May 17** at the time of this session (6 days), and a sibling `bun src/index.ts` MCP process also dated May 17 — while HEAD was `391420e` (post-May-17 merges). A bun server process does NOT hot-reload its source (no `--watch`), so arra_* behavior on the wire can lag the deploy source-of-truth (§3c-class runtime/source drift). **Operational follow-up (needs human/orchestrator ratification — disruptive): restart the oracle server so it runs current `src/index.ts`, after confirming no in-flight writes.** Do NOT restart unilaterally; it interrupts the fleet (inbox-watcher consumers, MCP sessions, studio). See [[2026-05-23_arralearn-with-a-project-writes-the-learning]] for the project-first path + casing-orphan companion findings.</pattern>
<parameter name="concepts">["indexer", "vault", "reindex", "_universal", "arra_learn", "drift", "stale-server", "runtime-drift", "brew-ops", "repo:arra-oracle-v3", "memory-pipeline", "discoverProjectPsiDirs", "operational"]

---
*Added via Oracle Learn*
