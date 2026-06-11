# Runbook — bank-bot SIM infra (Lane B: EC2 TLS proxy + colocated portal + Fargate bot)

**Owner:** brew-ops · **Created:** 2026-06-11 (thread #13 campaign close) · **Account:** 261955339426 / ap-southeast-1 / profile `mb-next-setup` (user `one-time-grant`)

SIM-only test infra for the mb-next-bank-bot golden-journey. No real bank data, no production credentials. Built Lane B (EC2+EIP+Caddy+Let's Encrypt) because this AWS account **cannot create load balancers** (`OperationNotPermitted` — new-account restriction; see Known follow-ups).

## Topology

```
client/harness ──https──> 18-136-227-108.sslip.io (EIP 18.136.227.108)
                            └─ EC2 t4g.nano i-0d96a92a6035b46f1 (AL2023 arm64)
                               ├─ Caddy :443 (LE cert, TLS-terminate) ──> 127.0.0.1:4925
                               └─ portal (node systemd) :4925 loopback, data on EBS
bot (Fargate) ──https BANK_URL──> same EIP  (real public-internet scrape hop)
bot ──push──> gateway staging EFs (sinuwgsqqyqzlpaavimf)  [separate stack, not torn down here]
```

## Components

| Thing | Identifier | Notes |
|---|---|---|
| **Stable portal URL** | `https://18-136-227-108.sslip.io` | real Let's Encrypt cert; login page at `/` |
| Portal EC2 | `i-0d96a92a6035b46f1` t4g.nano, AL2023 arm64 | holds the EIP; Caddy + portal colocated |
| Elastic IP | `18.136.227.108` = `eipalloc-0c41350730622e99b` | stable; survives instance stop/start (NOT terminate) |
| Proxy SG | `sg-0102adf38ae9a7c69` | :443 + :80 from 0.0.0.0/0 (:80 = ACME only) |
| Subnet / VPC | `subnet-00026d76147b39096` / `vpc-04b0ee094dbe5a731` | public subnet |
| Caddy | `/etc/caddy/Caddyfile`, systemd `caddy.service` | TLS via LE; `/sim/*` gated to `8.245.7.85/32` |
| Portal | `/opt/portal/{server,store,pages}.js`, systemd `portal.service` | canonical source commit `c5d0430`; pure Node, no npm/ECR |
| Portal env | `/etc/portal.env` | HOST=127.0.0.1, PORT=4925, SIM_* creds, SIM_DATA_FILE |
| Portal data | `/var/lib/portal/sim-rows.jsonl` (EBS) | append-only; replayed at boot → survives portal restart |
| **Bot service** | cluster `mb-next-bankbot`, service `mb-next-bankbot-bot`, td `mb-next-bankbot-bot:1` | Fargate; SG `sg-09785fe6d3f2cb843`; `BANK_URL=https://18-136-227-108.sslip.io` |
| ECR repo | `261955339426.dkr.ecr.ap-southeast-1.amazonaws.com/mb-next-bank-bot` | bot container image (sim variant); tags `sim-latest`/`realbank-latest`. Portal does NOT use ECR. |
| Secrets Manager | `mb-next-bankbot/sim-control-secret`, `/bot-key`, `/bot-key-secret` | control-plane secret + the bot's §ADR-7 BK credential |
| IAM (on `one-time-grant`) | `mb-next-bankbot-deploy`, `mb-next-bankbot-netedge`, `mb-next-bankbot-ec2` | -deploy=ECS/ECR/secrets/logs; -netedge=ELB/EIP (ELB unused); -ec2=EC2 proxy build |
| SSM role | role+instance-profile `mb-next-bankbot-proxy-ssm` (AmazonSSMManagedInstanceCore) | the EC2 instance profile |
| Build script | `~/.arra-oracle-v2/fleet-secrets/mb-next-bank-bot/bin/ec2proxy-build.sh` | rebuilds the proxy idempotent-ish |
| Helpers | same dir: `bankbot-ip.sh` (echoes URL), `bankbot-logs.sh` (bot CloudWatch), `bankbot-restart.sh` (bot-only SP3) | |

## Operate

- **Health:** `curl https://18-136-227-108.sslip.io/` → SCB login page (200).
- **Control plane (owner/harness IP only):** `curl https://18-136-227-108.sslip.io/sim/rows -H "X-Sim-Control-Secret: <secret>"`. Secret in Secrets Manager `mb-next-bankbot/sim-control-secret` + the live-tester slot. `/sim/*` is Caddy-IP-gated to `8.245.7.85/32` (owner + fleet-host share that egress) → 403 from elsewhere; scrape/login paths (`/`, `/api/*`) are open (the bot's egress churns).
- **Bot logs:** `bash bankbot-logs.sh` (uses `aws logs get-log-events` on `bot/bot/<task>` — the deploy user lacks `logs:FilterLogEvents`, so `aws logs tail` won't work).
- **Portal logs (on the box):** `journalctl -u portal -u caddy` via SSM Session Manager (the instance is SSM-managed; the deploy user lacks `ssm:StartSession`, so connect from a console/role that has it).
- **Inject a test row:** `POST /sim/inject` `{"amount":N,"type":"in"}` with the control secret.

## SP3 restart semantics (load-bearing)

**Restart the BOT service ONLY.** `bash bankbot-restart.sh` (or `aws ecs stop-task` on the bot task). The portal is on a SEPARATE EC2 box, so a bot restart does NOT wipe portal rows — the bot re-scrapes the still-present row and the gateway dedups (`0 inserted, 1 skipped`). NEVER restart the portal to exercise SP3 — that empties the ledger and the dup-leg holds trivially (the pre-split bug this topology fixed). Portal own-restart is survivable too (EBS-backed JSONL replays at boot).

## Security posture

Stable IP exposes the same two planes a real public bank portal does: scrape/login behind `simviewer`/`simviewer-pass`, control/inject behind `X-Sim-Control-Secret` (≥128-bit, fail-closed — the portal refuses to boot without it). `/sim/*` additionally IP-gated at Caddy. :80 serves only the ACME challenge + 308→https. No real bank data, no gateway credentials on this box. IMDSv2 required on the instance.

## Cost (~USD/mo, while running)

t4g.nano ~$3 + EIP free-while-associated + bot Fargate (0.25 vCPU/0.5 GB) ~$6 + 3 Secrets Manager secrets ~$1.2 + ECR storage negligible. **≈ $10–12/mo.** Scale the bot service to 0 between test windows to cut the Fargate share.

## TEARDOWN (ordered — run on disband)

```bash
R=ap-southeast-1; P=mb-next-setup
# 1. bot Fargate service
aws ecs update-service --cluster mb-next-bankbot --service mb-next-bankbot-bot --desired-count 0 --region $R --profile $P
aws ecs delete-service --cluster mb-next-bankbot --service mb-next-bankbot-bot --region $R --profile $P
# 2. portal EC2 (releases the EBS data volume on terminate)
aws ec2 terminate-instances --instance-ids i-0d96a92a6035b46f1 --region $R --profile $P
aws ec2 wait instance-terminated --instance-ids i-0d96a92a6035b46f1 --region $R --profile $P
# 3. EIP (disassociates on terminate; release to stop the idle charge)
aws ec2 release-address --allocation-id eipalloc-0c41350730622e99b --region $R --profile $P
# 4. proxy SG (after the instance is gone)
aws ec2 delete-security-group --group-id sg-0102adf38ae9a7c69 --region $R --profile $P
# 5. Secrets Manager (force or schedule)
for s in sim-control-secret bot-key bot-key-secret; do \
  aws secretsmanager delete-secret --secret-id mb-next-bankbot/$s --force-delete-without-recovery --region $R --profile $P; done
# 6. ECR repo (only if not reused elsewhere)
aws ecr delete-repository --repository-name mb-next-bank-bot --force --region $R --profile $P
# 7. IAM — OWNER (admin key; one-time-grant can't self-detach)
#    detach mb-next-bankbot-deploy/-netedge/-ec2 from one-time-grant, delete the policies,
#    remove role from instance-profile + delete role mb-next-bankbot-proxy-ssm + the profile.
# 8. ECS cluster mb-next-bankbot — delete if empty. DO NOT touch mb-next-keep (§ADR-15 keep stack).
```
Gateway-side (migrations 100/110/200, the 5 bot EFs, `BOT_CRED_ENC_KEY`, GW4 keys, the staging Supabase project `sinuwgsqqyqzlpaavimf`) is a SEPARATE stack owned by the gateway team — NOT part of this teardown.

## Known follow-ups

- **AWS Support case to enable ELB is UN-OPENED.** The "standard" ingress (NLB + ACM cert + Route53) is blocked until that account-capability flag is lifted. If/when opened, a future migration NLB+EIP→portal-service is available; the `mb-next-bankbot-netedge` IAM policy already covers it. Until then, Lane B (this runbook) is the ingress.
- **sslip.io dependency:** the cert/hostname depend on the public sslip.io wildcard-DNS service. For a longer-lived stack, register a real domain and re-issue (Caddy auto-handles a new hostname; update the bot `BANK_URL` + the Caddy site label).
- **Deploy user has no console/SSM/log-filter perms** — debugging the EC2 box needs a role with `ssm:StartSession` or `ec2:GetConsoleOutput` (see the Lane-B build learning for the cloud-init `:8080` log-server debug trick).

**Cross-refs:** thread #13 · learnings `2026-06-11_lane-b-...static-ip-https-ingress`, `2026-06-11_aws-account-261955339426...` (ELB block), `2026-06-11_gw4-staging-drift...` · §ADR-21 §Amendment 2026-06-11 (SP1–SP7 + SS1–SS8).
