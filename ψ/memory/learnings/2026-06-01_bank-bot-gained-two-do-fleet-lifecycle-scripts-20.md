---
title: bank-bot gained two DO fleet-lifecycle scripts (2026-05-31): create-fleet.sh (48
tags: [technical-writer, repo:bank-bot, current, deployment, do, scripts, brand, fleet, create-fleet, migrate-rename]
created: 2026-06-01
source: scripts/do/create-fleet.sh@4834f0c; scripts/do/migrate-rename-legacy.sh@3880bd0; docs/current-system.md §5.3
project: github.com/kokarat/bank-bot
---

# bank-bot gained two DO fleet-lifecycle scripts (2026-05-31): create-fleet.sh (48

bank-bot gained two DO fleet-lifecycle scripts (2026-05-31): create-fleet.sh (4834f0c, 302 LoC) + migrate-rename-legacy.sh (3880bd0, 193 LoC).

create-fleet.sh bulk-creates a whole brand's fleet from system_banks: resolves the brand's read-only Mongo URI (mongodb-public-read-uri → mongodb-read-uri from backend/k8s/envs/<brand>/secrets.yaml), queries system_banks filterable by --status / --only-method, sorted by sort_order, then loops create-bot.sh --brand <brand> <account> <region> <bank_type> per account. Idempotent: accounts whose account-<n> tag already exists in DO are skipped; unsupported bank codes listed as invalid. Dry-run by default; --apply prints a cost preview ($6/mo SCB s-2vcpu-2gb, $12/mo KTB s-2vcpu-4gb) and requires typing the brand name to confirm. Paces 3s between creates to stay under DO's 5 req/s soft cap.

migrate-rename-legacy.sh is the inverse: one-shot idempotent rename of legacy bank-bot-<account> Droplets to <brand>-<bank_type>-<account> + attach brand-<brand> tag. Fetches all bank-bot-tagged droplets, skips already-renamed, warns on missing/mismatched account-*/bank-type tags, and in --apply submits a DO rename droplet-action + tags/brand-<brand>/resources attach (creating the tag first to dodge a 422). BRAND defaults to ampay; pass --brand and run once per brand. Zero-downtime — DO rename does not restart the droplet.

Both are companions (new-fleet rollout vs legacy rename). Documented in docs/current-system.md §5.3 DO table (now 11 DO scripts, 19 shell total). Tags: technical-writer, repo:bank-bot, current, deployment, do, scripts, brand, fleet, create-fleet, migrate-rename.

---
*Added via Oracle Learn*
