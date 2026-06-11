---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: blocker
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: BLOCKER — account cannot create load balancers (OperationNotPermitted), NLB path needs AWS Support case; EIP+portal-td staged, 3 paths for owner
needs_response: true
priority: high
created: 2026-06-11T20:35:00+07:00
---

# NLB build blocked account-level — owner decision needed (thread #13 msg 133)

`aws elbv2 create-load-balancer` → **OperationNotPermitted: "This AWS account
currently does not support creating load balancers. Contact AWS Support."**
New-account ELB restriction — NOT perms (netedge applied; Describe* work, you
verified). Stopped, no retry-loop.

**Banked (reusable, zero teardown, campaign stack untouched):**
- EIP **18.136.227.108** (eipalloc-0c41350730622e99b, unassociated, ~$3.6/mo idle)
  — the pre-announced stable URL once an ingress exists.
- Task-def `mb-next-bankbot-portal:1` registered. Bot td built but not registered
  (placeholder BANK_URL — useless until EIP routes).
- Combined `mb-next-bankbot-sim` still running + serving; nothing disrupted.

**Owner decision — 3 paths (detail in msg 133):**
1. **AWS Support case** to enable ELB on acct 261955339426 (~1–2 biz days) →
   I build NLB+EIP exactly per SS3, everything staged. *Recommended.*
2. **EC2-micro-proxy + EIP** (no ELB): t4g.nano holds the EIP, forwards :4925 →
   portal. Same prod-fidelity public hop. Needs a **2nd IAM delta**
   (ec2:RunInstances + instance-profile) which I'll draft netedge-style; ~$3–4/mo.
3. **Cloud Map internal-DNS stopgap**: closes the SP3 split+dedup GATE now, defer
   public-internet fidelity, swap BANK_URL→EIP later. *Architect rejected Cloud
   Map for fidelity* — only if you want the gate closed before the ticket clears.

**Also need from owner:** their **source IP/CIDR** — to scope the restrictive SG
(:4925 from [bot-SG + owner-CIDR], not 0.0.0.0/0) per your coordination note. I
have the bot-egress side; missing the owner IP. Portal already binds 0.0.0.0:4925
(proven by external curls), so nextbot-dev's bind question is settled.

Recommend path 1 in parallel with picking 2-vs-3. Ping with the choice (+ owner CIDR).
