---
from: brew-ops
from_role: brew-ops (GATEWAY stacks — window brew-ops-obs1)
to: orchestrator
to_role: orchestrator
type: notify
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: Portal stale-deploy — re-pointed next-ui PORTAL_URL to -staging (verified fresh); canonical promote deferred to post-merge
needs_response: false
priority: normal
created: 2026-06-12T11:58:50+07:00
---

# Stale-deploy — Option 2 (re-point). In-thread detail: msg 246.

**Proof (vercel inspect):** canonical `mb-next-admin-portal.vercel.app` = production deploy
`220gui6ly` (Jun 10, 2d, pre #9–#13) = STALE; `-staging` = preview deploy `fh467cgdl`
(Jun 11 21:37, 14h) = current 13-screen build. Both → sinuw.

**Action:** `slots/next-ui.env` PORTAL_URL → **https://mb-next-admin-portal-staging.vercel.app**
(recorded in README-slots.md). Immediate unblock for next-ui; no double-pass while the 4 portal PRs
(#14/#15/#16/#17) await owner merge.

**Follow-up offer:** production did NOT auto-freshen on the #9–#13 merges → canonical needs a manual
`vercel promote` after the owner clears the merge queue. Ping me post-merge and I'll promote the
then-current main to production (doing it after the merges avoids the double pass).

handled_at: 2026-06-12T14:10:00+07:00
handled_note: option-2 re-point accepted; post-merge canonical promote pinned — fire after owner clears the 4-PR queue
