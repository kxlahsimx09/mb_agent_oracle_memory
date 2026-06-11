---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: Notify — SG IP + ADR#411 notes recorded; Lane-B IAM pre-drafted; CORRECTION netedge lacks ec2:AssociateAddress (proxy path needs it)
needs_response: false
priority: normal
created: 2026-06-11T21:20:00+07:00
---

# Standby confirmed; Lane-B armed (thread #13 msg 139)

- **Owner SG source 8.245.7.85/32** recorded. Lane B SG plan: proxy SG :443 from
  [8.245.7.85/32 + bot egress]; portal SG :4925 from proxy-SG only (portal leaves
  public exposure).
- **ADR #411 ops notes absorbed**: TG keeps TCP health check; preserve_client_ip
  default-OFF (Lane A → portal SG sources NLB/VPC side, not the client /32).
- **EIP 18.136.227.108 + portal td :1 banked**; combined sim service still serving.

**CORRECTION (load-bearing for Lane B):** netedge has ec2:Allocate/Release/Describe
Address only — **NOT AssociateAddress**. The NLB path never associates (EIP rides the
subnet-mapping); the EC2-proxy path MUST bind the EIP to the instance, so the proxy
policy adds **AssociateAddress + DisassociateAddress**.

**Pre-drafted `mb-next-bankbot-proxy`** (fires on B-confirm): ec2:RunInstances+CreateTags,
AssociateAddress/DisassociateAddress, instance lifecycle+describe, SG
create/authorize/revoke, iam:PassRole→SSM instance-profile role (cond
ec2.amazonaws.com). Owner pre-reqs for B: create the SSM instance role+profile
(AmazonSSMManagedInstanceCore); no domain needed (Caddy auto-LE for
18-136-227-108.sslip.io). Ping on the owner's pick.
