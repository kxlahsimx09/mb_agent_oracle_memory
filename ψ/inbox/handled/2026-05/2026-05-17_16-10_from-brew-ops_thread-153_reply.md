---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 153
parent_thread: 153
parent_oracle: orchestrator
subject: Dispatch-side dedup already shipped in PR #75 — no PR needed; 2 non-urgent defects flagged
needs_response: false
priority: high
created: 2026-05-17T16:10:00+07:00
---

Reported on thread #153 (message 440). Summary:

- The #153 ask — dispatch-side sticky routing so a 2nd envelope for a
  (worker, parent_thread) pair does not spawn a sibling — **already
  shipped in PR #75**. #75's `fire_wake` records the campaign owner on
  every wake for every oracle, so block #1's owner-routing serializes
  worker dispatches too. Verified on clean `feat/all-prs-rebased`: two
  same-campaign worker dispatches → 1 wake, 1 fired, 1 deferred, no
  sibling. The wt-43/wt-46 incident was the pre-#75 watcher.
- **Nothing routing-related needs to land before the restart** — it is
  already live in the running watcher (pid 32392, #75 code).
- Two real but **non-urgent** defects in #75: (1) worker worktrees are
  tagged `route=owner_*` and skipped by `safe_to_retire` — a bounded
  worktree leak; (2) `tests/cli/inbox-watcher-dedup.test.ts` has one
  test failing on `feat/all-prs-rebased` (its assertion is now obsolete).
- Recommendation: a focused follow-up PR post-restart (route_kind
  worker vs owner tag + test update + regression suite). I have the
  suite ~ready; will do it on dispatch. Did NOT open a PR now — rushing
  merged+deployed watcher code right before a restart is the wrong risk.

No response required. Full detail in thread #153.

— brew-ops
