---
title: AWS account 261955339426 (mb-next, ap-southeast-1) CANNOT create Elastic Load Ba
tags: [brew-ops, repo:cross, aws, fargate, elb, gotcha, deploy, bank-bot]
created: 2026-06-11
source: thread #13 stable-IP build; aws elbv2 create-load-balancer 2026-06-11 ~20:30 GMT+7
project: github.com/kxlahsimx09/mb-next-bank-bot
---

# AWS account 261955339426 (mb-next, ap-southeast-1) CANNOT create Elastic Load Ba

AWS account 261955339426 (mb-next, ap-southeast-1) CANNOT create Elastic Load Balancers — `aws elbv2 create-load-balancer` returns `OperationNotPermitted: This AWS account currently does not support creating load balancers. For more information, please contact AWS Support.` This is the standard NEW-ACCOUNT ELB restriction, an account-capability flag, NOT an IAM/perms problem: the mb-next-bankbot-netedge policy was applied and elasticloadbalancing:Describe* + ec2:DescribeAddresses both work. Only an AWS Support case lifts it (typically 1–2 business days).

Implication for the bank-bot SIM portal stable-IP work (thread #13, 2026-06-11): the architect-sanctioned NLB+EIP static-ingress path is BLOCKED until the account is enabled. EIP allocation itself works (allocated 18.136.227.108 / eipalloc-0c41350730622e99b) but a Fargate task ENI cannot take an EIP directly, so the EIP is useless without either (a) an NLB front [blocked], (b) an EC2 proxy holding the EIP and forwarding to the portal [needs ec2:RunInstances — a 2nd IAM delta], or (c) Cloud Map internal DNS [no public static IP; architect rejected for prod-fidelity].

General rule for this account: before promising any ELB/ALB/NLB-based design (ingress, stable IP, blue-green), verify `create-load-balancer` actually works on a throwaway name — Describe perms succeeding does NOT prove Create is allowed. If you need a static public IP in front of Fargate here and the ELB block is live, the EC2-proxy+EIP pattern is the only self-serviceable path (everything else needs AWS Support).

---
*Added via Oracle Learn*
