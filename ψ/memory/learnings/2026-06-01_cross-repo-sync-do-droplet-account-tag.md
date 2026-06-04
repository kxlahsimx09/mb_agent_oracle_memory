---
title: cross-repo-sync — DO droplet lookup moved from name pattern to account-<N> tag (mobiz #503 ↔ bank-bot DO rename)
tags: [technical-writer, repo:cross, current, bank-bot, cross-repo-sync]
created: 2026-06-01
source: services/botHostLocator.go:40-118@d821ec8
project: github.com/kokarat/mobiz-payment-gateway
---

Shared contract surface: how the backend's **Restart Bot** action resolves the VM hosting a bank-bot on DigitalOcean.

- **bank-bot side** (trace `dd879d35`, W2 `baee633..3ff2751`, 2026-06-01): DO droplet fleet migrated from name `bank-bot-<account>` to brand-aware `<brand>-<bankType>-<account>` (e.g. `ampay-scb-4192118234`) + tag-based lookup; `create-fleet.sh` + `migrate-rename-legacy.sh` carry the rename. Every droplet (legacy + new) now carries an `account-<N>` per-account tag.
- **mobiz side** (`d821ec8` #503, 2026-05-31): `services/botHostLocator.go` `doLocator.FindBotHost` stopped matching `droplet.Name == "bank-bot-<account>"` (which 502'd on every DO-hosted bot after the rename) and now scans `droplet.Tags` for `account-<accountNumber>`. Added `Tags []string` to `doDroplet`. `BotHost.Name` is now informational only. Mirrors `awsLocator`'s tag-based approach (`tag:Account` + `tag:Role`).

Trace link: mobiz W2 `d50e5bea` ← bank-bot W2 `dd879d35` (cross-repo sibling, linked 2026-06-01). The two W2 passes landed the same day for the same reason (DO naming → tag migration). Documented in `mobiz/docs/current-system.md` §6.7 (botHostLocator bullet). bot-writer's flow/host docs should reflect the brand-aware naming + account-tag lookup if they cite droplet names.
