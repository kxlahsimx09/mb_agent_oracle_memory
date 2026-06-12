---
title: Fargate bank-bot SIM image: playwright base-image/lockfile version drift crashes
tags: [brew-ops, repo:cross, deploy, fargate, playwright, gotcha, bank-bot]
created: 2026-06-11
source: thread #13 Fargate deploy, CloudWatch /ecs/mb-next-bankbot, commit 85150c7
project: github.com/kxlahsimx09/mb-next-bank-bot
---

# Fargate bank-bot SIM image: playwright base-image/lockfile version drift crashes

Fargate bank-bot SIM image: playwright base-image/lockfile version drift crashes the bot at every tick.

Symptom: bot container boots, fetches bot-config fine, then every poll tick logs `browserType.launch: Executable doesn't exist at /ms-playwright/chromium_headless_shell-…` (Playwright "Please update docker image" banner). Container stays RUNNING (loop catches the error), so ECS shows healthy while the bot does zero work — check CloudWatch, not container status.

Root cause: Dockerfile pinned `mcr.microsoft.com/playwright:v1.49.0-jammy` while package.json had `playwright: ^1.49.0` and package-lock.json had drifted to 1.58.2. `npm install --omit=dev` honors the lock → npm-level 1.58.2 looks for its own browser build, absent from the v1.49.0 base.

Fix (commit 85150c7 on ci/build-push-ecr, rides PR #4): bump base image tag to v1.58.2-jammy to match the lock. Durable rule: the playwright base-image tag and the lockfile version MUST move together; pin exact (not ^) or add a CI assertion comparing `jq .packages[\"node_modules/playwright\"].version package-lock.json` to the FROM tag.

Ops gotchas from the same deploy: (1) `aws logs tail` needs logs:FilterLogEvents which the mb-next-bankbot-deploy policy lacks — use `aws logs get-log-events --log-stream-name bot/bot/<task-id>`; (2) per-task public IP changes on every task replacement (no ALB) — resolve via ENI: describe-tasks → networkInterfaceId → describe-network-interfaces .Association.PublicIp (helper: fleet-secrets/mb-next-bank-bot/bin/bankbot-ip.sh).

---
*Added via Oracle Learn*
