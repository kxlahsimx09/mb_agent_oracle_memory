---
title: Oracle Memory Audit run — 2026-04-21 21:30 GMT+7 (workflow-5, brew-ops, post-rei
tags: [brew-ops, repo:cross, memory, audit, workflow-5, 2026-04-21, post-reindex, vector-recovered, typo-dirs-recurrent, silent-fail-fix-merged, P0, lancedb, path-corruption]
created: 2026-04-21
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Oracle Memory Audit run — 2026-04-21 21:30 GMT+7 (workflow-5, brew-ops, post-rei

# Oracle Memory Audit run — 2026-04-21 21:30 GMT+7 (post-reindex)

**Vault:** `d33fac9` on `main` (10 uncommitted). **DB:** 1358 docs / 353 unique files / FTS=1358 (ratio 1.000, 0 orphans). **Vector:** LanceDB bge-m3 = 1358 rows, connected. **Trigger:** ad-hoc (post-reindex check).

## P0 findings

1. **9 active typo-path rows recurring across 3 orphan directories.** The 10:42 audit flagged "1 row with `bank-bot<`"; reality is worse — disk still has `github.com/kokarat/bank-bot<`, `github.com/kokarat/cbank-bot`, and `github.com/kokarat/kokarat/kokarat/` as physical directories with orphaned .md files. Reindex re-creates chunk rows every run because source files exist. Distribution: 7× cbank-bot chunks (`title-bot-side-intent-at-a-glance-flow-ktb`), 1× bank-bot< (`flow-scb-dual-control-withdrawal`), 1× kokarat/kokarat (`regression-candidate-callback-resend-scheduler`). arra_supersede handled the doc-layer 4 times (supersedes present) but the typo dirs remain → each reindex re-indexes the orphans. **Root cause:** Step 4 rubric checks `<`/`>`/space chars only — `cbank-bot` and `kokarat/kokarat` typos slip through detection. Fix: `git rm -r` the three typo directories in the vault (write operation — out of scope for read-only audit, needs human approval).

2. **Vector silent-failure fix landed on disk but NOT in running MCP processes.** Fix commit `9da820d` merged into `feat/all-prs-rebased-2026-04-20` (8ddca9a) changing [src/tools/search.ts:178-186](src/tools/search.ts:178) from `return []` → `throw error` in `vectorSearch()` catch. Regression tests added in [src/tools/__tests__/search.test.ts](src/tools/__tests__/search.test.ts) (97 pass / 0 fail). HTTP path (fresh server) returns vector results (`mode=vector&limit=3` → 3 hits, no warning). MCP path still returns 0 vector hits with old warning text "Vector search returned no results" — multiple long-lived `bun src/index.ts` processes (Mon 09AM, Mon 01PM, Sat 08PM, 10:40AM today) cache stale LanceDB handles from before the 21:26 reindex. **Action needed:** restart MCP processes OR deploy fix to feat branch's actual running instance.

## P1 findings

3. **Cross-reference validity regressed to 6.7% broken** (8/120, up from 6.1% at 10:42). Notable cluster: `2026-04-21_drift-deposit-auto-expire-pending-pointer-accuracy*` references 3 truncated/missing filenames (pg-writer ownership).

## P2 findings

4. 10 uncommitted vault files (within auto-commit cadence).
5. 1/57 retro missing diary/feedback (`06.13_w2-track-commit-dispatcher-maintenance.md` — same as prior audits; bot-writer track).
6. Duplicate-indexing at 178/292 = 61.0% — just crossed 60% boundary (was 57.4% at 10:42). Passing-with-caution.
7. Knowledge gaps §13b: 39 zero-result / 317 total (12.3%) past 14d; 15 vector-mode zeros concentrated during the 08:40-21:26 vector-degraded window — not real gaps.

## PASS sections

§0 principles (4/4), §0.5 preflight (0 unindexed), §1 git (0/0 ahead/behind), §2 FTS ratio 1.000, §5 tags (no_tags 0.6%, missing_repo 3.0%, missing_role 3.3%), §6 retro quality (98.2%), §8 supersede (0 dangling, 42 preserved per P-001), §9 traces (0 dangling, 0 raw>14d), §10 handoffs (1 true pending — brew-ops pre-existing double-wrap cleanup), §11 arra_learn ratio 15.9%, §13c orphan markers (markers found but mostly narrative/Decision-history per P-001; 0 P0/P1 active orphans), §14d session capture (14 learnings+retros / 7 proj commits in 6h = 2.0× ratio, healthy).

## Delta vs 2026-04-21 10:42 audit

| Metric | 10:42 | 21:30 | Δ |
|---|---|---|---|
| docs | 1256 | 1358 | +102 |
| FTS ratio | 1.000 | 1.000 | — |
| vector search | degraded (0 hits) | **recovered via reindex** | ✅ |
| active path-corrupt rows | 1 (bank-bot<) | **9 (3 dirs)** | worsened via indexer scan |
| cross-ref broken | 6.1% | 6.7% | +0.6pt |
| superseded docs | 38 | 42 | +4 |
| dup-indexing | 57.4% | 61.0% | +3.6pt |
| silent-fail bug | unaddressed | **fix merged** to feat branch | ✅ |

## Code delivery this session

- Bug: `vectorSearch()` swallowed LanceDB errors → "returned no results" warning (not "unavailable: <real err>"). Agents silently fell back to FTS for 3 days before 10:42 audit caught it.
- Fix: rethrow in [src/tools/search.ts:178](src/tools/search.ts:178); outer handler already surfaces as `"Vector search unavailable: <msg>"`.
- Merged: `fix/vector-search-silent-failure` (9da820d) → `feat/all-prs-rebased-2026-04-20` (8ddca9a).
- Tests: +2 regression (error propagation + legitimate empty-result). `bun run build` clean.

## Root cause of the vector-degraded window (resolved)

08:40-09:06 GMT+7 today: LanceDB concurrent-writer race during a `reindex:full` cycle — manifest v43 referenced ~14 fragments GC'd by a parallel writer (likely pre-09:15 HTTP server's `arra_learn` writes during reindex). No file lock in `@lancedb/lancedb@0.27.2`. SQLite + vault markdown untouched — user's 21:26 reindex rebuilt bge-m3 from SQLite cleanly.

## Recommendations (ordered)

1. **Human decision needed:** clean typo directories `bank-bot<`, `cbank-bot`, `kokarat/kokarat/` in vault via `git rm -r`. Audit cannot execute writes.
2. **Restart MCP processes** OR deploy fix branch to running instance so agent-visible warnings match reality.
3. Update Step 4 rubric to catch broader typo patterns (not just `<>`/space) — current check missed 8 of 9 rows this run.
4. pg-writer to fix 3 broken refs in `2026-04-21_drift-deposit-auto-expire-pending-pointer-accuracy*`.
5. bot-writer to add diary+feedback to `06.13_w2-track-commit-dispatcher-maintenance.md` (flagged 3 audits running now).

## Telegram §17

Sent via `mcp__brew-ops-telegram__telegram_send`; message_id captured below.

---
*Added via Oracle Learn*
