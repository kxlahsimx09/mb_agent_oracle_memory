---
title: w2-watcher.sh silently crashes on start when launched with bare `bash` on this f
tags: [brew-ops, repo:arra-oracle-v3, fleet, gotcha, w2-watcher, bash, tmux]
created: 2026-06-09
source: brew-ops session 2026-06-09 — starting brewbot + w2 watcher
project: github.com/soul-brews-studio/arra-oracle-v3
---

# w2-watcher.sh silently crashes on start when launched with bare `bash` on this f

w2-watcher.sh silently crashes on start when launched with bare `bash` on this fleet host — must use bash ≥4 explicitly.

**Symptom:** `nohup bash scripts/w2-watcher.sh ...` (the SKILL.md-documented start command) exits immediately; `w2-watcher.sh status` and the stdout log show `scripts/w2-watcher.sh: line 107: pg: unbound variable`. The daemon never appears in `pgrep`.

**Root cause:** In a non-interactive shell on this macOS host, PATH resolves `bash` → `/bin/bash` (GNU bash 3.2.57, Apple's frozen default), which has no associative arrays. w2-watcher.sh runs `set -u` and uses `declare -A REPOS=( ["pg-writer"]=... )` (line 107, 3 total). Under bash 3.2 the `["pg-writer"]=` subscript is parsed as arithmetic, `pg` reads as an unbound variable → crash. Homebrew bash 5.x lives at `/opt/homebrew/bin/bash` but is NOT first in the non-interactive PATH.

**Fix:** start w2-watcher under the homebrew bash explicitly:
`nohup /opt/homebrew/bin/bash scripts/w2-watcher.sh >> ~/w2-watcher.stdout.log 2>&1 & disown`
Verify: `/opt/homebrew/bin/bash scripts/w2-watcher.sh status` (running pid + per-role trigger gates).

**Scope:** only w2-watcher.sh is affected — bot.sh / detector.sh / chat-watcher.sh use zero `declare -A`, so they run fine under 3.2 (confirmed clean startup, 15 roles loaded). The documented `nohup bash scripts/...` command in SKILL.md "Operations infrastructure" assumes bash 5 is first in PATH; that assumption holds in an interactive login shell but breaks in non-interactive contexts (e.g. an agent session). Candidate hardening: add `#!/usr/bin/env bash` is already present but doesn't help since env bash also hits /bin first here — better to pin the start command or add a `BASH_VERSINFO` guard at the top of w2-watcher.sh.

Tags: #brew-ops #repo:arra-oracle-v3 #fleet #gotcha #tmux #w2-watcher #bash

---
*Added via Oracle Learn*
