---
title: §11l Stop-hook gates on the whole for-{oracle}/ root — concurrent same-oracle se
tags: [inbox, stop-hook, loop-closure, concurrency, 11l, watcher, deadlock]
created: 2026-05-17
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# §11l Stop-hook gates on the whole for-{oracle}/ root — concurrent same-oracle se

§11l Stop-hook gates on the whole for-{oracle}/ root — concurrent same-oracle sessions deadlock-by-proxy (observed 2026-05-17).

`scripts/inbox-loop-closure-hook.sh` point 2 ("Archive gap") blocks a session's Stop if ANY `*.md` remains in `for-{oracle}/` root — not just envelopes routed to *that* session. With multiple concurrent sessions of the same oracle (normal under §11f session-per-thread/campaign), a fast-finishing session is held hostage by a slow sibling's still-open envelopes.

**Concrete case:** brew-ops session `wt-47` (thread #150 dispatch — deploy PR #74 + auto-start hardening) finished and fully closed its own loop (replied on #150, wrote reply envelope, archived its inbound envelope). But the Stop hook blocked it because two **thread #151** envelopes (a different campaign — sticky reply-routing design) were still in `for-brew-ops/` root, being actively worked by a *live separate session* (`5a86c267` / `wt-46`, claude pid confirmed alive). `wt-47` cannot close #151's envelopes without either (a) duplicating wt-46's in-flight implementation → double PR, or (b) archiving a `needs_response=true` envelope with no reply → the exact gap §11l exists to prevent.

**Correct behaviour:** the hook should gate a session only on envelopes *that session* was spawned to handle — reverse-lookup the Stop payload's session-id against `state/<oracle>/*.state` (`session_id=` field) and only block on envelopes whose state file names this session. Point 1's self-gating already does the session-id reverse-lookup; point 2 should filter by it too instead of globbing the whole root.

**Interim escape:** the §11l#4 circuit breaker (MAX_BLOCKS=3) trips and escalates to for-orchestrator/ — but it mislabels a correctly-finished session as "genuinely stuck."

Fix belongs in `inbox-loop-closure-hook.sh`; owner brew-ops. Tags: #repo:arra-oracle-v3 #fleet #brew-ops #gotcha #drift #mcp-tools

---
*Added via Oracle Learn*
