---
title: Drift: CLAUDE.md "Droplet Deployment" section (line 295) and the create-bot.sh u
tags: [technical-writer, repo:bank-bot, current, drift, claude-md-drift, readme-drift, create-bot, deployment, private-repo-auth]
created: 2026-04-28
source: CLAUDE.md:80,295; README.md:250,348; scripts/create-bot.sh:110-123@4b968a4
project: github.com/kokarat/bank-bot
---

# Drift: CLAUDE.md "Droplet Deployment" section (line 295) and the create-bot.sh u

Drift: CLAUDE.md "Droplet Deployment" section (line 295) and the create-bot.sh usage example in CLAUDE.md "Commands" (line 80, `DO_TOKEN=xxx API_URL=... BOT_SECRET=xxx ./scripts/create-bot.sh 4102508550`) are now incomplete after PR #108 / 4b968a4. The default repo (https://github.com/kokarat/bank-bot.git) is private; `create-bot.sh` now exits 1 in pre-flight unless one of GH_TOKEN, BOT_GIT_REPO (with embedded creds), or ALLOW_ANONYMOUS_CLONE=1 is set. Anyone copy-pasting CLAUDE.md's command will hit the new fail-fast and have to re-read the script to learn the missing env var. Same gap exists in README.md sections that show `./scripts/create-bot.sh <ACCOUNT>` without naming GH_TOKEN/BOT_GIT_REPO. Queued for W4 to update CLAUDE.md + README usage examples in a single drift-reconcile pass; W2 of 2026-04-29 deliberately stayed out of scope per "do not silently sweep drift in W2" rule.

---
*Added via Oracle Learn*
