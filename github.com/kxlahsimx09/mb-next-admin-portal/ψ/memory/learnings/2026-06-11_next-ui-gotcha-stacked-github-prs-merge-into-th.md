---
title: next-ui — GOTCHA: stacked GitHub PRs merge into their BASE branch, not main. (mb
tags: [next-ui, repo:mb-next-admin-portal, next, git, stacked-prs, github, merge, gotcha, process, thread-13]
created: 2026-06-11
source: thread #13; PRs #8-#11 stacked-merge gap, recovery PR #12
project: github.com/kxlahsimx09/mb-next-admin-portal
---

# next-ui — GOTCHA: stacked GitHub PRs merge into their BASE branch, not main. (mb

next-ui — GOTCHA: stacked GitHub PRs merge into their BASE branch, not main. (mb-next-admin-portal, thread #13, 2026-06-11.)

To keep per-cluster review diffs clean I opened 4 stacked PRs: #8 base=main, #9 base=#8-branch, #10 base=#9-branch, #11 base=#10-branch. Reviewer approved + "merged" all 4. GitHub showed all 4 MERGED — but `origin/main` only received #8. Squash-merging a stacked PR lands its squash commit on the branch it's BASED on (the one below), NOT on main. So #9/#10/#11 landed on intermediate feature branches; main was missing 3 of 4 clusters (verified: wallet-api.ts/monitoring-api.ts/callbacks absent from origin/main). "MERGED" status ≠ "on main" for a stacked PR.

PREVENTION (pick one):
1. Base every PR on main (independent PRs) when changes don't truly depend on each other in a way that breaks the diff.
2. If stacking for clean diffs: as each lower PR merges to main, RETARGET the next PR's base to main (GitHub auto-retargets when the base branch is deleted on merge — but only for still-OPEN PRs; if they're merged near-simultaneously the retarget doesn't apply). Merge strictly bottom-up, one at a time, letting each base retarget before merging the next.
3. Always VERIFY post-merge: `git fetch && git log origin/main` + spot-check a file from each PR is actually on origin/main. Don't trust the MERGED badge.

RECOVERY (clean + lossless): the top-of-stack branch still contains the full stack. Open ONE PR base=main, head=<top branch>; its content-diff vs main = exactly the clusters that didn't land (already-approved commits). Merge that to main. No rebase/cherry-pick needed. (Done here as PR #12.)

Also: don't delete local feature branches until you've confirmed their content is on origin/main — though if pushed, they're recoverable from origin.

---
*Added via Oracle Learn*
