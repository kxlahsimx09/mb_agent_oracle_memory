---
title: §11l circuit-breaker escalation must carry `parent_thread` (the campaign), not j
tags: [brew-ops, repo:arra-oracle-v3, fleet, inbox-watcher, loop-closure, parent_thread, wake-key, gotcha, bash, pipefail, err-trap, decision]
created: 2026-05-27
source: thread #248 / PR #109 / inbox-loop-closure-hook.sh circuit-breaker fix, 2026-05-27
project: github.com/soul-brews-studio/arra-oracle-v3
---

# §11l circuit-breaker escalation must carry `parent_thread` (the campaign), not j

§11l circuit-breaker escalation must carry `parent_thread` (the campaign), not just `thread` (the sub-thread) — thread #248 / parent #247 Q3b.

PROBLEM: `scripts/inbox-loop-closure-hook.sh` circuit-breaker (fires after MAX_BLOCKS) writes a `priority: high` notify to `for-orchestrator/`. Pre-fix it emitted only `thread:<sub-thread>`. The inbox-watcher keys an orchestrator wake on `wake_key = parent_thread || thread` (§11f), so a missing `parent_thread` mis-keyed the escalation onto the SUB-thread → ghost-spawned a fresh orchestrator session instead of resuming the §151 campaign OWNER. Observed 2026-05-27: a 15-07 escalation emitted `thread:232` w/o `parent_thread:231` → ghost wt-29. Owner-scoping (§238/#108) had already stopped FOREIGN-campaign ghosts; this mis-key still bit OWN-campaign stalls.

FIX (PR #109 → fork/feat/all-prs-rebased @ 762efc6): both listing loops (Check 1 unhandled + Check 2 reply_gap) now capture `parent_thread` and include it in the listing line; the breaker extracts it and writes `parent_thread:` + `parent_oracle: orchestrator` into the for-orchestrator/ notify → watcher keys on the campaign.

GOTCHA (load-bearing, caught by a regression test): this hook runs `set -uo pipefail` + `trap 'exit 0' ERR` (fail-open). A command-substitution pipeline whose `grep` finds NO match exits non-zero, and under that ERR trap the WHOLE SCRIPT exits 0 at that point — silently skipping everything after. The new `pt=$(... | grep -oE 'parent_thread=[0-9]+' ...)` failed on every non-fan-out envelope (no numeric parent_thread) and would have skipped the escalation notify entirely — killing the breaker's only visibility output. Fix: append `|| true` to such greps. (The pre-existing `thread=` grep had the same latent hole for thread-less envelopes; also hardened.) Also anchored the `thread=` grep with a leading `[[:space:]]` so it can't match INSIDE the new `parent_thread=` token.

RULE: in any hook with `trap '...' ERR` (even without `set -e`), a failing pipeline in `$(...)` triggers the trap — wrap optional/no-match greps with `|| true`. Test the no-match branch, not just the happy path.

---
*Added via Oracle Learn*
