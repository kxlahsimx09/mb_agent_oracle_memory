---
title: Soul-Brews-Studio workflow: long-lived personal branch + fork-as-backup only, on
tags: [brew-ops, repo:cross, workflow, feedback, github, fork, long-lived-branch, kxlahsimx09, backup-only, no-pr, 2026-04-22]
created: 2026-04-22
source: User clarification 2026-04-22 after consolidation of maw-js + arra-oracle-v3 fork layout; verified final state in both repos
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Soul-Brews-Studio workflow: long-lived personal branch + fork-as-backup only, on

Soul-Brews-Studio workflow: long-lived personal branch + fork-as-backup only, one account (`kxlahsimx09`), no PR to upstream, no PR to fork either.

**Why:** Refined 2026-04-22 after the user clarified the full pattern across maw-js + arra-oracle-v3. The earlier learning (`2026-04-22_default-prs-to-the-users-fork-not-to-soul-brews`) correctly diagnosed "no upstream push access" but proposed a PR-on-fork review workflow that doesn't match how the user actually operates. The truth: they don't run a PR review loop at all on their own work in Soul-Brews-Studio repos. They iterate on a single long-lived branch per repo, rebase onto upstream/main as upstream moves, and push to their fork as a backup mirror only.

**How to apply (per repo):**

1. **Remote layout** — keep `origin` pointing at upstream `Soul-Brews-Studio/<repo>` (pull from here via `git pull origin main` or rebase onto `origin/main`). Add `fork` pointing at `kxlahsimx09/<repo>` (push here for backup). Do NOT flip origin/fork — `git push` going nowhere by default is safer than accidentally pushing to upstream, because upstream rejects anyway.

2. **Long-lived branch** — one branch per repo named `feat/all-prs-rebased` (no date suffix; rolling). All work lands here via merge, cherry-pick, or direct commits. Rebase onto `origin/main` whenever upstream moves. Treat this as the working trunk.

3. **No PR opening** — do NOT run `gh pr create` for the user's own ongoing work in Soul-Brews-Studio repos, neither to upstream nor to their fork. Upstream rejects (no access); fork PRs create noise without value because there is no reviewer. Only open PRs when the user explicitly asks (e.g., proposing a specific change outward for upstream review).

4. **Backup push** — push the long-lived branch to `fork/feat/all-prs-rebased` after meaningful work: `git push -u fork feat/all-prs-rebased`. This is the durable backup.

5. **Account** — use `kxlahsimx09` as the active gh account for both push and `gh` CLI. Git config user = `kxlahsimx09 <117012903+kxlahsimx09@users.noreply.github.com>` in each Soul-Brews-Studio repo checkout. The `amadeusmarsexpress` account exists as a legacy login — prefer `kxlahsimx09` going forward for consistency. Switch with `gh auth switch -u kxlahsimx09`.

6. **Sub-branch pattern for atomic work** — when a task has distinct commits (e.g., fleet-lens + unrelated gitignore cleanup), still author them individually, but merge/cherry-pick them into the long-lived branch once tested. Delete sub-branches locally afterward. This keeps the log clean and the long-lived branch composable.

**Scope:** `Soul-Brews-Studio/maw-js`, `Soul-Brews-Studio/arra-oracle-v3`, `Soul-Brews-Studio/oracle-studio`, and any future Soul-Brews-Studio repo the user forks. Does NOT apply to `kxlahsimx09/mb_agent_oracle_memory` (commit-to-main OK per AGENTS.md §3a) or to third-party repos where the user has direct push access. Repos outside Soul-Brews-Studio keep whatever workflow their owner dictates.

**Verified state 2026-04-22:**
| Repo | origin | fork | long-lived branch |
|---|---|---|---|
| `maw-js` | `Soul-Brews-Studio/maw-js` | `kxlahsimx09/maw-js` (fresh) | `feat/all-prs-rebased` |
| `arra-oracle-v3` | `Soul-Brews-Studio/arra-oracle-v3` | `kxlahsimx09/arra-oracle-v3` | `feat/all-prs-rebased` (renamed from `feat/all-prs-rebased-2026-04-20`) |

Supersedes `2026-04-22_default-prs-to-the-users-fork-not-to-soul-brews` which assumed fork account = amadeusmarsexpress and a PR-on-fork review workflow — both now corrected.

---
*Added via Oracle Learn*
