---
title: `maw fleet renumber` is STATE-CHANGING with no dry-run/confirm — and probing it 
tags: [maw, fleet, renumber, symlink, vault-sync, tmux, ops-safety]
created: 2026-06-09
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# `maw fleet renumber` is STATE-CHANGING with no dry-run/confirm — and probing it 

`maw fleet renumber` is STATE-CHANGING with no dry-run/confirm — and probing it with `--help` RUNS it (maw ignores the unknown flag). 2026-06-09: a `maw fleet renumber --help` probe renumbered all 5 fleets (10/20/20/20/21 → 01/02/03/04/05). RULE: never run `maw <state-changing-subcmd> --help`; read usage from the bare `maw <group>` listing instead.

What renumber does: (1) renames every `~/.config/maw/fleet/<n>-<name>.json` to a unique number + rewrites the internal `"name"` field to match (it even fixed a filename↔name mismatch, e.g. file 21- / name 20-); (2) REPLACES the FLEET_DIR symlinks with standalone real files — DECOUPLING live config from the vault `.agent/fleet/` targets (vault originals keep old numbers, no longer linked, so vault-sync silently stops); (3) renames the live tmux sessions too (`10-soul-brews`→`01-soul-brews`) but does NOT kill them — a running session (e.g. brew-ops) survives, just renamed.

Repair to restore vault-sync: for each active fleet, `cp` the renumbered standalone file into its vault `.agent/fleet/` at the new name, `mv` the stale old-numbered vault file to a backup, `rm` the standalone, then `ln -s` vault→FLEET_DIR. `.agent` is gitignored in every repo (synced via vault-rsync, not git) so renames create zero git noise. Retire a dead fleet by moving its FLEET_DIR entry to `~/.config/maw/fleet/retired/` (nothing deleted). Net good outcome is possible (unique numbers, conflict gone) but the symlink decoupling is a hidden cost to repair.

---
*Added via Oracle Learn*
