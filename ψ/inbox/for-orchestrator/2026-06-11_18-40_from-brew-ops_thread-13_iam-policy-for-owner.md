---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: handoff
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: thread #13 — IAM (option 1, attach to one-time-grant) — verbatim least-privilege policy + roles + CI push, owner applies
priority: high
needs_response: true
created: 2026-06-11T18:40:00+07:00
---

# Bank-bot Fargate IAM — owner applies verbatim (option 1: attach to `one-time-grant`)

Account **261955339426** · region **ap-southeast-1**. One consolidated least-privilege policy on user **`one-time-grant`** covers BOTH the host deploy (profile `mb-next-setup`) AND the GitHub-Actions ECR push (same user's keys, per your choice). Resource names: ECR repo `mb-next-bank-bot`, cluster `mb-next-keep`, roles `mb-next-bankbot-exec` / `mb-next-bankbot-task`, secrets prefix `mb-next-bankbot/`, log-group `/ecs/mb-next-bankbot`.

Run all of this with an **admin** principal (one-time-grant can't grant to itself).

## 1. ECR repo + the two task roles (Fargate assumes these)
```bash
aws ecr create-repository --repository-name mb-next-bank-bot \
  --image-scanning-configuration scanOnPush=true --region ap-southeast-1

cat > task-trust.json <<'J'
{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ecs-tasks.amazonaws.com"},"Action":"sts:AssumeRole"}]}
J
aws iam create-role --role-name mb-next-bankbot-exec --assume-role-policy-document file://task-trust.json
aws iam attach-role-policy --role-name mb-next-bankbot-exec \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
aws iam put-role-policy --role-name mb-next-bankbot-exec --policy-name read-bankbot-secrets \
  --policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":"secretsmanager:GetSecretValue","Resource":"arn:aws:secretsmanager:ap-southeast-1:261955339426:secret:mb-next-bankbot/*"}]}'
aws iam create-role --role-name mb-next-bankbot-task --assume-role-policy-document file://task-trust.json
# task role needs no app perms for SIM (empty).
```

## 2. The deploy+CI policy — attach to `one-time-grant`
```bash
aws iam put-user-policy --user-name one-time-grant \
  --policy-name mb-next-bankbot-deploy --policy-document file://bankbot-deploy.json
```
`bankbot-deploy.json` (least-privilege; `*` only where AWS forbids resource-scoping — auth-token, RegisterTaskDefinition, ec2:Describe*):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    { "Sid": "EcrAuth", "Effect": "Allow", "Action": "ecr:GetAuthorizationToken", "Resource": "*" },
    { "Sid": "EcrRepoPushPull", "Effect": "Allow",
      "Action": ["ecr:DescribeRepositories","ecr:DescribeImages","ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer","ecr:BatchGetImage","ecr:InitiateLayerUpload","ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload","ecr:PutImage"],
      "Resource": "arn:aws:ecr:ap-southeast-1:261955339426:repository/mb-next-bank-bot" },
    { "Sid": "EcsTaskDef", "Effect": "Allow",
      "Action": ["ecs:RegisterTaskDefinition","ecs:DeregisterTaskDefinition","ecs:DescribeTaskDefinition"],
      "Resource": "*" },
    { "Sid": "EcsClusterRead", "Effect": "Allow", "Action": "ecs:DescribeClusters",
      "Resource": "arn:aws:ecs:ap-southeast-1:261955339426:cluster/mb-next-keep" },
    { "Sid": "EcsServiceOnKeep", "Effect": "Allow",
      "Action": ["ecs:CreateService","ecs:UpdateService","ecs:DeleteService","ecs:DescribeServices",
        "ecs:DescribeTasks","ecs:ListTasks","ecs:TagResource"],
      "Resource": "*",
      "Condition": { "ArnEquals": { "ecs:cluster": "arn:aws:ecs:ap-southeast-1:261955339426:cluster/mb-next-keep" } } },
    { "Sid": "PassTaskRoles", "Effect": "Allow", "Action": "iam:PassRole",
      "Resource": ["arn:aws:iam::261955339426:role/mb-next-bankbot-exec",
                   "arn:aws:iam::261955339426:role/mb-next-bankbot-task"],
      "Condition": { "StringEquals": { "iam:PassedToService": "ecs-tasks.amazonaws.com" } } },
    { "Sid": "Secrets", "Effect": "Allow",
      "Action": ["secretsmanager:CreateSecret","secretsmanager:PutSecretValue","secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret","secretsmanager:TagResource"],
      "Resource": "arn:aws:secretsmanager:ap-southeast-1:261955339426:secret:mb-next-bankbot/*" },
    { "Sid": "Logs", "Effect": "Allow",
      "Action": ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents","logs:DescribeLogGroups"],
      "Resource": "arn:aws:logs:ap-southeast-1:261955339426:log-group:/ecs/mb-next-bankbot*" },
    { "Sid": "NetworkRead", "Effect": "Allow",
      "Action": ["ec2:DescribeVpcs","ec2:DescribeSubnets","ec2:DescribeSecurityGroups","ec2:DescribeNetworkInterfaces"],
      "Resource": "*" },
    { "Sid": "SecurityGroupCreate", "Effect": "Allow",
      "Action": ["ec2:CreateSecurityGroup","ec2:AuthorizeSecurityGroupIngress","ec2:CreateTags"],
      "Resource": "*" }
  ]
}
```
> If `CreateService` is rejected on the `ecs:cluster` Condition (ECS resource-level is partial on some accounts), drop the `Condition` block on `EcsServiceOnKeep` — everything else stays scoped.

## 3. CI push leg (GitHub Actions → ECR)
**Chosen (per your pick): same `one-time-grant` user via repo secrets** — the policy above already grants ECR push.
```bash
aws iam create-access-key --user-name one-time-grant   # capture AccessKeyId + SecretAccessKey
gh secret set AWS_ACCESS_KEY_ID --repo kxlahsimx09/mb-next-bank-bot --body <AccessKeyId>
gh secret set AWS_SECRET_ACCESS_KEY --repo kxlahsimx09/mb-next-bank-bot --body <SecretAccessKey>
```
> **Recommend instead (more secure, no long-lived keys): GitHub OIDC role.** If you'd rather, I'll swap the workflow to `aws-actions/configure-aws-credentials@v4` with `role-to-assume` — needs a one-time OIDC provider + a `mb-next-bankbot-ci` role trusting `repo:kxlahsimx09/mb-next-bank-bot:*` (I have the trust JSON ready). Say the word and I send it; otherwise CI uses the keys above.

## What I need back
1. **CI role/keys done** → tell me (or the access-key pair is in repo secrets) so the workflow's first push runs.
2. **Gateway staging** (your target): point me at the staging creds slot for migrations `20260611000100/110` + the `BOT_KEY` mint via #398, and the gateway-staging **API base URL** for the bot's `API_URL`.
3. Confirm cluster `mb-next-keep` OK to host the service.

The GitHub Actions build workflow (sim + real-bank targets → ECR) is going up as a repo PR now; deploy runs the moment the policy lands + the first image digest exists.

— brew-ops, 2026-06-11
