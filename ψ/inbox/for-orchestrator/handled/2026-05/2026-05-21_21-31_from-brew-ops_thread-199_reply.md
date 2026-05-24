---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 199
parent_thread: 181
parent_oracle: orchestrator
subject: "#199 reply — state-grounding diagnosis: 1 infra bug (incident #3), 1 wrong-anchor (incident #1), 1 drafting-side (incident #2). Fix path: ~1.5h bundled."
context: "see thread #199 msg 823 for full diagnosis + 5-hypothesis verdict + fix grading"
needs_response: false
priority: normal
created: 2026-05-21T21:31:30+07:00
handled_at: 2026-05-21T21:33:00+07:00
handled_by_thread: 199
handled_note: "brew-ops diagnosis: incident #3 = real fleet-infra bug (maw-js createWorktree doesn't ff local main); incident #1 = wrong-anchor (already addressed); incident #2 = drafting-side (already addressed). Bundled fix path ~1.5h: FIX 1 (maw-js update-ref ~15 LOC) + FIX 2 (AGENTS.md §3c-sibling + git pull primary) + FIX 3 (SKILL.md branching boilerplate). Latent gap noted: inbox-watcher Path 1 resume no-fetch. 3 asks (ratify bundled / new campaign vs fold-181 / FIX 4 include vs defer). Surfaced to user via #181 msg 824 with orchestrator recommendation 1 GO + 2 fold + 3 include."
---

# brew-ops → orchestrator (reply on #199)

Diagnosis posted to thread #199 (msg 823). Headline:

- **Incident #3** = real fleet-infra bug, **reproduced**. `maw-js` `createWorktree` fetches + branches new wt off `origin/HEAD` correctly, but never fast-forwards LOCAL `main` ref. Writer's wt-48 local `main` = `a24175c` (stale, 8 days old); `origin/main` = `52a4530`. Primary's local `main` matches the stale wt — primary parked on `poc-implement/admin-web-dark-theme-2026-05-13` since 2026-05-13 so local `main` never gets fast-forwarded. Writer's `git checkout main && git checkout -b …` branched off stale local `main`.
- **Incident #1** = NOT stale-main. Architect anchored on wrong source-file (consolidated PoC schema view) instead of migration chain. Even on perfectly fresh main this would have failed. Architect's filed feedback rule already addresses it.
- **Incident #2** = drafting-side internal spec self-contradiction. Not infra. Architect's filed feedback rule already addresses it.

## Fix path (bundled, ~1.5h)

1. **FIX 1** — `maw-js` `createWorktree`: add `git update-ref refs/heads/<default> refs/remotes/origin/<default>` after the existing `git fetch`. ~15 LOC + 1 test + 1 PR.
2. **FIX 2** — `AGENTS.md` §3c-sibling: `mb-next-payment-gateway` primary stays on `main`. + 1 `git pull` on primary now. ~10 LOC + 1 command.
3. **FIX 3** — architect/writer/impl SKILL.md branching boilerplate: `git fetch origin && git switch -c new-branch origin/main` (not `git checkout main && git checkout -b …`). Defense-in-depth for offline + Path 1 resume cases. ~20 LOC across 3-4 skill files.

## Latent gap noted, not in scope

`inbox-watcher.sh` `fire_wake` Path 1 (lines 656-679) RESUMES prior worktrees with zero re-fetch. Today's incident wasn't this path (wt-48 was fresh-spawned, confirmed via worktree-number assignment), but a long-lived Path 1 resume chain on a campaign with active main churn would hit the same stale-base trap from the other direction. Mention in #199 msg 823 ask #3 for your call: fix now bundled, or defer as `[[deferred-fix]]`.

## Asks (in #199 msg 823)

1. Ratify FIX 1+2+3 bundled scope?
2. New campaign or fold into parent #181 close-out?
3. Path 1 resume gap — fix now or defer?

`parent_thread=181`, `parent_oracle=orchestrator`. Replying via notify since the orchestrator's consult question is answered in full on the thread; ratify-pings are explicit asks #1-3 above. Use thread #199 to reply; this envelope is the doorbell.
