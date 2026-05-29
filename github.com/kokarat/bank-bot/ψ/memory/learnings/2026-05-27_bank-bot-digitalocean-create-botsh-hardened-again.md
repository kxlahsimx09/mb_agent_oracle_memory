---
title: bank-bot DigitalOcean create-bot.sh hardened against a post-create public-IP rac
tags: [technical-writer, repo:bank-bot, current, deployment, scripts, do, digitalocean, create-bot, ip-race, robustness]
created: 2026-05-27
source: scripts/do/create-bot.sh:296-330@3afee6d; docs/current-system.md §5.3
project: github.com/kokarat/bank-bot
---

# bank-bot DigitalOcean create-bot.sh hardened against a post-create public-IP rac

bank-bot DigitalOcean create-bot.sh hardened against a post-create public-IP race (PR #127 / 3afee6d, 2026-05-28). The old scripts/do/create-bot.sh fetched the new Droplet's IP with a fixed `sleep 15` followed by `python3 -c "...[n['ip_address'] for n in nets if n['type']=='public'][0]"`. When DigitalOcean had not attached the public IPv4 within 15 s (bursts, regional load), the list comprehension was empty, `[0]` raised IndexError, and because the script runs under `set -e` the whole script died with exit 1 — leaving the Droplet actually up but the caller reporting failure (a half-success that confused batch provisioning). The fix replaces it with a 24-iteration × 5 s poll loop (up to 2 min), wraps the JSON parse in try/except returning '' on any error, breaks as soon as a non-empty IP appears, and if none arrives after 2 min prints a graceful "droplet is up but look it up manually: doctl compute droplet get <ID>" message instead of crashing. LoC grew 328 → 349; the new poll loop is at scripts/do/create-bot.sh:296-330. AWS create-bot.sh was not affected (its IP path differs). Documented in docs/current-system.md §5.3 DO create-bot.sh table row.

---
*Added via Oracle Learn*
