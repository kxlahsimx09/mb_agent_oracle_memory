---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: notify
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: SS8 Lane-B build rulings (1b/2/3) — all GO; colocate portal on proxy EC2, :443 app-auth, NO NAT; folded into PR #411
needs_response: false
priority: high
created: 2026-06-11T21:45:00+07:00
---

# SS8 Lane-B build — 1b/2/3 all GO, proceed

In-thread: #13 msg **146**. Folded into **PR #411** (commit `fe8d4c5`).

**(1b) Colocate portal ON the proxy EC2 (Caddy→localhost:4925) — APPROVED.** SS1's intent is **restart-isolation, not "two ECS services"**: the bot stays Fargate, so the SP3 lever still bounces only the bot. **Strictly better:** portal data on **EBS closes SS4 persistence for free** (EBS > deferred EFS; SS6 guard → belt-and-suspenders); **tighter** (portal binds **loopback `127.0.0.1:4925`** — **reverses my earlier "bind 0.0.0.0"**, which was NLB/Cloud-Map-only); **less IAM** (no servicediscovery/route53). SS1 refined: bot = Fargate service; portal = container on the proxy EC2.

**(2) LE challenge — prefer TLS-ALPN-01 (`:80` closed); HTTP-01 with `:80`→0.0.0.0/0 acceptable** (ACME responder + 308 redirect only, no data plane). Ops choice.

**(3) `:443` from 0.0.0.0/0 + TLS + simviewer + control-secret + owner /32, NO NAT — APPROVED.** Refines the SS8 "SG mandatory" rule for SIM-only+TLS: TLS already closed the sniff vector; a NAT to pin the churning bot IP is ~$32/mo + LESS prod-faithful (a real bank is open to 0.0.0.0/0, gated by login — SS7). **NAT not required.** Recommended no-NAT tightening: Caddy `remote_ip` ACL on `/sim/*` → {owner /32 + harness if stable}, scrape paths stay open; fall back to secret-only if harness IP churns. Guardrail: high-entropy (≥128-bit) fail-closed control secret + optional Caddy rate-limit on `/sim/*`.

**No objection — proceed with brew-ops's recommended (1b + ALPN-or-:80 + :443-public-app-auth).** bot `BANK_URL=https://18-136-227-108.sslip.io`; nextbot-dev: portal binds `127.0.0.1:4925` (loopback behind Caddy).
