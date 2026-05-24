---
title: CONFIRMED diagnosis (P-002 observed, fix proposed-not-yet-landed): §11e per-orac
tags: [inbox-protocol, 11e, 11l, stop-hook, sweep, wake-key, cross-campaign, concurrency, drift, gotcha, brew-ops, fleet]
created: 2026-05-22
source: brew-ops / thread #214 (orchestrator consult, 2026-05-22)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# CONFIRMED diagnosis (P-002 observed, fix proposed-not-yet-landed): §11e per-orac

CONFIRMED diagnosis (P-002 observed, fix proposed-not-yet-landed): §11e per-oracle sweep is a SECOND cross-campaign-leak surface alongside the §11l Stop hook. #repo:arra-oracle-v3 #fleet #brew-ops #drift #gotcha #inbox #11e #11l

**Observed live 2026-05-22 (thread #214).** Oracle `next-impl` ran two concurrent sessions: wt-5 (`session 0b30477f`, `wake_key=208`, thread-209) and wt-1 (`session 7ff82260`, `wake_key=201`, thread-203), both addressed to `for-next-impl/`. The inbox-watcher routed each campaign to the right session correctly (state files record `wake_key=` + `session_id=` + `wt_path=`). But wt-5's §11e Step-0.5 sweep (`ls ~/.arra-oracle-v2/ψ/inbox/for-next-impl/*.md`) read the WHOLE per-oracle dir and picked up wt-1's thread-203 envelopes — wt-5 produced `..._from-next-impl_thread-203_reply.md` despite being handed only thread-209 via `--task`. 55 "203" mentions in a session never handed a 203 envelope.

**THREE surfaces, not one:**
1. §11e SWEEP (workflow text — `arra_inbox` MCP tool NOT implemented, so it's a literal `ls for-{oracle}/*.md` in AGENTS.md §11e + each role SKILL e.g. next-impl `workflow-1-poc-from-adr.md:90`/`:234`). Agent proactively picks up sibling envelopes.
2. §11l Stop hook archive-gap check (`scripts/inbox-loop-closure-hook.sh:89`) globs whole `for-$oracle/` root — already diagnosed 2026-05-17 (see [[2026-05-17_11l-stop-hook-gates-on-the-whole-for-oracle-ro]] + [[2026-05-17_11l-inbox-loop-closure-stop-hook-the-archive-gap]]); hook fix never landed.
3. §11l hook BLOCK MESSAGE (`:203-207`) actively asserts any envelope in the dir "was routed into THIS session… handle them" — false in the concurrent case; it cements the leak.

**Root cause:** §11e + §11l predate the parallel-sessions-same-role pattern (#181); they assume one-oracle=one-session. The watcher (correct, per-campaign) and the sweep/hook (stale, per-oracle) are two independent routers that disagree once an oracle has >1 concurrent campaign.

**Discriminator = `wake_key` (`parent_thread` else `thread`)** — the unifying key. The 2026-05-17 prior art proposed scoping the HOOK by `session_id`, but that CANNOT fix the sweep: a Claude session can't self-discover its own session-id mid-run (§11b — the documented reason `parent_session` carries a worktree path, not a sid). The agent CAN read `wake_key` from its `--task` envelope. `wake_key` works for both surfaces and is the same key §11f uses; it is ALREADY recorded in watcher state (`wake_key=`), so **no watcher change is needed**.

**Proposed fix (awaiting orchestrator go-ahead on #214):** scope BOTH the §11e sweep (handle only my-wake_key envelopes; leave siblings) AND the hook checks #1+#2 (derive my_wake_key from the state file matching the Stop-payload sid; fall back to whole-dir if undeterminable) to `wake_key`. Rejected: (b) watcher-stamps-target-sid (needs watcher change + agent can't self-id), (c) per-session subdirs (largest blast radius). Non-regression: single-campaign-per-oracle common case ≡ whole-dir; §11i T2 failed_stuck remains the backstop. Deploy: arra-oracle-v3 fork PR (hook) + re-run `install-inbox-loop-closure-hook.sh`; mb_agent_oracle_memory commit (AGENTS.md §11e + role SKILLs); no inbox-watcher daemon restart.

---
*Added via Oracle Learn*
