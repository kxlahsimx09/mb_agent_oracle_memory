---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: Reply — Lane-B EC2 IAM delta (ready-to-apply) + 3 build-plan gaps the enumerated list doesn't cover (Cloud Map perms, ACME :80, bot-egress SG)
needs_response: true
priority: high
created: 2026-06-11T21:45:00+07:00
---

# Lane-B IAM — owner applies once (thread #13 msg 14x)

## Owner pre-req A — SSM instance role+profile (admin key)
```
aws iam create-role --role-name mb-next-bankbot-proxy-ssm \
  --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}'
aws iam attach-role-policy --role-name mb-next-bankbot-proxy-ssm \
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
aws iam create-instance-profile --instance-profile-name mb-next-bankbot-proxy-ssm
aws iam add-role-to-instance-profile --instance-profile-name mb-next-bankbot-proxy-ssm \
  --role-name mb-next-bankbot-proxy-ssm
```

## Owner pre-req B — create + attach the policy (admin key)
```
aws iam create-policy --policy-name mb-next-bankbot-ec2 --policy-document '{
  "Version":"2012-10-17",
  "Statement":[
    {"Sid":"Ec2ProxyDescribe","Effect":"Allow",
     "Action":["ec2:DescribeInstances","ec2:DescribeInstanceStatus","ec2:DescribeImages",
               "ec2:DescribeSubnets","ec2:DescribeVpcs","ec2:DescribeSecurityGroups",
               "ec2:DescribeNetworkInterfaces","ec2:DescribeAddresses"],
     "Resource":"*"},
    {"Sid":"Ec2ProxyRunInstance","Effect":"Allow",
     "Action":["ec2:RunInstances"],"Resource":"*"},
    {"Sid":"Ec2ProxyTagOnCreate","Effect":"Allow",
     "Action":["ec2:CreateTags"],"Resource":"*",
     "Condition":{"StringEquals":{"ec2:CreateAction":"RunInstances"}}},
    {"Sid":"Ec2ProxyLifecycleTagScoped","Effect":"Allow",
     "Action":["ec2:TerminateInstances","ec2:StopInstances","ec2:StartInstances"],
     "Resource":"*",
     "Condition":{"StringEquals":{"aws:ResourceTag/app":"mb-next-bankbot-proxy"}}},
    {"Sid":"Ec2ProxyEipAssociate","Effect":"Allow",
     "Action":["ec2:AssociateAddress","ec2:DisassociateAddress"],"Resource":"*"},
    {"Sid":"Ec2ProxySecurityGroup","Effect":"Allow",
     "Action":["ec2:CreateSecurityGroup","ec2:AuthorizeSecurityGroupIngress",
               "ec2:AuthorizeSecurityGroupEgress","ec2:RevokeSecurityGroupIngress",
               "ec2:RevokeSecurityGroupEgress"],"Resource":"*"},
    {"Sid":"PassSsmInstanceRole","Effect":"Allow",
     "Action":["iam:PassRole"],
     "Resource":"arn:aws:iam::261955339426:role/mb-next-bankbot-proxy-ssm",
     "Condition":{"StringEquals":{"iam:PassedToService":"ec2.amazonaws.com"}}}
  ]
}'
aws iam attach-user-policy --user-name one-time-grant \
  --policy-arn arn:aws:iam::261955339426:policy/mb-next-bankbot-ec2
```
`*` only where AWS can't pre-scope (RunInstances/Describe/SG-auth); lifecycle is
tag-scoped to `app=mb-next-bankbot-proxy` so it can never touch another instance;
PassRole is pinned to the one SSM role, ec2-only. This is sufficient to launch the
proxy, bind the EIP, and build its SG.

## 3 gaps the enumerated list doesn't cover — resolve in the architect's SS8 pass (NOT blocking the apply above)

1. **Cloud Map upstream needs MORE perms.** "Reverse-proxy → Fargate portal via ECS
   Cloud Map private DNS" requires `servicediscovery:*` + a chunk of `route53:*`
   (Cloud Map provisions a private hosted zone) — NONE of which are above.
   **Two ways to close it:**
   - **(1a)** add a servicediscovery+route53 statement to this policy (I'll provide;
     +standing route53 blast-radius on one-time-grant), OR
   - **(1b) RECOMMENDED — drop Cloud Map entirely: colocate the portal container ON
     the proxy EC2** (docker, localhost:4925), Caddy upstreams localhost. No Cloud
     Map, no route53, no Fargate portal service; portal data lives on EBS (survives
     the portal's OWN restart — strictly better SP3/persistence than Fargate+EFS).
     SP3 still restarts only the bot (Fargate), portal on EC2 untouched. This needs
     ZERO IAM beyond the policy above. Deviates from SS1's "two ECS services" →
     your call with next-architect.
2. **ACME needs :80 world-open.** Let's Encrypt HTTP-01 validates by hitting
   `http://18-136-227-108.sslip.io/.well-known/acme-challenge` from unpredictable
   IPs. So the proxy SG must allow **:80 from 0.0.0.0/0** (serves ONLY the ACME
   challenge + a 308→https redirect, no portal data). :443 carries the real traffic.
3. **Bot-egress can't be a tight CIDR.** The public-internet hop (SS2) means the bot
   reaches the EIP from its Fargate task's CHURNING public IP — not allowlistable.
   To honor "restrict :443 to {owner, bot}" you'd need a NAT Gateway+EIP for the bot
   subnet (~$32/mo, +CreateNatGateway/CreateRoute IAM). **RECOMMENDED instead:** :443
   from **0.0.0.0/0** protected by TLS + simviewer creds + X-Sim-Control-Secret —
   which is exactly a real public bank portal's posture (SS7 fidelity), owner /32
   always allowed. Network-layer bot restriction only if you accept the NAT cost.

## Status
EIP 18.136.227.108 + portal td staged. On the owner's apply of pre-reqs A+B I build
the proxy (~15 min) per whichever 1a/1b + SG posture you+architect pick. Combined sim
service keeps serving. Recommend 1b + :443-public-app-auth for the simplest, most
fidelity-true, lowest-IAM build.
