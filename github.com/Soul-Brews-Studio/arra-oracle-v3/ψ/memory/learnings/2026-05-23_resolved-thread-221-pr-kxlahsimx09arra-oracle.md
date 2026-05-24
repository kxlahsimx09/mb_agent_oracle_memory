---
title: RESOLVED (thread #221, PR kxlahsimx09/arra-oracle-v3#89): the two operational ga
tags: [brew-ops, repo:arra-oracle-v3, indexer, vault, drift, decision, thread-221]
created: 2026-05-23
source: arra_learn from github.com/Soul-Brews-Studio/arra-oracle-v3 thread-221 brew-ops
project: github.com/soul-brews-studio/arra-oracle-v3
---

# RESOLVED (thread #221, PR kxlahsimx09/arra-oracle-v3#89): the two operational ga

RESOLVED (thread #221, PR kxlahsimx09/arra-oracle-v3#89): the two operational gaps from thread #219 (filed in 2026-05-23_two-operational-gaps-found-during-the-thread-219).

C — `_universal/` index-blind on rebuild: FIXED. `discoverProjectPsiDirs` (src/indexer/discovery.ts) scanned only `{host}/{org}/{repo}/ψ` host dirs, never `_universal/ψ` — but arra_learn writes project-less learnings to `<vault>/_universal/ψ` (`projectDir = project || '_universal'`). Those files were index-only; a from-scratch batch rebuild silently dropped them (incl. the 5 orchestrator-pattern 2026-05-21 learnings). Fix: discoverProjectPsiDirs now also returns `<repoRoot>/_universal/ψ` when present. The parser already yields `project: null` for those paths, so no parser change. Verified against the live vault — 12 `_universal` learnings now discovered (was 0 via the batch reindexer). New test: src/indexer/__tests__/discovery.test.ts.

D — `arra_learn(project=…)` → `_universal/` fallback was STALE-SERVER, NOT code. In current source (391420e) normalizeProject resolves `github.com/Soul-Brews-Studio/arra-oracle-v3` and KNOWN_PROJECTS (landed aa4d681, 2026-04-21) whitelists it, so handleLearn writes project-first WITH the `project:` frontmatter line. The wt-17 observation of a silent _universal/ fallback was the 6-day-stale running server (PID 5859, up since May 17; Bun does not hot-reload src/). Restart deploys the fix — no D code change. Added a restart-after-deploy note to docs/LOCAL-DEV.md.

Operating rule: after every deploy, restart the oracle HTTP/MCP server (stop → bun run src/server.ts) — a long-running Bun process serves whatever source it booted with, so on-the-wire arra_* behaviour silently lags the deployed source-of-truth (feat/all-prs-rebased). Restart of src/server.ts is gated on the user merging PR #89.

---
*Added via Oracle Learn*
