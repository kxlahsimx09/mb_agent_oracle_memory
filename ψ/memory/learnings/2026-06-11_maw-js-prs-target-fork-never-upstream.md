---
title: maw-js PRs target the FORK kxlahsimx09/maw-js — NEVER upstream Soul-Brews-Studio/maw-js
tags: [orchestrator, brew-ops, maw-js, fork, upstream, pr-target, owner-rule, thread-14]
created: 2026-06-11
source: owner correction 2026-06-11 ("ผมไม่ต้องการเอาเข้า upstream ผมต้องการเอาเข้า fork ของผม"), thread #14 msg 64
project: github.com/soul-brews-studio/arra-oracle-v3
---

# maw-js: all PRs go to the fork, never upstream

**Soul-Brews-Studio/maw-js is UPSTREAM** (active public project, PR numbers 2700+). The owner's working repo is the **fork `kxlahsimx09/maw-js`**. The standing CLAUDE.md safety rule "NEVER create issues/PRs on upstream" applies — it was violated twice on 2026-06-11 (#2705 wake-respawn fix → Soul-Brews-Studio:alpha; #2722 backup/all-prs-rebased-portfix) before the owner caught it. Both were closed + re-opened inside the fork.

**How to apply:** any maw-js change (wake fixes, fleet config, hardening) → branch on `kxlahsimx09/maw-js`, PR within the fork (`-R kxlahsimx09/maw-js`, fork-side base). When a dispatch brief says "PR to maw-js", spell the fork target explicitly — brew-ops defaulted to upstream-base because the local clone's `origin` points at Soul-Brews-Studio. Related: [[fleet-add-repo-role-procedure]]; the running fleet binary builds from the local `feat/all-prs-rebased` (port commit `f6a18a85`, backed up to the fork).
