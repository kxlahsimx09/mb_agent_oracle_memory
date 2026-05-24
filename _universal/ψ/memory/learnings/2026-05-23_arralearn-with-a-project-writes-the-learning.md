---
title: **arra_learn with a `project` writes the learning .md to the VAULT repo's projec
tags: [indexer, vault, project-first-path, arra_learn, drift, gotcha, fts5, vector, reindex, brew-ops, repo:arra-oracle-v3, memory-pipeline, smart-delete, case-insensitive]
created: 2026-05-23
source: brew-ops thread #219 — full reindex + vault↔index reconciliation
---

# **arra_learn with a `project` writes the learning .md to the VAULT repo's projec

**arra_learn with a `project` writes the learning .md to the VAULT repo's project-first path — NOT the universal ψ/ dir nor the product repo's own ψ/.** A learning tagged `project: github.com/kokarat/mobiz-payment-gateway` lands at `<vault-repo>/github.com/kokarat/mobiz-payment-gateway/ψ/memory/learnings/<slug>.md`, where `<vault-repo>` = `mb_agent_oracle_memory` (resolved via `ghq` from the `vault_repo` setting). It does NOT land in `~/.arra-oracle-v2/ψ/memory/learnings/` (universal) nor in the kokarat/mobiz product repo's own `ψ/`.

**RECON TRAP (thread #219, 2026-05-23):** wt-13 orchestrator declared wt-17's `2026-05-23_same-amount-fifo-matching-gap-in-transactionmat` "not findable AND not on disk in any canonical vault path" → suspected lost/never-persisted. FALSE ALARM: the file was on disk at the project-first path (mtime 09:28 GMT+7, hours before the 13:13 check) and indexed the whole time. The recon only checked the universal `ψ/memory/learnings/` + the product repo's `ψ/`, and a `find ~` that missed it (likely ψ-char/glob quoting). **Lesson:** to confirm a learning's on-disk presence, search the VAULT repo recursively (`find <vault> -path '*/memory/learnings/*<slug>*'`) or just `arra_search mode=fts query=<slug>` — never conclude "lost" from the universal dir alone.

**Indexer model:** `src/indexer/collectors.ts` scans BOTH the root `ψ/memory/learnings` AND project-first dirs via `discoverProjectPsiDirs` (github.com/gitlab.com/bitbucket.org → <org>/<repo>/ψ). It does NOT scan a top-level `_universal/ψ/` dir — files there are indexed only if arra_learn wrote a row at creation time. `arra_stats` counts CHUNKS, not files (one .md → multiple FTS chunks; ~3.5 avg). 2026-05-23 disk truth: 776 learning files (94 universal + 672 project-first + 10 _universal), 258 retros, 4 principle/resonance.

**CASING-ORPHAN DRIFT (flagged, not fixed):** `inferProjectFromPath` lowercases project paths (`src/indexer/discovery.ts:51,59`), but `source_file` is stored from `path.relative` (actual disk case, e.g. `github.com/Soul-Brews-Studio/...`). On case-insensitive macOS, the indexer's smart-delete `fs.existsSync(repoRoot + source_file)` returns true for stale lowercase-cased rows → a full reindex reports `Smart delete: 0` and never prunes them. After the 2026-05-23 reindex ~110 orphan/duplicate rows persist (lowercase twins, `kokarat/kokarat`, `cbank-bot`, a stray `<`, `_universal/` arra_learn rows); `oracle_documents`=4293 > current FTS chunk set=3575. Low-harm (possible duplicate search hits) but inflates counts. Recommended follow-up: a case-normalizing index-prune (index rows are derived & prunable; vault .md files are sacred per P-001).</pattern>
<parameter name="project">github.com/Soul-Brews-Studio/arra-oracle-v3

---
*Added via Oracle Learn*
