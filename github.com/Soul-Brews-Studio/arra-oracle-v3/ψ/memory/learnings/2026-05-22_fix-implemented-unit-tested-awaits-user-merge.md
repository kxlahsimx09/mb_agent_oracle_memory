---
title: FIX implemented + unit-tested (awaits user merge): §11e sweep + §11l Stop hook a
tags: [inbox-protocol, 11e, 11l, stop-hook, wake-key, campaign-scope, orchestrator-exception, fix, brew-ops, fleet]
created: 2026-05-22
source: brew-ops / thread #214 (orchestrator GO, 2026-05-22)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# FIX implemented + unit-tested (awaits user merge): §11e sweep + §11l Stop hook a

FIX implemented + unit-tested (awaits user merge): §11e sweep + §11l Stop hook are now campaign-scoped by wake_key — with an ORCHESTRATOR whole-dir EXEMPTION. #repo:arra-oracle-v3 #fleet #brew-ops #inbox #11e #11l #decision

Resolves the thread #214 cross-campaign leak (diagnosis: [[2026-05-22_confirmed-diagnosis-p-002-observed-fix-proposed]]; prior hook half: [[2026-05-17_11l-stop-hook-gates-on-the-whole-for-oracle-ro]]).

**Discriminator: `wake_key` = `parent_thread` else `thread`** — already recorded by the inbox-watcher in `state/<oracle>/*.state`; works for both the agent sweep (agent can't self-know its session-id mid-run, §11b) and the hook. A session handles/gates ONLY envelopes whose wake_key matches the campaign it was woken for; sibling same-oracle sessions' envelopes are left in place.

**THE KEY DURABLE CAVEAT (orchestrator, thread #214):** the **orchestrator is the multi-campaign hub** and MUST stay whole-dir — `for-orchestrator/` legitimately collects replies from ALL campaigns it owns, and **one hub session spans many wake_keys** (verified live 2026-05-22: orchestrator sid `6812815d` owned wake_keys 162/167/168/170; `e4cb06e8` owned 201+208; `3bff545d` owned 174+175). Worker oracles are one-session-per-campaign (e.g. next-impl `0b30477f`=208, `7ff82260`=201) → scopable. The orchestrator is one-session-many-campaigns → scoping would blind it to its other campaigns' loops. **Anyone touching the sweep or §11l hook must preserve the explicit `oracle == orchestrator → whole-dir` special-case** (not the undeterminable-fallback — explicit).

**Implementation:**
- §11l hook (`scripts/inbox-loop-closure-hook.sh`): Checks 1+2 scoped by wake_key derived from the state file naming the Stop-payload session_id; orchestrator special-cased whole-dir; undeterminable wake_key → whole-dir fallback (over-block is safe; §11i T2 failed_stuck is backstop); block message corrected. arra-oracle-v3 **fork PR #88**, 5-case harness green (sibling-only→allow, own→block, mixed→block-own-only, orchestrator→whole-dir, unknown-sid→allow).
- §11e + role cheat-sheets: mb_agent_oracle_memory commit `17121f5` (AGENTS.md §11e rule + orchestrator whole-dir-exception in dispatch Step 0 + brew-ops/next-impl/next-architect scope notes). **Live now** (read via .agent symlink).

**Deploy gating:** the §11e text is live, but the hook fix deploys only on **user merge of PR #88 → re-sync arra-oracle-v3 primary (§3c) → re-run `install-inbox-loop-closure-hook.sh`**. Until then the OLD whole-dir hook still cross-blocks, so the workflow-text change alone does not fully resolve it — the hook is the enforcement teeth. No inbox-watcher daemon restart needed (watcher unchanged; hook invoked fresh per Stop).

---
*Added via Oracle Learn*
