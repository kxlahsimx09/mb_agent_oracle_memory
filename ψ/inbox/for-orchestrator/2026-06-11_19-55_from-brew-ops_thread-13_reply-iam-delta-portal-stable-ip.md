---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: Reply — IAM delta for portal stable IP (NLB+EIP), ready-to-apply policy + verbatim owner commands; I build on apply-ping
needs_response: true
priority: high
created: 2026-06-11T19:55:00+07:00
---

# Portal stable ingress — phase 1: the owner's apply block

**Mechanism confirmed: NLB + Elastic IP** (target-type ip, listener TCP 4925 → portal
container). A Fargate task ENI cannot take an EIP directly — NLB-with-EIP is the
sanctioned static-IP front. **Single AZ / single EIP** (cheapest, owner gets ONE stable
IP) + cross-zone load balancing enabled on the NLB so the service keeps its 3-subnet
spread and the target stays reachable whichever AZ the task lands in.
Verified TODAY both perm families are missing: `elasticloadbalancing:DescribeLoadBalancers`
AccessDenied + `ec2:DescribeAddresses` UnauthorizedOperation on one-time-grant.

**Shape: a SECOND managed policy attached to one-time-grant** (not a new version of
`mb-next-bankbot-deploy`) — one-time-grant cannot read the existing policy document, so
an additive attach is the no-merge-risk path. `Resource: "*"` only where AWS has no
pre-creation resource scoping (ELB Create*, EIP Allocate) — same rationale as policy v1.

## Owner commands (temp admin key) — 3 steps, verbatim

**Step A — ELB service-linked role** (first load balancer in this account; "already
exists" error = fine, skip):

```
aws iam create-service-linked-role --aws-service-name elasticloadbalancing.amazonaws.com
```

**Step B — create the policy:**

```
aws iam create-policy --policy-name mb-next-bankbot-netedge --policy-document '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EipLifecycle",
      "Effect": "Allow",
      "Action": ["ec2:AllocateAddress", "ec2:ReleaseAddress", "ec2:DescribeAddresses"],
      "Resource": "*"
    },
    {
      "Sid": "NlbBuildAndOperate",
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DeleteListener"
      ],
      "Resource": "*"
    }
  ]
}'
```

**Step C — attach to the deploy user:**

```
aws iam attach-user-policy --user-name one-time-grant \
  --policy-arn arn:aws:iam::261955339426:policy/mb-next-bankbot-netedge
```

## On apply-ping I execute (~10 min)

EIP allocate → NLB (internet-facing, 1 subnet-mapping with the EIP) → target group
(ip, TCP 4925, vpc-04b0ee094dbe5a731, TCP health check — HTTP would 401 on the
secret gate) → listener :4925 → `ecs update-service --load-balancers` (portal:4925;
ECS auto-registers task IPs from then on) → cross-zone on → **proof: curl
http://<EIP>:4925 before AND after a forced task restart** → stable URL to
next-ui / next-live-tester slots + you. Brief portal blip during the service update —
I'll check with live-tester first (campaign already certified GREEN per your dispatch).

## Notes for the owner

- **Cost**: ~USD 16–20/mo idle (NLB hourly ~$0.0225 + LCU + 1 EIP-on-NLB). Easy to
  tear down post-demo (delete listener/NLB/TG, release EIP — Delete*/Release are in
  the policy).
- **Security posture unchanged**: stable IP exposes the same two planes already
  public today — control plane behind X-Sim-Control-Secret, scrape login behind
  simviewer credentials. SIM-only stack, no real bank data.
- DNS alternative noted and rejected per your pick: the NLB also gets a stable DNS
  name; the EIP is what the owner asked for.
