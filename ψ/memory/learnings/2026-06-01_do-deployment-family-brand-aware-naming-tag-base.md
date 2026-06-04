---
title: DO deployment family brand-aware naming + tag-based lookup migration (bank-bot, 
tags: [technical-writer, repo:bank-bot, current, deployment, do, scripts, brand, naming, tag-based-lookup, create-bot, install-preventive-restart]
created: 2026-06-01
source: scripts/do/create-bot.sh:118-135,169,320@3880bd0; scripts/do/install-preventive-restart.sh:88-99,229-237@3ff2751; docs/current-system.md §5.3
project: github.com/kokarat/bank-bot
---

# DO deployment family brand-aware naming + tag-based lookup migration (bank-bot, 

DO deployment family brand-aware naming + tag-based lookup migration (bank-bot, 2026-05-31, commits 3880bd0 + 3ff2751).

`do/create-bot.sh` now REQUIRES `--brand` (whitelist {ampay, maxpayplus, goodpay}) and a BANK_TYPE tag (scb/ktb/kbank/bbl). The Droplet name changed from `bank-bot-<account>` to `<brand>-<bank_type>-<account>` (e.g. maxpayplus-scb-4102508550), matching the AWS family's Name-tag convention, and a `brand-<brand>` tag is stamped alongside the existing bank-bot / account-<n> / <bank_type> tags. `--brand` is stripped from argv before positional parsing so it can appear anywhere.

The ops scripts destroy/stop/restart/install-preventive-restart/bot-uptime switched from name-regex enumeration (`doctl --format Name | grep '^bank-bot-' | sed 's/^bank-bot-//'`) to tag-based lookup (`doctl --tag-name bank-bot --format Tags`, parse account out of the account-<n> tag, skip brand-*). This works for BOTH legacy bank-bot-<n> Droplets and new <brand>-<bank_type>-<n> Droplets because every Droplet carries the account-<n> tag regardless of name — so the migration is non-breaking for un-renamed legacy droplets. destroy-bot.sh additionally looks up by tag_name=account-<n> and aborts if >1 Droplet shares that tag (brand-collision guard).

Follow-up 3ff2751 fixed two rollout bugs in install-preventive-restart.sh: (1) --brand was leaking into the positional TARGETS list (treated as an account → no_droplet), now stripped like create-bot.sh; (2) the account→bank_code map (used only for KTB-window timer selection) dropped its status:1 Mongo filter — during initial fleet rollout every system_banks account starts status:0 and only flips to 1 after operator verification, so the filter was hiding brand-new KTB accounts from window detection. Map now reads all rows.

DO per-brand env example renamed youpay → maxpayplus (.env.do.maxpayplus.example, API_URL=https://api.maxpayplus.tech) — DO-side companion to the AWS rename PR #127/3afee6d.

Documented in docs/current-system.md §5.3 (Brand-aware naming note + DO table) + §8 DRIFT-2(c) (CLAUDE.md's `create-bot.sh 4102508550` example now exits 1 since --brand is required). Tags: technical-writer, repo:bank-bot, current, deployment, do, scripts, brand, naming, tag-based-lookup, create-bot, install-preventive-restart.

---
*Added via Oracle Learn*
