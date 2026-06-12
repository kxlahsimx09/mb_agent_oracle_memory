---
title: brew-ops (thread #18, 2026-06-12) — portal `impeccable detect` CI gate: diff-sco
tags: [brew-ops, repo:mb-next-admin-portal, next, ci, github-actions, impeccable, eslint, gotcha, branch-protection, next-ui]
created: 2026-06-12
source: thread #18 2026-06-12; PR #17 ui-gate (verified green in CI); impeccable@2.3.2 CLI + plan-403 observed
project: github.com/kxlahsimx09/mb-next-admin-portal
---

# brew-ops (thread #18, 2026-06-12) — portal `impeccable detect` CI gate: diff-sco

brew-ops (thread #18, 2026-06-12) — portal `impeccable detect` CI gate: diff-scope it, and branch-protection is plan-blocked on free private repos.

## The gate (mb-next-admin-portal/.github/workflows/ui-gate.yml — PR #17)
One required check `ui-gate` on `pull_request`: checkout (fetch-depth:0) → setup-node 20 (cache npm) → `npm ci` → 3 steps. `impeccable detect` is `npx impeccable@<pinned> detect <files>` (the npm pkg `impeccable`, latest 2.3.2; deterministic, no LLM, JSON+exit code). Actions pinned to FULL commit SHAs (no floating majors). Verified green in real CI in 45s.

## KEY: scope `detect` to the PR DIFF, not `.`
A whole-repo `impeccable detect .` exits NON-ZERO on the portal today because of pre-existing, next-ui-ACKNOWLEDGED findings that will never change: `src/app/globals.css` (deliberate single-body-font + em-dashes inside CSS comments — a DESIGN.md decision) and the build-excluded `docs-site/`. impeccable@2.3.2 has NO ignore/config mechanism (only path args + `--json/--gpt/--gemini`), so `detect .` can never be green and cannot be a real gate. next-ui's "detect exits 0" is therefore a CHANGED-FILES run, not `.`. Gate the PR diff instead: `git diff --name-only --diff-filter=ACMRT <base.sha> <head.sha> | grep -Ei '\.(tsx?|jsx?|css|html?)$' | grep -vE '^docs-site/'`, read into a bash array (handles `src/app/(portal)/...` paren-paths), pass all to one detect call; empty list → skip → green. This blocks NEW anti-patterns without re-litigating accepted debt + matches next-ui's pre-PR practice.

## eslint: advisory, not blocking (yet)
`eslint-config-next` core-web-vitals now errors on `react-hooks/set-state-in-effect`; the portal predates it → a full-repo `eslint .` exits 1 with 41 errors (layout.tsx, theme.tsx, contexts…). So eslint runs with `continue-on-error: true` (advisory) — flip to blocking by deleting that one line once next-ui clears the 41. next-ui's "eslint ✅" is changed-files-scoped, which is why the repo-wide debt was invisible.

## GOTCHA — branch protection is PLAN-GATED, not permission-gated
Even as repo ADMIN, `PUT .../branches/main/protection` returns 403 "Upgrade to GitHub Pro or make this repository public" on a PRIVATE repo on the FREE tier. So a required-status-check (and rulesets) cannot be enforced at all until the org upgrades to Pro/Team OR the repo is made public. The workflow still RUNS + shows green/red on every PR; interim enforcement = next-code-reviewer blocks on a red check. Don't promise an owner-click branch-protection flip without checking the plan first.

## npm vs bun
The portal ships `package-lock.json` (npm), no bun lockfile — CI uses `npm ci` (reproducible) even though the fleet default is bun. Switching to bun = a separate lockfile-migration decision (commit bun.lockb, drop package-lock), not a CI-workflow change.

---
*Added via Oracle Learn*
