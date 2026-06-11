---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: Reply — TLS scope: NO team domain found + ELB still account-blocked; ACM-IAM delta + a Caddy/EIP path that clears BOTH blockers
needs_response: true
priority: high
created: 2026-06-11T21:05:00+07:00
---

# STEP 1 domain finding + IAM (thread #13 msg 13x)

## Domain reality (probed)
- **No Route53 hosted zone** (and one-time-grant lacks route53:ListHostedZones).
- **No team-owned real apex**: midasgoteam.com / .io return NO NS = unregistered.
- **workers.dev is unusable**: `*.midasgoteam.workers.dev` is Cloudflare's SHARED
  Workers domain — you cannot point an A-record there at the EIP.
- CF token can't enumerate zones (bad-header / Workers-scoped) — can't confirm any
  real CF domain from my creds.
- **sslip.io works**: `18-136-227-108.sslip.io` → 18.136.227.108 (verified). A free,
  valid-TLS hostname needing zero domain ownership.

**Conclusion: no domain we control today.** Either the owner provides a real
registered domain (and says where its DNS lives), or we use sslip.io.

## Two STACKED blockers on the architect's NLB+ACM (SS8) design
1. **ELB still account-blocked** (my msg 133) — the TLS listener lives on the NLB;
   `create-load-balancer` = OperationNotPermitted until an AWS Support case lifts it.
2. **ACM needs a domain you control** for validation — it CANNOT issue for sslip.io
   or a bare IP. So NLB+ACM requires BOTH the ELB-unblock AND a real domain. Neither
   is in hand.

## IAM delta netedge still lacks for the NLB+ACM path (ready-to-apply)
Third additive policy (one-time-grant can't read existing docs → attach, don't merge):

```
aws iam create-policy --policy-name mb-next-bankbot-tls --policy-document '{
  "Version":"2012-10-17",
  "Statement":[
    {"Sid":"AcmForNlbTls","Effect":"Allow",
     "Action":["acm:RequestCertificate","acm:DescribeCertificate",
               "acm:ListCertificates","acm:DeleteCertificate",
               "acm:AddTagsToCertificate"],
     "Resource":"*"},
    {"Sid":"Route53OnlyIfDomainInR53","Effect":"Allow",
     "Action":["route53:ListHostedZones","route53:ChangeResourceRecordSets",
               "route53:GetChange"],
     "Resource":"*"}
  ]
}'
aws iam attach-user-policy --user-name one-time-grant \
  --policy-arn arn:aws:iam::261955339426:policy/mb-next-bankbot-tls
```
(`elasticloadbalancing:CreateListener` is already in netedge — no ELB add. Route53
block is needed ONLY if the domain is hosted in Route53; if it's on Cloudflare, drop
that statement and the owner does manual CNAME cert-validation instead.)

## Recommended alternative — clears BOTH blockers, realizes SS8's HTTPS intent
**EC2 micro-proxy (Caddy) + the EIP**, TLS terminated on the instance:
- Caddy auto-provisions a **Let's Encrypt** cert for the hostname (works with
  **sslip.io today**, or a real domain later) — no ACM, no Route53, **no NLB** →
  the account ELB block + the no-domain problem BOTH vanish.
- Bot `BANK_URL = https://18-136-227-108.sslip.io`. Portal stays plain :4925 and can
  drop public exposure entirely — only the proxy is internet-facing (tighter than
  NLB→plain-portal).
- Cost ~$3–4/mo t4g.nano. Needs a **2nd IAM delta** (ec2:RunInstances +
  iam:PassRole for an SSM instance profile + ec2:AssociateAddress[have]) — I'll
  draft it netedge-style on your nod. Internal proxy→portal upstream = ECS Cloud Map
  private DNS (the PUBLIC hop stays real-internet HTTPS, so SS2 fidelity holds; only
  the proxy's internal leg uses DNS). **Flag for next-architect**: this terminates
  TLS on a proxy instead of the NLB — same external https://host→portal:4925
  contract; needs a quick SS8 ratification.

## Owner actions needed (pick a lane)
- **Lane A (architect's NLB+ACM as-is):** (1) open AWS Support case to enable ELB;
  (2) provide a real domain + confirm its DNS home; (3) apply mb-next-bankbot-tls
  (+route53 stmt only if R53-hosted); (4) be ready to add the ACM validation record.
- **Lane B (Caddy/EIP, recommended):** (1) approve the EC2-proxy IAM delta I'll
  draft; (2) optionally provide a real domain, else we use sslip.io. No Support case,
  no ACM, no NLB.
- **Either lane:** send the **owner source IP/CIDR** for the restrictive SG.

## Build status
EIP 18.136.227.108 + portal td `mb-next-bankbot-portal:1` staged. NLB / TLS listener
/ 2-service split NOT built — all gated on the lane choice; **holding the listener
entirely** (no cleartext interim — can't put a listener on an un-creatable NLB, and
cleartext would contradict the TLS-from-start decision). Combined sim service still
serving; GREEN stack untouched. I build the chosen lane in ~15 min once unblocked.
