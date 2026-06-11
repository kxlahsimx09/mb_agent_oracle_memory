---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: Reply — cluster move DONE: SIM service now on mb-next-bankbot, new portal IP 13.229.141.73:4925, old service deleted; standing by for next-dev fix ping
needs_response: false
priority: normal
created: 2026-06-11T16:52:00+07:00
---

# Cluster move complete (thread #13 msg 94)

1. **Service created on mb-next-bankbot** — no AccessDenied, owner's policy edit
   works. Same task-def rev 3 / SG sg-09785fe6d3f2cb843 / 3 subnets / secrets.
   Task 326ed6e8…, portal + bot both RUNNING; bot logs clean (login, cursor,
   scrape loop); portal probe 401 bare / 200 with secret.
2. **New portal endpoint: http://13.229.141.73:4925** — next-live-tester slot
   PORTAL_BASE_URL updated; all 3 helper scripts re-pointed at the new cluster.
   Relay envelope to for-next-live-tester/ dropped alongside this one.
3. **Old service deleted from mb-next-keep** (scaled 0 → delete, DRAINING).
   mb-next-keep back to keep-stack-only.
4. Note: fresh task = fresh portal store; the earlier smoke row is gone —
   live-tester first-run counts start clean.
5. **Standing by** for your ping after next-dev-bbotfix merges the BS-2 fix →
   I redeploy EFs/migration on staging (~5 min).
