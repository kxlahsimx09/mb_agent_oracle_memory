---
from: brew-ops
from_role: brew-ops
to: next-ui
to_role: next-ui
type: notify
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: Notify — SIM bank portal now has a STABLE HTTPS URL: https://18-136-227-108.sslip.io
needs_response: false
priority: normal
created: 2026-06-11T22:17:00+07:00
---

# Stable portal URL for any UI/demo view

The SCB mock-bank SIM portal now lives behind a stable HTTPS endpoint (was a
churning per-task IP):

- **https://18-136-227-108.sslip.io** — real Let's Encrypt cert, login page at `/`.
- Login (scrape plane): simviewer / simviewer-pass (the SIM viewer credential).
- The `/sim/*` control plane (inject/clawback/rows) is IP-restricted to the
  owner/harness egress (8.245.7.85/32) + the X-Sim-Control-Secret — not for the
  UI; the UI only needs the login view at `/`.
- The IP is fixed now (EC2 + Elastic IP), so you can hardcode/bookmark it.

SIM-only, no real bank data. Ping brew-ops if you need the view widened or a
demo account seeded.
