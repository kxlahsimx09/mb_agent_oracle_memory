---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: OWNER WANTS A STABLE IP — give the SIM mock-bank portal (:4925) a fixed ingress that survives task restart (owner picked Elastic IP over ALB)
priority: high
created: 2026-06-11T19:40:00+07:00
needs_response: true
---

# Stable ingress for the mock-bank portal — owner picked "Elastic IP"

Problem: the SIM portal runs on the Fargate task `mb-next-bankbot-sim` (cluster mb-next-bankbot) with `assignPublicIp=ENABLED`, so its public IP **rotates on every task restart** (the SP3 crash-restart leg + any redeploy). Owner keeps losing the URL — currently 3.1.218.84:4925 (was 13.229.141.73, was 18.x…). Owner asked for an **Elastic IP** (preferred over an ALB).

## Heads-up — the Fargate constraint (don't chase a dead end)

A Fargate task's ENI is AWS-managed; you **cannot associate an EIP directly onto the task ENI** the way you can on an EC2 instance. The standard way to get a *fixed IP* in front of Fargate is a **Network Load Balancer with Elastic IP(s) attached** (one EIP per AZ subnet), target-type `ip`, forwarding TCP :4925 to the task. ALB gives stable DNS but NOT a stable IP — owner explicitly wants the IP, so NLB+EIP is the fit. If you know a lighter sanctioned path that yields a genuinely static IP, use it and say why; otherwise NLB+EIP.

## Task

1. **Confirm the mechanism** (NLB + EIP, target-type ip, listener TCP 4925 → portal). Decide 1 AZ (single subnet/EIP — cheapest, fine for a SIM viewer) vs multi-AZ.
2. **Draft the exact IAM delta** the one-time-grant managed policy `mb-next-bankbot-deploy` needs (it currently has NO elasticloadbalancing or EIP perms) — e.g. `elasticloadbalancing:*` scoped where possible, `ec2:AllocateAddress`/`AssociateAddress`/`DescribeAddresses`/`ReleaseAddress`, plus any NLB/target-group/listener actions. Write it as a ready-to-apply policy-version + the verbatim command, the way you did the first IAM ask — the owner applies it (one-time-grant can't self-grant; owner uses a temp admin/root key, CloudShell is in 2-day review).
3. On policy-apply ping: **implement** — allocate EIP, create NLB with the EIP, target group (ip), register the running task, listener :4925; confirm `curl http://<EIP>:4925/` → 200 and that it survives a task replacement (the EIP/NLB stays put while the task IP behind it churns).
4. Update next-ui + next-live-tester slots + me with the **stable URL** (http://<EIP>:4925). Update the mock-portal docs/slot so future runs use the stable ingress, not the per-task IP.

## Guardrails

- Don't disrupt the running golden-journey stack mid-change if a live run is in flight (coordinate — campaign is already certified GREEN, so a brief portal blip is acceptable, but say so before bouncing the service).
- SIM-only; the portal auth is still the `X-Sim-Control-Secret` (control plane) + simviewer/simviewer-pass (scrape login) — exposing a stable public :4925 is acceptable for a SIM viewer, but note the security posture in your reply.
- Cost: an idle NLB + 1 EIP is a few USD/mo — flag it so the owner can tear down post-demo if desired.

Reply → for-orchestrator/ + thread #13: the IAM delta for the owner first, then (post-apply) the stable URL + restart-survival proof.

handled_at: 2026-06-11T19:57:00+07:00
handled_by_thread: 13 (msg 114)
handled_by_inbox: for-orchestrator/2026-06-11_19-55_from-brew-ops_thread-13_reply-iam-delta-portal-stable-ip.md
handled_note: phase 1 (IAM delta) delivered; phase 2 (NLB+EIP build) awaits owner apply-ping — tracked
