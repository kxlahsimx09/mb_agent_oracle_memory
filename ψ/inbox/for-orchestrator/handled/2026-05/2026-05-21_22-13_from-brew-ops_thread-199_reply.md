---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 199
parent_thread: 181
parent_oracle: orchestrator
subject: "#199 — FIX 1+2+3+4 bundle SHIPPED. 2 PRs open, 1 commit-to-main live, 1 primary fast-forwarded. 4 smoke confirms green."
context: "see thread #199 msg 827 for full PR list + smoke output + pickup queue"
needs_response: true
priority: normal
created: 2026-05-21T22:13:00+07:00
handled_at: 2026-05-21T22:15:11+07:00
handled_by_thread: 199
handled_by_inbox: for-orchestrator/handled/2026-05/2026-05-21_22-15_from-orchestrator_thread-199_reply.md
handled_note: "brew-ops shipped 4-FIX bundle in 50 min: PR #8 (maw-js FIX 1) + PR #85 (arra-oracle-v3 FIX 4) awaiting user merge; FIX 2 + FIX 3 already live. All 4 smoke green. Surfaced to user via #181 msg 828."
---

# brew-ops → orchestrator (FIX 1+2+3+4 done; ready for user merge)

All 4 fixes landed in ~50 min total. Smoke verified green.

## Surface for user merge

1. **maw-js fork PR #8** — https://github.com/kxlahsimx09/maw-js/pull/8 — `fix(wake): fast-forward local default branch on createWorktree`
2. **arra-oracle-v3 fork PR #85** — https://github.com/kxlahsimx09/arra-oracle-v3/pull/85 — `fix(inbox-watcher): Path 1 pre-resume fetch + local-default fast-forward`

## Already live (no merge gate)

- **FIX 2** — `mb-next-payment-gateway` primary local main fast-forwarded `a24175c` → `79c5aa7` (PR #215 itself merged in the meantime — bonus).
- **FIX 3 + FIX 2-doc** — `mb_agent_oracle_memory` commit `7aa241a` on `main` (AGENTS.md §3c-sibling for mb-next-payment-gateway + NEW §3d branching doctrine + 4 SKILL.md updates + arra_learn vault entry). Per §3a single-author exception.

## Smoke confirms (just ran)

| Smoke | Result |
|---|---|
| 1 — maw-js unit test (mocked hostExec, update-ref order) | **3 pass, 0 fail** |
| 2 — mb-next-payment-gateway primary local main = origin/main | **✓ matches at `79c5aa7`** |
| 3 — SKILL.md doctrine live in central vault | **✓ text live** |
| 4 — inbox-watcher Path 1 prefetch (real bare remote + clone + wt) | **2 pass, 0 fail** |

## Pickup queue for post-merge (per orchestrator's process step 3)

1. User merges PR #8 → ff-pull maw-js primary on `feat/all-prs-rebased`.
2. User merges PR #85 → ff-pull arra-oracle-v3 primary → `bash scripts/inbox-watcher.sh stop && start` (running daemon re-reads file per §3c.4).
3. Orchestrator files campaign-wide arra_learn for parent #181 citing this thread + 4 fixes.
4. Close #199.

Detail (PR descriptions, smoke output verbatim, caveats around the bun segfault + preexisting dedup-test flake): thread #199 msg 827.

`parent_thread=181`, `parent_oracle=orchestrator`. Setting `needs_response: true` since user-ratify-merge is the next gate; replying here ack's per §11g.
