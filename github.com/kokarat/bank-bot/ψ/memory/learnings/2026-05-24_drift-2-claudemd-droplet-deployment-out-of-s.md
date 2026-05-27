---
title: DRIFT-2 (CLAUDE.md "Droplet Deployment" § out of sync with scripts/) extended by
tags: [technical-writer, repo:bank-bot, current, drift, deployment, claude-md-gap, scripts-restructure, aws]
created: 2026-05-24
source: docs/current-system.md §8 DRIFT-2; CLAUDE.md:295-297@8e78dbb
project: github.com/kokarat/bank-bot
---

# DRIFT-2 (CLAUDE.md "Droplet Deployment" § out of sync with scripts/) extended by

DRIFT-2 (CLAUDE.md "Droplet Deployment" § out of sync with scripts/) extended by W2 pass fdab647..8e78dbb (PR #120 amend, commit #122). #122 introduced a NEW dangling reference: CLAUDE.md line 296 still lists scripts/do/setup-droplet.sh, but the SAME #122 commit DELETED that script — its first sub-commit rewrote the path scripts/setup-droplet.sh → scripts/do/setup-droplet.sh, its third sub-commit dropped the file without removing the CLAUDE.md line. Result: CLAUDE.md points at a file that no longer exists. Separately, the previously-tracked set-password.sh / reset-droplet-password.sh / migrate-bank-codes.js / test-{scb,ktb}-bank-dropdown.js were all deleted by #122, so they fall off the "absent from CLAUDE.md" list (gone → moot). Still genuinely unlisted in CLAUDE.md: install-vector.sh, restart-bot.sh, stop-bot.sh, bot-uptime.sh, install-preventive-restart.sh, and the entire scripts/aws/ family (8 scripts incl #122's new install-preventive-restart.sh + aws/README.md). CLAUDE.md's Droplet Deployment § remains DigitalOcean-only and names no AWS path, --brand layout, or .env.aws*/.env.do* template files. Two fixes a future CLAUDE.md edit (or W4) should make: (1) drop the setup-droplet.sh bullet, (2) add the AWS family + the unlisted DO helpers + the env/ convention. Recorded in docs/current-system.md §8 DRIFT-2 (code loc bumped scripts/*@8e78dbb; CLAUDE.md:295-297@8e78dbb). Queued for W4.

---
*Added via Oracle Learn*
