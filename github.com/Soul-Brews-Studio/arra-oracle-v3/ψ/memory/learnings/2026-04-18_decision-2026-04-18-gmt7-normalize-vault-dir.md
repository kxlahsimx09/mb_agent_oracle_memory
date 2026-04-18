---
title: Decision (2026-04-18, GMT+7) — Normalize vault directory case to GitHub canonica
tags: [brew-ops, memory, vault, decision, case-normalization, ghq, symlinks, onboarding, repo:cross, soul-sync]
created: 2026-04-18
source: 2026-04-18 brew-ops audit session, GMT+7
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Decision (2026-04-18, GMT+7) — Normalize vault directory case to GitHub canonica

Decision (2026-04-18, GMT+7) — Normalize vault directory case to GitHub canonical (Soul-Brews-Studio, not lowercase)

Observed drift: vault had `mb_agent_oracle_memory/github.com/soul-brews-studio/` (lowercase) while GitHub remote + ghq canonical path use `Soul-Brews-Studio` (capital). macOS case-insensitive FS masked the drift locally; Linux peers on `soul-sync` would see two separate directories.

Decision: vault directory names under `github.com/<org>/` must match the canonical GitHub remote casing exactly. The charter already uses `Soul-Brews-Studio` throughout; file system now matches.

Action taken: `git mv github.com/soul-brews-studio → github.com/Soul-Brews-Studio` (two-step rename through temp name to work around macOS case-insensitivity without `-f`). 24 DB rows for 1 file from pre-rename path preserved via `arra_supersede` pointing to the canonical new path. P-001 maintained.

How to apply — when onboarding a new project into the vault:
- Use the exact casing that appears in `git remote get-url origin` (not the URL you typed — what GitHub stores)
- Verify with `ghq list | grep <repo>` — that's the ground truth
- Add the project to BOTH `scripts/setup-symlinks.sh::PROJECTS` AND `scripts/verify.sh::PROJECTS` (two separate arrays, both need updating)
- Run `bash scripts/setup-symlinks.sh` → creates `.agent` symlink from project repo to vault's canonical copy
- Update README "Projects currently mounted" table with role

Related: this decision was reached while onboarding `github.com/Soul-Brews-Studio/arra-oracle-v3` as the third tracked project (joining `kokarat/mobiz-payment-gateway` and `kokarat/bank-bot`).

---
*Added via Oracle Learn*
