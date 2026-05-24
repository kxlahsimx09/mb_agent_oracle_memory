---
title: `services/botHostLocator.go` (NEW `7e239a5` #454, 2026-05-22) introduces `BotHos
tags: [technical-writer, repo:mobiz-payment-gateway, current, service, bot-ops, aws-migration, provider-abstraction, ssh-restart]
created: 2026-05-21
source: services/botHostLocator.go:1-161@7e239a5, services/botOpsService.go:84-138@7e239a5
project: github.com/kokarat/mobiz-payment-gateway
---

# `services/botHostLocator.go` (NEW `7e239a5` #454, 2026-05-22) introduces `BotHos

`services/botHostLocator.go` (NEW `7e239a5` #454, 2026-05-22) introduces `BotHostLocator` interface with two implementations (`doLocator`, `awsLocator`) so `BotOpsService` stays provider-neutral over its SSH + `systemctl` path. `BotHost{Name, ID, IP}` is the provider-neutral identifier. `doLocator` uses `GET https://api.digitalocean.com/v2/droplets?tag_name=bank-bot&per_page=200` + `Authorization: Bearer DO_TOKEN`, matches by `name=="bank-bot-<account>"`, picks first public-v4. `awsLocator{region}` loads `aws-sdk-go-v2` default credential chain (env + IAM-role) at the configured `AWS_REGION` (defaults `ap-southeast-1`), runs `ec2.DescribeInstances` with filters `tag:Name=bank-bot-<account>` AND `instance-state-name=running`. Dispatch lives in `BotOpsService.locatorFor(provider)`: empty/`"digitalocean"`/`"do"` → DO; `"aws"`/`"ec2"` → AWS; anything else errors with `"unknown cloud provider …"`. Adding a third provider is now a single new struct that satisfies the interface plus one switch arm.

---
*Added via Oracle Learn*
