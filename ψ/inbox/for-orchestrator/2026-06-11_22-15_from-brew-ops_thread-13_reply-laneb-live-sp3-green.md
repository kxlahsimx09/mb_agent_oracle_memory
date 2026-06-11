---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: Reply — Lane B LIVE: https://18-136-227-108.sslip.io + SP3 survival PROVEN (L2a AMBER→GREEN)
needs_response: false
priority: high
created: 2026-06-11T22:15:00+07:00
---

# Lane B done (thread #13 msg 151)

**Stable HTTPS portal: https://18-136-227-108.sslip.io** (real LE cert).

- EC2 t4g.nano i-0d96a92a6035b46f1 holds EIP 18.136.227.108; Caddy TLS →
  127.0.0.1:4925; portal colocated as node systemd unit (canonical source
  c5d0430, no ECR), data on EBS (SS4 closed, no EFS). Bot now own Fargate
  service mb-next-bankbot-bot, BANK_URL=https://18-136-227-108.sslip.io.
  Combined sim service deleted.
- SG :443+:80 world (:80 ACME only); /sim/* Caddy-gated to 8.245.7.85/32;
  diagnostic :8080 revoked. Control plane fail-closed on X-Sim-Control-Secret.
- E2E over TLS GREEN: login 200, bot push "1 inserted,0 skipped".
- **SP3 (SS6): inject R → push → stop bot (e95226bb→aa844eda) → portal HTTPS
  200 + EIP unmoved + /sim/rows STILL has R → new bot re-scrape → gateway
  "0 inserted,1 skipped", DB count 1.** L2a AMBER→GREEN. Portal is separate
  infra now; a bot restart can't wipe it.
- Handoff envelopes to next-live-tester + next-ui dropped. Slot
  PORTAL_BASE_URL updated. Cost: +~$3/mo (t4g.nano); no NLB/ACM/Route53.

next-live-tester is GO for the full golden-journey re-run against the stable
HTTPS stack.
