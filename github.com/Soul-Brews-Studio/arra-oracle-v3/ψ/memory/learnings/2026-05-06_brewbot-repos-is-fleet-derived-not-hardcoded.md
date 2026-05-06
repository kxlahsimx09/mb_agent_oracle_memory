---
title: **Brewbot `REPOS` is fleet-derived, not hardcoded** (post `Soul-Brews-Studio/arr
tags: [brew-ops, repo:arra-oracle-v3, bot, fleet, telegram, decision, durable-rule]
created: 2026-05-06
source: brew-ops session 2026-05-04 → 2026-05-06 — fleet-driven scope to support mb-next without hand edits
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **Brewbot `REPOS` is fleet-derived, not hardcoded** (post `Soul-Brews-Studio/arr

**Brewbot `REPOS` is fleet-derived, not hardcoded** (post `Soul-Brews-Studio/arra-oracle-v3` commit `de1b64a`, merged into `feat/all-prs-rebased` 2026-05-04).

**Behavior** (`scripts/brew-ops-bot/bot.sh`):
- `REPOS=()` declared empty at module top
- `load_roles()` populates `REPOS` at boot from unique repo paths in `ROLES` (which loads from `~/.config/maw/fleet/*.json` + `*/.agent/fleet/*.json`)
- All consumers (`cmd_blockers`, `cmd_pending`, `sweep_orphan_worktrees`) iterate `REPOS` as before — no other change

**How to add a new repo to brewbot scope**:
1. Drop a fleet json — either user-level (`~/.config/maw/fleet/NN-<name>.json`) or project-local (`.agent/fleet/NN-<name>.json` symlinked into the same dir)
2. Restart `bot.sh` (kill + `cd ~/Code/.../arra-oracle-v3 && nohup bash scripts/brew-ops-bot/bot.sh > /dev/null 2>&1 & disown`)
3. New repo's `docs/` will appear in `/blockers` + `/pending`, and orphan worktrees in that repo become `/close all auto` sweep candidates

**Trigger for the change**: user wanted `mb-next-payment-gateway` (architect's repo) in scope without hand-editing bot.sh every time a new repo lands. Hardcoded list = code edit per repo; fleet-derived = config edit per repo (same place fleet lives).

**Tradeoff**: blast radius of `sweep_orphan_worktrees` now grows automatically with fleet — usually desirable, but worth knowing when adding a fleet config that points at a repo with sensitive uncommitted state.

**Pre-existing bug noted but not fixed**: `load_roles` calls `log "loaded ..."` at module-init (line 79) before the `log()` function is defined (line 83) → bash falls back to `/usr/bin/log` (macOS unified logging) producing "Unknown subcommand" errors. Boot log message lost; runtime unaffected. Fix would be to move `log()` defn above `load_roles` call or move `load_roles` call below helpers — out of scope for the REPOS change.

---
*Added via Oracle Learn*
