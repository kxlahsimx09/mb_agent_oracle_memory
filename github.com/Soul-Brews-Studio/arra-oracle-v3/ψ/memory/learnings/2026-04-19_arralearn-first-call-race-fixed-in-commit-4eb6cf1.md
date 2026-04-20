---
title: arra_learn first-call race fixed in commit 4eb6cf1 on local/all-prs branch of gi
tags: [["brew-ops", "fix", "race-condition", "vector", "lancedb", "thread-9", "first-call-race", "pattern", "repo:arra-oracle-v3", "memory", "indexer", "2026-04-19"]]
created: 2026-04-19
source: src/tools/learn.ts commit 4eb6cf1 on local/all-prs, 2026-04-19 brew-ops session
project: github.com/soul-brews-studio/arra-oracle-v3
---

# arra_learn first-call race fixed in commit 4eb6cf1 on local/all-prs branch of gi

arra_learn first-call race fixed in commit 4eb6cf1 on local/all-prs branch of github.com/Soul-Brews-Studio/arra-oracle-v3. The race was: `getVectorStoreByModel(model)` in `src/tools/learn.ts:199` returned a LanceDBAdapter whose background `connect()` promise was still in-flight; the immediately-following `addDocuments()` call entered `ensureCollection()` which throws synchronously if `this.db` is null. The throw got caught by learn.ts and downgraded to `embedding: "failed"` while FTS5 + disk write had already succeeded. Result: first `arra_learn` per fresh MCP process landed in FTS but not in lancedb; subsequent learns in the same process saw `this.db` populated (connect had resolved) and worked normally.

## Evidence chain (pre-fix observations)

1. `ψ/memory/retrospectives/2026-04-17/16.58_bot-baseline-95dbb70.md` — first retro to note an embedding failure next to a successful FTS write.
2. `ψ/memory/retrospectives/2026-04-18/07.48_bot-baseline-7d4b50e.md` — second occurrence; pattern acknowledged.
3. 2026-04-18 workflow-5 audit summary (`learning_2026-04-18_audit-run-2026-04-18-1619-gmt7-brew-ops-work`) — third occurrence, live-reproduced while writing the audit report itself.
4. 2026-04-19 workflow-9 spec-fix learning (`learning_2026-04-19_w9-step-3-extractor-regex-was-anchored-on-impl`) — fourth occurrence, also live-reproduced.
5. Demand-side confirmation: 4× vector-mode `arra_search query="SCB approver matching [strategy]"` returned 0 despite 5 vault files containing the content. Those files were written with `embedding: "failed"` → absent from lancedb until manual re-index.

## Why only first-call per process

- `modelStoreCache` + `connectPromises` are module-level singletons in `src/vector/factory.ts`.
- First `arra_learn` hits the cold cache → `getVectorStoreByModel` creates adapter, starts background connect, returns immediately → addDocuments races and loses.
- Subsequent calls find `this.db` populated (connect resolved) → succeed.
- Each fresh MCP spawn (every new agent session) resets the cache → every session's first learn loses the race unless something else (e.g. `arra_search mode=vector model=bge-m3`) warmed the cache first.

## What changed

`src/tools/learn.ts`:
- Import swapped from `getVectorStoreByModel` to `ensureVectorStoreConnected` (sibling function in the same module that awaits the pending connect promise before returning the adapter).
- `const vectorStore = getVectorStoreByModel(model)` → `const vectorStore = await ensureVectorStoreConnected(model)`.
- Added explanatory comment block quoting the symptom so future readers don't revert to `getVectorStoreByModel` for "efficiency".

`src/vector/__tests__/connect-race.test.ts` (new):
- 2 unit tests asserting raw `LanceDBAdapter.addDocuments()` without a completed `connect()` throws with a greppable "LanceDB not connected" message.
- Uses a fake embedder (no Ollama dependency) so the guard runs in CI without external services.
- 14/14 tests pass across learn.test.ts + the new file (13 ms).

## Symmetry restored

Other vector call sites were already correct before this fix:

| File | Line | Pattern |
|---|---|---|
| `src/tools/search.ts` | 136 | `await ensureVectorStoreConnected(model)` |
| `src/server/handlers.ts` | 889 | `await ensureVectorStoreConnected(modelKey)` |
| `src/server/handlers.ts` | 1202 | `await ensureVectorStoreConnected(key)` |
| `src/tools/learn.ts` | 199 (before) | `getVectorStoreByModel(model)` ← lone outlier |

The outlier explained why search consistently worked (post-reindex) and writes consistently lost silently.

## What this fix does NOT address

- **Ollama transient failures** during `addDocuments` (network blip, model reload, etc.) still land in the same catch → `embedding: "failed"` path. Caller discipline (check `embedding` field in response + retry) remains the mitigation until a retry-with-backoff is added upstream. Tracked as a separate follow-up on thread #9.
- **Silent log loss.** HTTP server stdout/stderr currently go to `/dev/ttys014` with no log file under `~/.arra-oracle-v2/`. Retroactive debugging required code inspection instead of log grep. Capturing stderr to a rotating log is a separate infra task.
- **Alerting on `embedding: "failed"` responses.** The field is returned but nothing aggregates it. A counter + alert threshold would turn future regressions from "discovered days later via audit" into "paged at write time".

## Pattern name (brew-ops pattern library)

**First-call-per-process async-init race.** Any module-level singleton whose initializer is fired lazily-and-asynchronously on first request risks this pattern if downstream callers skip the await. Symptoms: first operation in every fresh process fails; subsequent operations succeed; test suites that run sequentially in a warm process never reproduce it; cron jobs and short-lived processes hit it every time. The `ensureConnected`-style await-the-pending-promise helper is the standard remedy; making sure every call site uses it is the discipline.

Tags: brew-ops, repo:arra-oracle-v3, memory, indexer, vector, fix, race-condition, thread-9, bge-m3, lancedb, pattern, first-call-race

---
*Added via Oracle Learn*
