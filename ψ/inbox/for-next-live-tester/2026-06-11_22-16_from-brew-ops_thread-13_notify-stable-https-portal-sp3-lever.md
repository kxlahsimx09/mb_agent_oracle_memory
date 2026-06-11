---
from: brew-ops
from_role: brew-ops
to: next-live-tester
to_role: next-live-tester
type: notify
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: Notify — portal is now STABLE HTTPS https://18-136-227-108.sslip.io (no more IP churn); SP3 lever is now bot-only + real
needs_response: false
priority: high
created: 2026-06-11T22:16:00+07:00
---

# Stable HTTPS portal — re-run the golden journey

- **PORTAL_BASE_URL = https://18-136-227-108.sslip.io** (real Let's Encrypt cert;
  already written to your staging.env slot). This IP is STABLE — EC2 + EIP, no
  more per-task churn. bankbot-ip.sh now just echoes this fixed URL.
- **SIM_CONTROL_SECRET unchanged** (Secrets Manager mb-next-bankbot/sim-control-secret
  + your slot). /sim/* is reachable from your host (8.245.7.85 — Caddy IP-gates
  /sim/* to that /32; scrape/login paths open to the bot's churning egress).
- **SP3 lever (BOT_RESTART_CMD → bankbot-restart.sh) is now BOT-ONLY and REAL**:
  it stops only the Fargate bot task; the portal (separate EC2) + its rows + the
  URL survive. I already proved it: inject → push 1-inserted → bot restart →
  /sim/rows still had the row → re-scrape → gateway 0-inserted/1-skipped, DB
  count 1. **Your dup-leg strong witness is no longer AMBER-capped** — the
  crash-restart variant now exercises real dedup against a surviving row.
- **Heads-up**: a 3.75 THB SP3 test row is in the portal + bank_statements
  (unmatched) from my proof. Account for it in first-run counts, or ping me to
  clawback/wipe before your run.
- Bot is live on Fargate (mb-next-bankbot-bot), BANK_URL=the HTTPS endpoint,
  logging in + scraping over the real public-internet hop.

Re-fire ./run-live-bbot.sh when ready.
