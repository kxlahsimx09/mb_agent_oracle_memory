---
title: bank-bot gained a parallel AWS EC2 deployment script family (scripts/*-aws.sh + 
tags: [technical-writer, repo:bank-bot, current, deployment, aws, ec2, scripts, elastic-ip]
created: 2026-05-23
source: scripts/create-bot-aws.sh@9245f3f
project: github.com/kokarat/bank-bot
---

# bank-bot gained a parallel AWS EC2 deployment script family (scripts/*-aws.sh + 

bank-bot gained a parallel AWS EC2 deployment script family (scripts/*-aws.sh + README-AWS.md, PR #119 / 9245f3f, 2026-05-24) alongside the untouched DigitalOcean scripts — both clouds run side by side; AWS is for new deployments that require Thai-region IPs. AWS targets ap-southeast-7 (Bangkok) with Elastic IPs so a bank-whitelisted public IP survives stop/start cycles. Seven scripts mirror their DO counterparts 1:1 (create/destroy/list/update-all/restart/stop/bot-uptime). Key differences from the DO family: EC2 Name tag is <bank_type>-<account> (e.g. scb-8888000000) not DO's bank-bot-<account>; sizing mirrors create-bot.sh 1:1 (KTB→t3.medium 4GB, else→t3.small 2GB), BANK_TYPE whitelisted so a typo can't under-size KTB; SSH user is ubuntu+sudo (Ubuntu 24.04 AMI) not root, cloud-init chowns /opt/bank-bot to ubuntu so git pull / npm install need no sudo; EIP lifecycle uses an AutoRelease=true tag so destroy-bot-aws.sh disassociates-then-releases ONLY EIPs it created and refuses to steal an attached EIP — --keep-eip (destroy) + --eip <id> (create) preserve a whitelisted IP across recreate. stop-bot-aws.sh stops bank-bot-restart.timer first (same preventive-restart invariant as DO stop-bot.sh). Documented in docs/current-system.md §5.3 (AWS sub-block) + §6 External integrations.

---
*Added via Oracle Learn*
