---
title: Orchestrator aggregation must verify work COMPLETENESS against the task's measur
tags: [orchestrator, aggregation, verification, completeness, coverage, under-scope, diff-size-signal, P-004, cleanup-requirements]
created: 2026-05-22
source: orchestrator wt-15 campaign-215 (next-writer W2-cleanup RE-OPEN aggregation)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Orchestrator aggregation must verify work COMPLETENESS against the task's measur

Orchestrator aggregation must verify work COMPLETENESS against the task's measurable target — not just that the PRs exist.

INCIDENT (2026-05-22, campaign #215, W2 cleanup-requirements → next-writer): next-writer reported the pass "COMPLETE" with 3 PRs. Orchestrator (msg 940) verified the PRs EXISTED (open, base main, one file each, AC counts) and relayed "pass complete" to the user. But the pass had only touched DEPOSIT-007's intro+journey (9 lines) + 4 payout lines — ~1-2% of the task. Step-3c's own spec says "walk EVERY story body top-to-bottom." The **user** caught the under-scoping by counting residual engineering-jargon in story bodies (deposit 252, payout 98, wallet 33, match 11 — all AFTER the PRs). Re-dispatch (msg 941) → full pass → jargon 252/98/33/11 → 0 across all 4 epics (PRs #228/#229/#232/#234; #227 merged).

ROOT CAUSE: "PR exists + diff is non-empty + ACs unchanged" is necessary but NOT sufficient. It confirms the work is well-FORMED, not that it COVERS the task. A worker can do high-quality work on 2% of the scope and honestly believe it's done.

RULE for orchestrator aggregation (P-002, P-004): when the dispatched task has a MEASURABLE completion target (here: body-jargon → ~0; or N files, N stories, a coverage %), the aggregator must sanity-check COVERAGE against that target before relaying "complete" to the user — not just PR existence. Cheap checks that would have caught it: diff SIZE vs scope (the first pass was +9/-9 + +4/-4 on 659+589-line files — visibly ~1% touched; the real pass was +170/-170 + +101/-101), or a quick grep for the target token-class across the supposedly-cleaned files. A 2-line diff on a "clean the whole file" task is a red flag, not a green check.

SECONDARY (label drift): the worker reused "ACs byte-verbatim" across both passes, but it meant different things — pass 1 left AC text literally untouched; pass 2 REWORDS AC text (demoting jargon) while preserving meaning + asserted values. "byte-verbatim" was accurate for pass 1, misleading for pass 2 ("89=89" = AC count + meaning preserved, not byte-identical). Aggregator should disambiguate count-preserved vs text-preserved when relaying to a human who will merge.

#repo:cross #fleet #mcp-tools #decision #gotcha #handoff #brew-ops

---
*Added via Oracle Learn*
