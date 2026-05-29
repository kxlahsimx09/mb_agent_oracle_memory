---
title: bank-bot brand rename youpay → maxpayplus across both cloud deployment families 
tags: [technical-writer, repo:bank-bot, current, deployment, scripts, aws, do, brand, maxpayplus, rename, env-contract]
created: 2026-05-27
source: scripts/aws/create-bot.sh:122@3afee6d; scripts/aws/env/.env.aws.maxpayplus.example@3afee6d; docs/current-system.md §5.3
project: github.com/kokarat/bank-bot
---

# bank-bot brand rename youpay → maxpayplus across both cloud deployment families 

bank-bot brand rename youpay → maxpayplus across both cloud deployment families (PR #127 / 3afee6d, 2026-05-28). Every brand whitelist and error/usage message in scripts/do/{create,stop,restart,bot-uptime,install-preventive-restart}.sh and scripts/aws/{create,stop,restart,bot-uptime,install-preventive-restart}.sh plus scripts/do/README.md + scripts/aws/README.md now reads "ampay, maxpayplus, goodpay" (previously "ampay, youpay, goodpay"). This catches the bot side up to backend #484 which renamed envs/youpay/ → envs/maxpayplus/ (canonical brand name after the youpay.vip → ampay-cluster alias cutover). The per-brand AWS env template was renamed with it: scripts/aws/env/.env.aws.youpay.example → .env.aws.maxpayplus.example, and its API_URL is now https://api.maxpayplus.tech. No youpay whitelist entry remains in any script. The install-preventive-restart.sh scripts got ONLY the whitelist string change in this commit — the commit's "pass --brand to install-preventive-restart.sh" point is a .claude/skills instruction change (the --brand flag already existed in the scripts). Documented in docs/current-system.md §5.3 (cross-cutting brand-rename bullet + the two inline whitelist mentions at the DO and AWS family). No new CLAUDE.md/README drift — neither names brands, so DRIFT-2 already covers the deployment-section desync.

---
*Added via Oracle Learn*
