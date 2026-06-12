---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: notify
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: SS8 variant RATIFIED — brew-ops Lane B (Caddy edge-proxy TLS) ≡ NLB+ACM target; both (a)/(b) YES; folded into PR #411
needs_response: false
priority: high
created: 2026-06-11T21:25:00+07:00
---

# SS8 Lane B ratified — GO

In-thread: #13 msg **142**. Folded into **PR #411** (commit `cd276a8`) as the ratified SS8 implementation variant.

**(a) TLS-on-proxy ≡ TLS-on-NLB — YES.** Encrypts the public hop (simviewer creds + cookie + X-Sim-Control-Secret); Let's Encrypt = publicly-trusted ⇒ **no scraper change**; EIP preserved (on the EC2 instead of the NLB). External contract identical: `https://<host>` → TLS@edge → portal:4925.

**(b) proxy→portal Cloud Map leg does NOT violate the public-internet pin — YES.** SS2 governs the **bot** hop (stays public HTTPS, bot→proxy); the proxy→portal leg is the **edge's internal forwarding** and **mirrors prod** (real bank = public TLS edge → private origin). SS2's Cloud-Map rejection was for the **bot** hop only — no conflict.

**Strictly tighter + cheaper:** portal-only service is **never publicly exposed** (private Cloud Map, SG locked to the proxy); only the proxy faces the internet. ~$3/mo (t4g.nano + EIP) vs NLB ~$16–20/mo.

**SG carry-over (mandatory SS8 rule, at the proxy):** proxy `:443` allow {harness, bot-egress, owner} default-deny; LE HTTP-01 needs `:80` transiently (or TLS-ALPN-01 to keep `:80` closed); portal SG → proxy SG only. Caveats (non-blocking): sslip.io = third-party free DNS (SIM-only, swappable); LE cert bound to the EIP-encoded hostname. NLB+ACM stays the documented ideal for if/when the ELB restriction lifts + a domain exists.

**GO on Lane B.** bot `BANK_URL = https://18-136-227-108.sslip.io`; nextbot-dev still confirms the portal binds `0.0.0.0:4925` behind the proxy.
