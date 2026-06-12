---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: notify
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: ADR PR #411 OPEN (arch/adr21-sp3split) — §ADR-21 SS1–SS8; folded owner NO-EFS (SS6 guard load-bearing) + SS8 TLS/SG ingress posture; route next-code-reviewer
needs_response: false
priority: high
created: 2026-06-11T21:05:00+07:00
---

# ADR PR open — SS1–SS8, reviewer-gated

**PR #411** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/411 — branch `arch/adr21-sp3split` off main, `docs/adr.md` only (+30/−1; kept off the live working tree as asked). In-thread: #13 msg **129**. Route next-code-reviewer.

**Folded your two follow-ups:**
1. **NO-EFS-for-now** → SS4 = EFS recommended-not-blocking; the **SS6 portal-generation guard is now load-bearing** (SP3 run asserts portal task generation/startedAt/ARN unchanged across the run → an incidental portal bounce can't pass as a dedup proof).
2. **SS8 ingress crypto+SG** (nextbot-dev cleartext finding): **TLS at the NLB + ACM cert on a small hostname is the realism-OPTIMAL target** (real banks are HTTPS — TLS advances realism); EIP preserved ⇒ **ALB-HTTPS REJECTED** (loses the static IP); publicly-trusted cert ⇒ no scraper change. **SG source-restriction mandatory either way** — concrete spec for brew-ops: inbound `:4925` allow ONLY {harness egress IP, bot egress IP, owner IP}, default-deny; pin the bot source via a **NAT-Gateway EIP** (ephemeral per-task IP churns on every SP3 restart). Control plane `/sim/*` (no prod analogue) stays **double-gated** (X-Sim-Control-Secret ∩ SG). **Cleartext gate-acceptable ONLY with the SG rule** (SIM-only blast radius); never cleartext without SG. Recommend TLS.

brew-ops build = 2 services + NLB+EIP→portal-only + bot BANK_URL(TLS host) + the SG rule + BOT_RESTART_CMD→bot-only (EFS deferred). nextbot-dev confirms `0.0.0.0:4925` bind. next-live-tester runs SS6; investigator L3 unchanged. Handoff artifact: `next-architect_sp3split_amendment.md`.
