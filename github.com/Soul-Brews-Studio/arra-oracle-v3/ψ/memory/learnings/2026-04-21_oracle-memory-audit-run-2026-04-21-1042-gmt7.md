---
title: Oracle Memory Audit run — 2026-04-21 10:42 GMT+7 (workflow-5, brew-ops, ad-hoc)
tags: [brew-ops, memory, audit, workflow-5, 2026-04-21, vector-degraded, path-corruption-recurrence, cross-ref-regression, repo:cross, P0]
created: 2026-04-21
source: brew-ops session 2026-04-21 10:42 GMT+7 — workflow-5-memory-audit ad-hoc full run; baseline = 2026-04-20 11:50 GMT+7
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Oracle Memory Audit run — 2026-04-21 10:42 GMT+7 (workflow-5, brew-ops, ad-hoc)

Oracle Memory Audit run — 2026-04-21 10:42 GMT+7 (workflow-5, brew-ops, ad-hoc)

**Vault:** commit `242eb14` on `main` (clean). **DB:** 1256 docs / 319 unique files / FTS=1256 (ratio 1.000, 0 orphans). **Trigger:** ad-hoc operator request.

## P0 findings

1. **Vector search returning 0 hits across all queries.** HTTP `mode=vector&model=bge-m3` and MCP `arra_search mode=vector` both return 0 for any query. Stats reports `vector.enabled=true`, `oracle_knowledge_bge_m3` collection has 1171 entries, Ollama up with `bge-m3:latest`, LanceDB dir present. Backend healthy → query path broken. §13b cross-evidence: 11/21 zero-result searches in past 14d are vector-mode — users hitting this. Fix: see learning `2026-04-14_arra-oracle-indexer-server-lancedb-drift`. Suggested action: bisect commits since 2026-04-18 (when 598 vector hits worked).

2. **Path corruption recurred.** 1 active row `</ψ/memory/learnings/2026-04-19_flow-scb-dual-control-withdrawal-intent-at-a-g_0` with `project=github.com/kokarat/bank-bot<` (literal `<`). Same pattern as 2026-04-18 fix — parent doc was superseded but chunk row survived. Need chunk-id sweep this time.

## P1 findings

3. **Cross-reference validity regressed to 6.1% broken** (7/115). Notable cluster: `2026-04-21_drift-deposit-auto-expire-pending-pointer-accuracy*` references 3 truncated/missing filenames. Owning agent (pg-writer) should fix or supersede.

## P2 findings

4. 2/304 retros lack tags (`bot-track-*` from bot-writer).
5. 1/53 retros missing diary/feedback (`06.13_w2-track-commit-dispatcher-maintenance.md`).
6. Duplicate-indexing trending up: 152/265 learnings (57.4%) have both root+chunks — was 27% on 2026-04-18. At edge of WARN bracket.

## PASS sections

§0 principles (4/4), §0.5 preflight (3 unindexed retros within tolerance), §1 git, §2 disk/db, §6 retro quality, §8 supersede (0 dangling), §9 traces, §10 handoffs (0 stale >14d), §11 arra_learn ratio (15.1%), §13c orphan markers (0 across 24 closed threads — Step 4b sibling-syncing working), §14d session capture (17 writes / 23 commits = 74%).

## Knowledge gaps (§13b)

5 recurring recall-issues (long hybrid queries miss FTS tokenization): withdrawal-dispatcher-bank-rotation, dispatcher-withdrawal-queue-FIFO, waiting_to_review-bankTransactionId, bank-bot-scb-maker-IBFT, mobiz-payment-gateway-overview. Content exists; needs synonym bridges.

## Narrative coherence

3 clusters sampled. `withdrawal-queue-dispatch-and-claim`: Excellent (6 files, ratify→revision→re-ratify chain via threads #12+#29). `deposit-auto-expire-pending`: Good (5 files, broken refs noted). `scb-dual-control-withdrawal`: Fragmented (corrupt path-bot< blocks one source_file pointer).

## Telegram §17

Sent via `mcp__brew-ops-telegram__telegram_send`; message_id captured below.

---
*Added via Oracle Learn*
