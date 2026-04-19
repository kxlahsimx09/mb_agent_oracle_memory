---
title: Audit run (2026-04-18 16:19 GMT+7) — brew-ops workflow-5 memory audit, second li
tags: [brew-ops, memory, audit, workflow-5, vector-embedding, supersede-indexer-gap, narrative-coherence, repo:cross, 2026-04-18]
created: 2026-04-18
source: 2026-04-18 16:19 GMT+7 brew-ops workflow-5 audit, vault commit 9ae00f5
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Audit run (2026-04-18 16:19 GMT+7) — brew-ops workflow-5 memory audit, second li

Audit run (2026-04-18 16:19 GMT+7) — brew-ops workflow-5 memory audit, second live run since workflow establishment that morning.

## What I observed (not what should happen)

- **Oracle DB:** 655 docs / 655 FTS rows / 0 orphans / ratio 1.000. Grew +9.5% over the 2026-04-18 07:48 baseline (598 → 655). Vector HTTP and MCP both return matches.
- **Vault git:** `main` at `9ae00f5`, synced with origin. 2 untracked learnings pending propagation (bot-writer + pg-writer owned).
- **Preflight §0.5 fired:** 4 unindexed files on disk, user chose continue-with-drift; likely residue of the `Soul-Brews-Studio` vs `soul-brews-studio` case-rename that's still mid-cutover per learning `2026-04-18_decision-normalize-vault-dir`.
- **Tag compliance (§5):** no_tags 0.0%, missing_repo 3.9%, missing_role 2.3% — all inside PASS bands.
- **Retro quality (§6):** 20/20 have AI Diary + Honest Feedback.
- **Supersede chain (§8):** 0 dangling, 0 orphan log entries, 14 total supersedes — clean.
- **Trace chain (§9):** 18 traces, 15 linked, 0 dangling parents, 0 raw >14d.

## Patterns that emerged (not recommendations)

1. **Vector-embedding failures clustered on structured markdown.** Two retros (07.48_bot-baseline-7d4b50e, 16.58_bot-baseline-95dbb70) report `embedding: "failed"` on decision learnings. §13b independently found 4× vector searches for "SCB approver matching …" returning 0 despite content existing in 5 vault files. Same root cause: those docs are in FTS but missing from vector store. This is the pattern; whoever investigates next will confirm or deny it on the Oracle server embedding pipeline.
2. **arra_supersede cannot run on a not-yet-indexed newId, and there is no MCP reindex trigger.** Retro 17.00_workflow-4-first-live-run documents: 60 s wait + `touch` did not trigger reindex; `/api/reindex` and `/api/scan` return 404. Workflow-4 deferred the supersede as a follow-up. The workflow-5 §16 "do not run the indexer" rule correctly isolates the drift — the fix lives outside this workflow.
3. **Title truncation at 80-char basename.** Vault-case-rename thread (Thread 2 in §14) has 2/3 files with mid-word title truncation ("Verifying that arra_learn n", "vault directory case to GitHub canonica"). §14 dimension "Title integrity" scored this thread Fragmented (3/6), though structural data (chain integrity, source citation) all passed.
4. **The audit is doing its job.** §13 and §13b found the same vector issue from two independent angles (retro narrative + search_log demand). That's the intended §13b pattern — demand-side signal complementing supply-side synthesis.

## Deltas vs first audit (2026-04-18 07:48)

| Metric | First audit | This audit | Δ |
|---|---|---|---|
| Total docs | 598 | 655 | +57 |
| Retros (files) | 16 | 20 | +4 |
| arra_learn rows | 45 | 58 | +13 |
| Vector HTTP matches | 598 | 647 | +49 |
| Uncommitted vault files | 0 | 2 | +2 |
| Broken cross-refs | 0 | 3 | +3 |
| Knowledge gaps (recurring) | n/a | 2 recall-issues | n/a |

Cross-reference breakage appeared in the 10-hour gap — likely from the new learnings referencing slugs that got renamed or haven't been written yet. Not an audit finding; just a number to watch next run.

## How to apply

Future workflow-5 runs should re-check items 1–2 first: if the vector-embedding failure cluster persists, it warrants its own trace (Workflow 2). If `arra_reindex` still doesn't exist as an MCP tool, the §13 synthesis will keep surfacing it until someone implements it or explicitly rejects it. The audit is read-only by design — the finding is the output, not the fix.

Tags: brew-ops, repo:cross, memory, audit, workflow-5, vector-embedding, supersede-indexer-gap, vault-case-rename, narrative-coherence

---
*Added via Oracle Learn*
