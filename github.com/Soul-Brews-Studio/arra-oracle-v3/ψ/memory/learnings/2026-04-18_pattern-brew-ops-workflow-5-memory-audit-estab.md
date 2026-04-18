---
title: Pattern — brew-ops workflow-5 (Memory Audit) established 2026-04-18 + baseline m
tags: [brew-ops, memory, audit, workflow, baseline, narrative-coherence, repo:arra-oracle-v3, pattern, decision]
created: 2026-04-18
source: 2026-04-18 brew-ops audit session creating workflow-5-memory-audit.md (16 steps, 680+ lines)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Pattern — brew-ops workflow-5 (Memory Audit) established 2026-04-18 + baseline m

Pattern — brew-ops workflow-5 (Memory Audit) established 2026-04-18 + baseline metrics captured

New workflow: `.agent/skills/brew-ops/references/workflow-5-memory-audit.md` — 16 steps, read-only, writes only `arra_learn` findings + `arra_handoff` if P0.

Scope split across two dimensions:
- **Structural health** (§1–§12): git sync, disk↔DB sync, FTS/vector integrity, path corruption, tag compliance, retro quality, cross-refs, supersede chains, trace chains, handoff inbox, arra_learn/indexer balance, duplicate-indexing tracking
- **Semantic health** (§13–§14): cross-agent signal extraction from retros; narrative coherence sampling (does memory tell a coherent story a fresh agent can follow?)

Known-good baseline (frozen into the workflow for calibration):
- 598 oracle_documents, 598 oracle_fts rows (ratio 1.000), 0 FTS orphans
- 444 learnings + 41 principles + 113 retro chunks (from 16 retro files)
- 16/16 retros have AI Diary + Honest Feedback
- 0 dangling supersedes, 0 active path corruption
- 72 `related:` cross-refs, 0 broken to existing files
- 13 traces, 4 with parent links, 6 with prev/next chains
- 24/88 learning files have both arra_learn root + indexer chunks (by design, not a bug)

Future audits should trend ±20% of these; sudden shifts warrant investigation.

Why workflow-5 was needed: prior sessions had ad-hoc quality checks but nothing periodic. First real audit (this one) caught 3 P0 issues:
- FTS bloat (2.83x ratio) — already fixed on branch `local/all-prs` commit 3c8f55b
- Vector search degraded — known LanceDB path drift (see learning `2026-04-14_arra-oracle-indexer-server-lancedb-drift`)
- Path corruption `bank-bot<` — see sibling learning from this same session

§14d (current-session capture check) is the workflow's own safety net against the worst failure mode: a session making durable changes without capturing them. This learning itself is an instance of that safety net firing — without it, today's work would be invisible to tomorrow's brew-ops.

How to run: cadence is weekly, on-request, or after major fleet/indexer changes. Takes ~15 min. Produces a markdown report with P0/P1/P2 findings + metrics snapshot + retro synthesis + coherence scores.

---
*Added via Oracle Learn*
