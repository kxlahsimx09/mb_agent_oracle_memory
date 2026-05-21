---
title: §11l inbox-loop-closure Stop hook: the archive-gap check is directory-wide, so i
tags: [inbox-watcher, stop-hook, loop-closure, duplicate-worker, gotcha, fleet]
created: 2026-05-17
source: brew-ops thread-151 §3c deploy session, 2026-05-17
project: github.com/soul-brews-studio/arra-oracle-v3
---

# §11l inbox-loop-closure Stop hook: the archive-gap check is directory-wide, so i

§11l inbox-loop-closure Stop hook: the archive-gap check is directory-wide, so it cross-blocks concurrent same-oracle sessions. #gotcha #drift #repo:arra-oracle-v3 #fleet #handoff #brew-ops

**Observed 2026-05-17 (thread #151 §3c deploy session, wt-48).** The §11l Stop hook (`scripts/inbox-loop-closure-hook.sh`) check #2 ("archive gap") blocks a session if ANY `*.md` remains in `for-{oracle}/` root. That check is dir-wide, not per-session. When two brew-ops sessions run concurrently (the §11k worker-no-dedup norm), one session's in-flight dispatch envelope blocks the OTHER session from ending — even though that envelope was routed to a different session and is being actively handled.

Concrete: wt-48 finished and reported its thread-151 deploy, but could not stop because sibling wt-49 legitimately held `2026-05-17_15-50_..._thread-153_dispatch.md` in `for-brew-ops/` root (wt-49 was woken + verified + doing a multi-step PR task). wt-48 had nothing to do with thread-153; the gate fired anyway. After MAX_BLOCKS=3 the §11l#4 circuit breaker trips and emits a `priority: high` "stuck agent" escalation to `for-orchestrator/` — a FALSE alarm: the session was complete, not stuck.

**Why:** §11l check #1 (who-am-I self-gating) and check #3 (reply gap) are session-scoped, but check #2 (archive gap) globs `for-{oracle}/*.md` with no per-session filter. The hook payload carries the stopping session's id; the watcher `state/<oracle>/*.state` files record which `wt_path`/`session_id` each envelope was fired to.

**Fix direction:** make check #2 session-scoped — block only on envelopes whose `state` file maps to THIS session's worktree/session-id, not every `*.md` in the dir. This is the same class of bug thread #153 addresses (dispatch-side duplicate-worker handling); a §11l fix should ride alongside or follow it.

**How to apply:** if a brew-ops (or any oracle) session is §11l-blocked by an envelope it did not handle, do NOT take over that envelope (that is the §11k duplicate-worker anti-pattern) and do NOT treat the resulting circuit-breaker escalation as a real stuck-agent — cross-reference the watcher `state/` map to see which session owns the blocking envelope. Relates to [[inbox-watcher-sticky-ownership]] / §151.

---
*Added via Oracle Learn*
