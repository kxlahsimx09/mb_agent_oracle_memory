# oraclevecfix — DONE (code shipped; merge blocked on perms)

**Campaign `oraclevecfix` / brew-ops, 2026-06-18.** Follow-up to the `oraclevec` diagnostic (handoff `2026-06-18_07-53_oraclevec-verdict`). The 3 cosmetic vector-label/warning fixes are applied, committed, CI-green, and PR'd. **NO index rebuild, NO search-behaviour change** (the index is HEALTHY — confirmed by the diagnostic).

## PR
- **https://github.com/Soul-Brews-Studio/arra-oracle-v3/pull/2483** — base `alpha`, head `kxlahsimx09:brew-ops/oraclevec-label-fix` (fork-based).
- Status: **OPEN**, `mergeable=MERGEABLE`, `mergeStateStatus=CLEAN`. Both checks PASS (GitGuardian + "Typecheck and scoped tests", 3m27s).
- **BLOCKED ON MERGE PERMISSION** — `kxlahsimx09` cannot execute `MergePullRequest` on the upstream (GraphQL perms denial, same class as the oracle-studio label limitation). **A privileged account (orchestrator/owner) must do the merge** (`gh pr merge 2483 --repo Soul-Brews-Studio/arra-oracle-v3 --squash`). `--auto` also denied. This is the only open item.

## The 3 fixes (1 commit, 6 files)
1. **Label rename** — stale `ChromaDB` labels that mislabel the DEFAULT LanceDB backend → `[Vector]` / "LanceDB vectors" / "vector index":
   - `src/tools/search/definition.ts` (oracle_search tool desc — the key agent-facing one), `handler.ts` + `vector.ts` (`[ChromaDB]`/`[ChromaDB ERROR]` log prefixes), `src/tools/stats.ts` (oracle_stats desc), `src/server/handlers.ts` (doc comment).
   - Real `type:'chroma'` adapter code left UNTOUCHED (chroma is a genuine adapter option).
   - NOTE: on `alpha`, `search.ts` was already split into `src/tools/search/{definition,handler,vector}.ts` and the stale labels had MOVED there (not yet fixed upstream) — caught + fixed.
2. **De-latch `logLocalVectorDisabled`** (`src/vector/cpu-capabilities.ts`) — last-reason tracking (logs on state transition only, no spam) + `noteLocalVectorEnabled()` re-arm wired into `handlers.ts` (sole caller on alpha).
3. **Harden `localVectorIndexMissingReason`** — `|| ORACLE_VECTOR_DB_PATH || LANCEDB_DIR` (+ VECTORS_DB_PATH for sqlite-vec) mirroring createVectorStore's default chain.

## Verify
- `tsc --noEmit` green. Touched-area tests green. 3 failing tests are pre-existing **Ollama-service** failures (reproduce identically on clean `origin/alpha`) — unrelated.

## §3c re-sync note (NON-URGENT)
The RUNNING checkout (inbox-watcher daemon + MCP server) only picks up these labels on the next §3c re-sync (`git merge --ff-only` + daemon restart). **Cosmetic + non-urgent — do NOT restart the daemon for this.** It rides along on the next routine re-sync after #2483 merges.

## Branch convention (durable)
`alpha` is the working trunk (not `feat/all-prs-rebased`, not `main`). Branch off `origin/alpha`, PR into `alpha`. Pushing to `main` triggers a STABLE release + is blocked by a repo hook.

## NEXT STEP for orchestrator/owner
Merge PR #2483 (squash). Nothing else outstanding.

`arra_learn` filed: `2026-06-18_repoarra-oracle-v3-search-vector-brew-ops-la.md`.