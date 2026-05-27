---
title: FIX (PR'd, tests green): orchestrator §11l Stop-hook gate scoped by §151 OWNER, 
tags: [inbox-protocol, stop-hook, 11l, 151, 214, 238, orchestrator, multi-session, owner-map, campaign-scope, fix, brew-ops, repo:arra-oracle-v3, fleet]
created: 2026-05-27
source: brew-ops thread #238, fork PR #108, 2026-05-27
project: github.com/soul-brews-studio/arra-oracle-v3
---

# FIX (PR'd, tests green): orchestrator §11l Stop-hook gate scoped by §151 OWNER, 

FIX (PR'd, tests green): orchestrator §11l Stop-hook gate scoped by §151 OWNER, not whole-dir (thread #238)

tags: [inbox-protocol, stop-hook, 11l, 151, 214, 238, orchestrator, multi-session, owner-map, campaign-scope, fix, brew-ops, repo:arra-oracle-v3, fleet]

## The bug (drift since 2026-05-22, re-hit ~5× on 2026-05-26)
`scripts/inbox-loop-closure-hook.sh` campaign-scoped every oracle's archive-gap + reply-gap checks by `wake_key` EXCEPT the orchestrator, which stayed **whole-dir** — the §214 carve-out, justified by "one hub session spans many wake_keys, so wake_key scoping would blind it." That assumption holds for ONE hub session. Under §181 there are **concurrent** orchestrator sessions (wt-20/21/22 on 2026-05-26), each owning a different subset of campaigns. The whole-dir gate then false-blocked each session on `for-orchestrator/` envelopes owned by a SIBLING session — envelopes §151 already routed to that sibling, and which the blocked session must NOT archive (would corrupt the sibling's audit trail). Supersedes/resolves the drift in `2026-05-22_214-orchestrator-whole-dir-sweep-exception-brea`, `2026-05-22_11l-stop-hook-archive-gap-check-races-151-sticky`, `2026-05-26_multi-orchestrator-session-coordination-hazard-th`.

## The fix
The orchestrator gate is now scoped by **§151 ownership**, not whole-dir (mirrors how §214 scoped the non-orchestrator gate by wake_key, but uses the per-session discriminator that fits a multi-campaign hub):
- in_scope() for orchestrator: envelope wake_key (parent_thread else thread) → read `sessions/orchestrator/thread-<wake_key>.owner` → in scope iff that owner worktree == THIS session's worktree.
- This session's worktree = Stop-hook payload `.cwd` (Claude) / `.payload.cwd` (Codex), `$PWD` fallback.
- Non-orchestrator wake_key scoping UNCHANGED.
- Unattributable scope (no owner record / no wake_key / cache miss) → falls back to gating whole-dir: over-block is safe (§11i T2 failed_stuck backstop); under-block would re-open the #140 silent-stall class.

## How to apply / verify
- Owner map: `~/.cache/inbox-watcher/sessions/<oracle>/thread-<wake_key>.owner` contains the owning worktree path (written by inbox-watcher `record_owner` from the dispatch envelope's `parent_session`). The hook reuses this exact map — single source of truth, no new state.
- Doc record: AGENTS.md §11e + §11l + footer (§238) amended; the §214 "the two never disagree" claim now reads: orchestrator gate tracks §151 owner, every other oracle tracks wake_key. Sweep stays whole-dir (sweep-reads-all, close-out-owns-own).
- Refs: arra-oracle-v3 fork PR #108 (hook + 5 regression tests in tests/cli/inbox-loop-closure-hook.test.ts, 12 pass); vault commit 7865978.

---
*Added via Oracle Learn*
