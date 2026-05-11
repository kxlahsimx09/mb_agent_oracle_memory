---
title: Oracle Memory Audit run — 2026-05-09 17:56 GMT+7 (workflow-5, brew-ops, ad-hoc)
tags: [brew-ops, memory, audit, 2026-05-09, workflow-5, P-001, tag-compliance-regression, orphan-markers, stale-handoffs, ad-hoc]
created: 2026-05-09
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Oracle Memory Audit run — 2026-05-09 17:56 GMT+7 (workflow-5, brew-ops, ad-hoc)

Oracle Memory Audit run — 2026-05-09 17:56 GMT+7 (workflow-5, brew-ops, ad-hoc)

**Vault**: commit `2a0ad2b` on `main` (0/0 vs origin/main, 1 untracked handoff). **DB**: 3262 docs / 3262 FTS rows / 0 orphans / vector=connected (bge-m3, 3262 collection count). **Baseline 2026-04-18**: 598 docs → +446% growth in 21d (mostly W1/W9 pass learnings).

## Severity summary
- **P0**: 2 — orphan markers (100+ across 3 repos), stale handoffs (4 >14d)
- **P1**: 3 — tag compliance regression, missing-disk active row, dup-index ratio
- **P2**: 4 — retro quality, cross-ref freeform drift, trace distillation debt, recall-issue gap
- **PASS**: 7 — supersede chain (0 dangling), path corruption (0 active), vector health, FTS ratio 1.000, principle grounding (P-001..P-004 all present), session capture (no uncaptured changes), §13b real-gaps (0 confirmed)

## P0 findings

1. **Cross-repo orphan markers (§13c)** — 100+ `[AWAITING_THREAD:N]` / `[RATIFICATION_PENDING:N]` markers in mobiz-payment-gateway/docs (~50), mb-next-payment-gateway/docs (~80), bank-bot/docs (~14) reference threads CLOSED 1.2–21d ago. Worst clusters: mb-next-pg has 9× RP:60 + 8× RP:61 + 7× RP:55 (ADR ratification markers; threads closed 6.3–10.2d by claude); mobiz-pg has 4× AT:16 + 4× AT:15 + 3× RP:19/AT:19 + 2× RP:11/12/13 from threads closed 17–21d ago. Pattern: agent W9/Step-4b sweeps not running on these territories OR closing-without-fix anti-pattern (last_role=claude on most). Action: route via arra_thread to technical-writer (mobiz-pg) + implementation-architect (mb-next-pg) for strip passes.

2. **Stale handoffs >14d (§10)** — 4 stale: 3× brew-ops self-handoffs (2026-04-21/22 pre-existing-double-wrap-cleanup, verify-legacy-name-format, workflow-gaps-memory-drift) + 1× architect handoff (2026-04-24 cross-role-drift + ADR-8 ratified). Inbox watcher should pick these up.

## P1 findings

3. **Tag compliance regression (§5)** — `missing_repo` 19.2% (FAIL >10%, baseline ~5%); `missing_role` 5.7% (WARN). Mostly pg-writer's 2026-04-27 flow-track / payout / drift learnings (mobiz-pg) — rich domain tags (flow-track, pointer-refresh, payout-controller) but dropped `repo:mobiz-payment-gateway` + role tags. Plus 5 w2/w9 retros from 2026-05-02 with no tags at all (`05.30_w2-extend-pr359-slip-fraud-v1-8b94f05.md`, `05.50_w9-extend-pr363-flow-track-slip-fraud-v1-8b94f05.md`, `00.13/00.18/14.30_*`). 

4. **Active arra_learn row missing on disk (§0.5/§11)** — `_universal/ψ/memory/learnings/2026-04-22_brew-ops-gap-2-backfill-audit-2026-04-22-40-late.md` (active, not superseded). 4 other missing files are properly superseded path-corruption rows (P-001 ok).

5. **Duplicate-indexing ratio (§12)** — 70.8% of learning files have both root + chunks (WARN >60%). arra_learn entries trending larger; consider smaller atomic learnings.

## P2 findings

6. **Retro quality (§6)** — 2.5% (5/202) missing diary/feedback. Worst: 3× from 2026-04/27 (w1-tester-validate-3b629e9, w2-backlog-7557402, bot-track-b74e745).
7. **Cross-ref drift (§7)** — 15.1% broken, but ~all are freeform prose entries in `related:` from May brew-ops retros (e.g. "2026-05-03 retro 14.04 (Phase 2a inbox-watcher merged...)"). Discipline drift, not P-001 risk.
8. **Trace distillation debt (§9)** — 100% of 208 traces are `status=raw`; 51% (106) >14d old. No traces have ever been distilled.
9. **Recall-issue (§13b)** — query "deposit expires_at check matcher race opportunistic" returned 0; simpler "deposit expires_at matcher" surfaces ADR-4c content. FTS5 multi-keyword combination edge.

## Recommendations (ordered)

1. arra_thread to technical-writer (mobiz-pg orphan markers) + implementation-architect (mb-next-pg ADR ratification markers) for strip passes — this is the largest health regression.
2. arra_thread to pg-writer reminding of 3-layer tag discipline; sample non-compliant filenames in body.
3. Process or close the 4 stale brew-ops/architect handoffs from 2026-04-21..24.
4. Investigate _universal/ψ/memory/learnings/2026-04-22_brew-ops-gap-2-backfill-... — file deleted but row not superseded.
5. Telegram §17: Sent via mcp__brew-ops-telegram__telegram_send; message_id captured below.

---
*Added via Oracle Learn*
