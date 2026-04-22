---
title: Default PRs to the user's fork, not to Soul-Brews-Studio upstream, in repos wher
tags: [brew-ops, repo:cross, fleet, workflow, feedback, github, pr, fork, amadeusmarsexpress, 2026-04-22]
created: 2026-04-22
source: Direct user correction 2026-04-22 after opening Soul-Brews-Studio/maw-js#710, #711 against upstream; re-opened as amadeusmarsexpress/maw-js#1, #2
project: github.com/soul-brews-studio/maw-js
---

# Default PRs to the user's fork, not to Soul-Brews-Studio upstream, in repos wher

Default PRs to the user's fork, not to Soul-Brews-Studio upstream, in repos where the active gh account (`amadeusmarsexpress`) has no push access to upstream. The fork (`amadeusmarsexpress/<repo>`) is the user's own review + iteration venue; opening upstream PRs from there produces PRs that can't be merged and that pollute the upstream review queue.

**Why:** Observed 2026-04-22 on maw-js during fleet-lens Phase 1 landing + a companion `.claude/` gitignore cleanup. I opened both against `Soul-Brews-Studio/maw-js:main` by default. User corrected: "ไม่ต้อง pr ไปที่ upstream แค่ pr ให้ review ที่ fork พอแล้ว" (no need to PR to upstream — just PR for review on the fork). Had to close the two upstream PRs (Soul-Brews-Studio/maw-js#710, #711) and re-open on fork (amadeusmarsexpress/maw-js#1, #2).

**How to apply:**

1. Before running `gh pr create`, check push access for the active account: `gh api /repos/<owner>/<repo> --jq '.permissions.push'`. If the response is `null`/missing for Soul-Brews-Studio repos, the fork PR is the default.
2. Target the fork explicitly: `gh pr create --repo amadeusmarsexpress/<repo> --base main --head <branch>`. Both sides live on the fork so no `owner:branch` prefix is needed on `--head`.
3. The fork's `main` is normally synced with upstream when created via `gh repo fork`; verify with `gh api /repos/amadeusmarsexpress/<repo>/compare/main...Soul-Brews-Studio:main --jq '"ahead=" + (.ahead_by|tostring) + " behind=" + (.behind_by|tostring)'` before opening — if behind, sync first so the diff is clean.
4. Only target upstream when the user explicitly says "upstream", "propose to Soul-Brews-Studio", "open against main upstream", or similar. Reversible: `gh pr close <n> --repo Soul-Brews-Studio/<repo> --comment "..."` + re-open on fork.
5. Do NOT auto-merge even on the fork. Fork PRs still go through the same review gate — the user reviews their own changes before merge.

**Scope:** Applies to Soul-Brews-Studio/* (maw-js, arra-oracle-v3, oracle-studio, etc.). Does NOT apply to `kxlahsimx09/mb_agent_oracle_memory` (single-author exception, commit-to-main OK per AGENTS.md §3a) or to repos where the active account has direct push access.

**Account context:** `amadeusmarsexpress` is the active gh account for Soul-Brews-Studio work + matches `git config user.email`. `kxlahsimx09` is the other logged-in account but does not have Soul-Brews-Studio push access either — neither works for direct upstream push.

---
*Added via Oracle Learn*
