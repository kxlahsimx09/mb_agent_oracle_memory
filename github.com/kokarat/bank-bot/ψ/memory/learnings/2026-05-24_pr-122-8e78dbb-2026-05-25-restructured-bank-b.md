---
title: PR #122 / 8e78dbb (2026-05-25) restructured bank-bot's flat scripts/ into per-cl
tags: [technical-writer, repo:bank-bot, current, deployment, scripts, aws, do, restructure, env-autosource, multi-brand]
created: 2026-05-24
source: scripts/@8e78dbb (do/ + aws/ split); docs/current-system.md §5.3
project: github.com/kokarat/bank-bot
---

# PR #122 / 8e78dbb (2026-05-25) restructured bank-bot's flat scripts/ into per-cl

PR #122 / 8e78dbb (2026-05-25) restructured bank-bot's flat scripts/ into per-cloud folders: 9 DO scripts under scripts/do/, 8 AWS scripts under scripts/aws/ (the -aws suffix stripped, so create-bot-aws.sh → aws/create-bot.sh), plus 3 navigation READMEs (scripts/README.md, do/README.md, aws/README.md) and a gitignored env/ template dir per cloud (*.example only). Dropped: setup-droplet.sh, set-password.sh, reset-droplet-password.sh, and the whole old shared/ folder (migrate-bank-codes.js + test-{scb,ktb}-bank-dropdown.js). Added: scripts/aws/install-preventive-restart.sh — the AWS port of the preventive-restart timer installer (targets via `aws ec2 describe-instances` tag filters instead of doctl; SSH as ubuntu+sudo; bank type from the BankType EC2 tag; deposit <BRAND> mode = Mongo status==1 & method==deposit intersected with AWS Brand+Account tags; same 2h INTERVAL timer + KTB 07..19/2 BKK OnCalendar window variant + TimeoutStopSec=60). Cross-cutting behaviors added to every script: (1) auto-source sibling env/.env.<cloud> at startup via `set -a; . file; set +a` (no-op if missing) — AWS create-bot.sh additionally auto-sources env/.env.aws.<brand> AFTER --brand is parsed, so operators no longer source two files by hand; (2) REPO_ROOT recomputed 2 levels up ($SCRIPT_DIR/../..) to repair the backend k8s-secrets path ($REPO_ROOT/../backend/k8s/envs/$brand/secrets.yaml) broken by the new do/ nesting; (3) symmetric brand-scoped target modes — active <BRAND> on restart/stop/bot-uptime, deposit <BRAND> on install-preventive-restart (brand whitelist ampay/youpay/goodpay, ALLOW_UNKNOWN_BRAND=1 bypass, mongosh required); (4) 3-tier Mongo URI priority mongodb-public-read-uri (public DNS, works from a local Mac) → mongodb-read-uri (private DNS, DOKS-only) → mongodb-uri (doadmin RW, last resort). All §5 deployment territory, no bot-code change. Documented in docs/current-system.md §5.3 (rewritten: header 17 shell + 3 READMEs no Node helpers; new cross-cutting bullets; DO + AWS tables with do/aws paths) + §6 AWS line + §8 DRIFT-2. W2 amend extending PR #120 to cumulative fdab647..8e78dbb; trace 2dd8467c chained from f4c3c580. Step 2c no cross-repo signal (no mobiz flow doc cites any bank-bot script; pure deployment ops, no shared contract).

---
*Added via Oracle Learn*
