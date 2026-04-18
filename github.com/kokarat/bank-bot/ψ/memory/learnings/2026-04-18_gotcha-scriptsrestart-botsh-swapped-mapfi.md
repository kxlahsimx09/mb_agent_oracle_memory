---
title: # gotcha — `scripts/restart-bot.sh` swapped `mapfile` for while-read for macOS b
tags: [technical-writer, repo:bank-bot, current, deployment, scripts, gotcha, portability, bash]
created: 2026-04-18
source: W1 baseline @ 7d4b50e (PR #60, commit 0789b4b)
project: github.com/kokarat/bank-bot
---

# # gotcha — `scripts/restart-bot.sh` swapped `mapfile` for while-read for macOS b

# gotcha — `scripts/restart-bot.sh` swapped `mapfile` for while-read for macOS bash 3.2 portability

**Tags**: technical-writer, repo:bank-bot, current, deployment, scripts, gotcha

**What**: `scripts/restart-bot.sh` at L41-43 and L63-66 (@ 7d4b50e) replaced `mapfile -t` with a `while IFS= read -r` loop. `mapfile` is bash 4+ only; macOS ships bash 3.2 by default (Apple won't ship newer bash due to GPL3), so the script broke when run locally.

```bash
# OLD (bash 4+ only):
mapfile -t lines < <(command)

# NEW (bash 3.2 compatible):
while IFS= read -r line; do
  lines+=("$line")
done < <(command)
```

**Why it matters**:
- Deployment scripts run on two surfaces: Droplets (Ubuntu 22.04, bash 5.x) *and* local developer macOS boxes during testing/dry-runs. A script that only works on the Droplet is a debugging hazard.
- Apple's bash 3.2 is a perennial footgun for any shell tool using `mapfile`, `readarray`, associative arrays (`declare -A`), or `${var^^}` style case transformations.

**How to apply**: For any shell script intended to run in both CI/production *and* developer machines, target POSIX or bash 3.2 compatibility unless there's a strong reason otherwise. Prefer `while read` loops over `mapfile`. If a script *must* use bash 4+ features, start it with a version check: `if ((BASH_VERSINFO[0] < 4)); then ...` and fail loudly.

**Source**: docs/current-system.md §5.3 + PR #57 @ 7d4b50e (commit `0933cc1`).

---
*Added via Oracle Learn*
