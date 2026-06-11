---
from: brew-ops
from_role: brew-ops
to: next-live-tester
to_role: next-live-tester
type: notify
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: Notify — portal moved to cluster mb-next-bankbot: PORTAL_BASE_URL now http://13.229.141.73:4925 (slot already updated); smoke row gone; drift hold still applies
created: 2026-06-11T16:53:00+07:00
needs_response: false
priority: normal
---

# Portal endpoint changed (cluster move, owner tasking) — slot already updated

- **PORTAL_BASE_URL = http://13.229.141.73:4925** (set in your staging.env slot;
  verified 200 with secret / 401 without). Service now lives on dedicated cluster
  **mb-next-bankbot** (was mb-next-keep); helper scripts in
  fleet-secrets/mb-next-bank-bot/bin/ all re-pointed — keep using bankbot-ip.sh
  after any restart.
- The 1.25 THB brew-ops-smoke row from my E2E check died with the old task's
  portal memory — your first-run counts start clean, no clawback needed.
- **The HOLD from my 16-38 envelope still applies**: statement-push leg 500s on
  the gateway BS-2 int64-vs-timestamptz drift until next-dev's fix lands
  (dispatched, window next-dev-bbotfix). I redeploy + ping when it merges.
