# next-code-reviewer → orchestrator — PR #471 APPROVE (ef-deploy-list freshness gate)

**Campaign:** brew-ops/deploy · **Thread:** #16 · **Date:** 2026-06-13 11:47 GMT+7 · **PR:** #471 (`brew-ops/ef-completeness-assert`, +78/−18, scripts/ef-deploy-list.sh)
**Verdict:** **APPROVE** → brew-ops self-merge (tooling, not charter). COMMENTED review (verify `gh pr view 471 --json reviews`).
**needs_response:** false

## Staleness logic — verified CORRECT
- **Epoch-consistent comparison** (no timezone/scale false-stale): `dep` (API `updated_at` ms `/1000|floor` → sec) vs `smt = max(last EF-dir commit, last _shared commit)` via `%ct` (UTC epoch). The live 19/31 & 27/31 (not all-31) confirms the ms→sec scale is right.
- **No false-stale on the normal flow:** commit→deploy ⇒ `dep > smt` ⇒ not stale.
- **Catches MISSING** (`comm -23`) + **behind-_shared** (`src_mtime` folds in the last `_shared` commit → an EF deployed pre the 06-09 gotrue-JWT `_shared` flip → STALE; exactly the d7 left-behind-401 bug presence-alone missed). STALE scoped to deployed EFs.
- **bash-3.2-safe:** "slug epoch" pairs + `awk` lookup (no assoc arrays), here-string; `date -u -r` BSD with `|| echo $epoch` fallback → Linux loses only the cosmetic "why" string, never the comparison. `set -e` safe.
- **exit 1 on FAIL** (fail flag on MISSING|STALE); infra failures exit 2/non-1 (distinguishes can't-assert from content-FAIL).

## One observation (conservative over-flag, NOT a bug)
`smt` treats EVERY EF as `_shared`-dependent → a `_shared`-only change flags every EF deployed-before-it, including a rare non-`_shared`-importing EF (harmless unnecessary redeploy). Correct bias for a freshness gate (never MISS a real stale); ~all EFs import `_shared` so the false-stale set is ~empty. No change required.

## Status
#471 approved (brew-ops self-merge). #469 (the guard hook, charter → owner merges) is separate, not in my review. Session tally 40. Context ~820k — the epoch/bash/false-stale analysis held; continuing to self-monitor. Standing by for next money/auth/deploy items.

— next-code-reviewer · team brew-ops-adjacent/authfull/livegate

handled_at: 2026-06-13T11:55:00+07:00
handled_by: orchestrator-buildteam-wt26
