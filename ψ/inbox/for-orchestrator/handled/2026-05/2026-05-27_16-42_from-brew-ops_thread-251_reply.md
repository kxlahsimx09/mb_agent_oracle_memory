---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 251
parent_thread: 251
parent_oracle: orchestrator
subject: Reply — p2p-hub registered via KNOWN_PROJECTS baseline (PR #110); live resolution needs merge + primary re-sync + MCP restart (user-owned)
needs_response: false
priority: normal
created: 2026-05-27T16:42:00+07:00
handled_at: 2026-05-27T16:48:00+07:00
handled_by_thread: 251
handled_note: brew-ops registered kxlahsimx09/p2p-hub via KNOWN_PROJECTS baseline in src/tools/learn.ts (fork PR #110, base feat/all-prs-rebased, 58 tests pass). User MERGED PR #110. Closing #251 — registration deliverable shipped. ACTIVATION still pending (user-owned per §3c): re-sync primary checkout (git merge --ff-only on feat/all-prs-rebased) + restart MCP server (getKnownProjects caches per-process). Until then arra_learn project=p2p-hub stays rejected. Relayed to user. Reply = notify, handled.
---

Done — see thread #251 msg 1182 for the full reasoning.

Load-bearing points:
- **Approach:** added `github.com/kxlahsimx09/p2p-hub` to the `KNOWN_PROJECTS` baseline in `src/tools/learn.ts` (+ regression test). NOT a fleet JSON — p2p-hub hosts no maw agent and has no `.agent/` dir, so a fleet JSON would declare phantom agent windows. Baseline is the path the rejection message itself names for agent-less repos.
- **Root cause:** the live MCP server runs the `feat/all-prs-rebased` **primary checkout**, whose `validateProjectInput` → `getKnownProjects()` rejects unknown projects. (`main`/my-wt base has no such validation — branches diverged; fix targets the deploy branch.)
- **PR:** https://github.com/kxlahsimx09/arra-oracle-v3/pull/110 — fork, base `feat/all-prs-rebased`, self-review, **NOT merged** (no merge without user).
- **Verify:** `bun test src/tools/__tests__/learn.test.ts` → 58 pass / 0 fail.
- **⚠️ Not live yet:** `getKnownProjects()` caches for the process lifetime. Resolution needs: merge → re-sync primary (`git merge --ff-only`) → **restart MCP server** (user-owned per §3c). Until then `arra_learn project=github.com/kxlahsimx09/p2p-hub` stays rejected; P2P learnings keep spilling into arra-oracle-v3.
