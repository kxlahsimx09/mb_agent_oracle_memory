---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 221
parent_oracle: orchestrator
subject: C+D done — PR #89 up (fork, base feat/all-prs-rebased). C fixed+vault-verified; D = stale-server-only (no code). Restart GATED ON MERGE — relay the GO.
context: full reply posted as thread #221 message #980 (2026-05-23 15:40 GMT+7). C code fix + tests (206 pass/0 fail, tsc clean), verified against live vault (12 _universal learnings now discovered). D: current source 391420e resolves project correctly (KNOWN_PROJECTS whitelists arra-oracle-v3) → wt-17 fallback was the 6-day-stale server, no code change; restart deploys it. Awaiting user merge → then I execute/confirm the src/server.ts restart (§3c).
needs_response: false
priority: normal
created: 2026-05-23T15:40:09+07:00
handled_at: 2026-05-23T15:48:00+07:00
handled_by_thread: 221
handled_note: notify received — C+D complete, PR #89 verified OPEN/MERGEABLE (base feat/all-prs-rebased, +142/-3). Milestone relayed to user with merge ask; ack posted to thread #221 (msg 981). Thread left pending (campaign mid-stream). Restart GATED ON USER MERGE — orchestrator will post restart GO to #221 once #89 merges.
---

# C+D complete — PR #89, restart gated on merge (brew-ops → orchestrator)

Full reply on thread #221 message #980.

- **PR:** https://github.com/kxlahsimx09/arra-oracle-v3/pull/89 — fork base `feat/all-prs-rebased` (off `391420e`).
- **C (code):** `discoverProjectPsiDirs` now scans `_universal/ψ`. Vault-verified — 12 universal learnings now discoverable (was 0 via batch reindexer), incl. the 5 orchestrator-pattern 2026-05-21 ones.
- **D (no code):** current source resolves `project=…` correctly (`KNOWN_PROJECTS` whitelists arra-oracle-v3); the `_universal/` fallback was the stale server (PID 5859, up since May 17). Regression test + `docs/LOCAL-DEV.md` restart-on-deploy note added.
- **Tests:** `bun run test:unit` 206 pass / 0 fail; `tsc --noEmit` clean.

**Next:** relay the restart GO once the user merges #89 — I'll ff the primary (§3c) and restart `src/server.ts`. A/B stay backlog.
