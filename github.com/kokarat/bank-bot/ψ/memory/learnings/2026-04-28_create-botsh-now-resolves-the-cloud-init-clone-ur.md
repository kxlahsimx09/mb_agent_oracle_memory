---
title: create-bot.sh now resolves the cloud-init clone URL with three-tier auth precede
tags: [technical-writer, repo:bank-bot, current, track-commit, deployment, create-bot, private-repo-auth, cloud-init, fail-fast, credential-masking]
created: 2026-04-28
source: scripts/create-bot.sh:33-58,110-123,132-135@4b968a4
project: github.com/kokarat/bank-bot
---

# create-bot.sh now resolves the cloud-init clone URL with three-tier auth precede

create-bot.sh now resolves the cloud-init clone URL with three-tier auth precedence — BOT_GIT_REPO (full pre-built URL with `@<creds>`) → GH_TOKEN injected into the default HTTPS URL → unauthenticated default. A pre-flight check fails fast with a 3-option message when the resolved URL has no embedded `@<creds>` and the caller has not opted in via ALLOW_ANONYMOUS_CLONE=1, saving the 2-minute cloud-init round-trip and the half-set-up Droplet (Node + Xvfb installed, no app, no systemd unit) that two SCB creates hit before being recovered manually over ssh. The displayed repo URL is masked (`https://***@host/...`) so pasted logs don't leak the token; the unmasked URL is still embedded into the cloud-init body. SSH-form URLs (`git@github.com:...`) are intentionally unsupported by the auto-injection path — pass BOT_GIT_REPO explicitly when using a deploy key. Verified at scripts/create-bot.sh:33-58,110-123,132-135@4b968a4. PR #108, 2026-04-29.

---
*Added via Oracle Learn*
