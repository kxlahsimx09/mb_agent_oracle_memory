---
title: Oracle Memory Audit run — 2026-05-16 (workflow-5, brew-ops, escalate via thread 
tags: []
created: 2026-05-16
source: brew-ops — workflow-5 audit 2026-05-16
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Oracle Memory Audit run — 2026-05-16 (workflow-5, brew-ops, escalate via thread 

Oracle Memory Audit run — 2026-05-16 (workflow-5, brew-ops, escalate via thread #109 / campaign #108)

**Vault:** commit `26de613` (20 uncommitted files). **Oracle DB:** 3620 docs / 920 source files, FTS orphans 0, vector=DEGRADED. **Trigger:** escalate — re-run after the stale 2026-05-09 audit whose P0 threads #86–89 sat undispatched 7 days.

## Summary
- **P0:** 2 — (1) 156 cross-repo orphan markers; (2) vector search fully degraded.
- **P1:** 1 — 9 stale handoffs >14d.
- **P2:** 2 — 22 pending handoffs (WARN band); 7/215 retros missing diary/feedback (3.3%).
- **PASS:** §2 FTS orphans 0; §4 path corruption 0; §8 supersede 0 dangling; §9 traces 226, 0 dangling; §11 arra_learn ratio 593/3620=16.4%; §13b no recurring real knowledge-gaps.

## P0-1 — §13c orphan markers: 156 across 3 repos (was "~30/~80/~14" on 05-09)
Fresh precise counts 2026-05-16:
- mobiz-payment-gateway: **51 orphan** markers (57 total − 6 valid: AT:14×2, AT:51, AT:58, AT:75×2). Threads closed 24–27.7d.
- mb-next-payment-gateway: **92 orphan** markers (all referenced threads 41–82 closed; 0 valid). Closed 7.9–27.7d.
- bank-bot: **13 orphan** markers (15 total − 2 valid: UNDOCUMENTED-STEP:50×2). Closed 17–26d.
All reference threads closed ≥7d → P0 per §13c matrix. The debt is the OLD cohort (threads ≤82); the 05-09 headline counts were rounded undercounts. mb-next genuinely grew ~+12 (threads #76–82 closed since). Reconciled into threads #86/#87/#88 (updated in place, kept pending).

## P0-2 — §3 vector search degraded (NEW)
HTTP + MCP vector search both return 0 results. `stats.vector` reports `enabled:true, count:3287` but a LanceDB data fragment is missing: `~/.arra-oracle-v2/lancedb/oracle_knowledge_bge_m3.lance/data/0111…aeef894314a6c87fb2e17445ad.lance — Not found`. System silently falls back to FTS5-only. Matches the §3 "HTTP empty + stats connected = P0 LanceDB path/data drift" pattern; cf. learning `2026-04-14_arra-oracle-indexer-server-lancedb-drift`. Not flagged on 05-09 → regressed/new this week.

## P1 — §10 stale handoffs: 9 >14d (was 4 at thread #89)
The 4 from #89 still present + 5 more aged in (04-27/04-28 cohort). 22 pending total. Reconciled into thread #89 (updated in place).

## Positive signal
Threads #90–107 (a full week of ADR/PoC/writer churn) closed cleanly and left **zero** orphan markers — write-time hygiene (W9 §4b, thread-resolve closing rule) is working on the active cohort. The 156-marker debt is entirely retroactive cleanup of the pre-#82 cohort, not a current-cadence failure.

## Reconciliation of stale 05-09 P0 threads
#86/#87/#88/#89 updated in place with fresh 2026-05-16 counts (chose update-in-place over supersede — threads still `pending`, structurally sound, P-001-clean to append). Orchestrator (#108) fans out cleanup dispatch from the refreshed numbers.

Tags: #brew-ops #repo:cross #memory #audit #2026-05-16 #workflow-5 #orphan-markers #vector-drift #stale-handoffs #P0

---
*Added via Oracle Learn*
