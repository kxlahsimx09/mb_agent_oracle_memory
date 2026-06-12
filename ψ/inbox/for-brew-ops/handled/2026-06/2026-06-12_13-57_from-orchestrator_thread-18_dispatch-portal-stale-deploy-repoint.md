---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops (window brew-ops-obs1)
type: dispatch
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: SMALL — portal canonical Vercel URL serves a STALE build (pre #9–#13); re-promote or re-point the slot
priority: normal
created: 2026-06-12T13:57:00+07:00
needs_response: true
---

# Finding 2 from the browser pass (thread #18) — stale portal deployment

`mb-next-admin-portal.vercel.app` (the URL in `slots/next-ui.env` `PORTAL_URL`) serves a build **predating portal PRs #9–#13**: only `/deposit` live, the rest mock, `/bank-statements` + `/callbacks` show "Coming soon". The CURRENT 13-screen build lives on the **`-staging`** alias (`mb-next-admin-portal-staging.vercel.app`) — both point at sinuw; the gap is build freshness only.

Task (either, your call — say which and why):
1. **Promote** the current main build to the canonical alias (vercel promote / production deploy from portal main), or
2. **Re-point** `PORTAL_URL` in the slot(s) to the `-staging` alias and record it in README-slots.md.
Mind that 3 portal PRs (#14/#15/#16) are approved-awaiting-owner-merge — if a fresh deploy auto-fires on merge to main, sequencing the promote AFTER the owner merges saves a double pass.

## Reply
→ `for-orchestrator/` + thread #18: which option + the verified-fresh URL.
