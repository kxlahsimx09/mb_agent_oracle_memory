---
title: Gotcha — stacked PRs merged in order without base-retargeting land in side branc
tags: [gotcha, github, stacked-pr, merge-mechanics, orchestrator, thread-169, recovery]
created: 2026-05-18
source: thread #169 — audit-#168 stack recovery; incident on kxlahsimx09/mb-next-payment-gateway PRs #158/#160/#164/#165
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Gotcha — stacked PRs merged in order without base-retargeting land in side branc

Gotcha — stacked PRs merged in order without base-retargeting land in side branches, not main (2026-05-18)

In a stacked-PR set (PR-B based on PR-A's head branch, PR-C on PR-B's head, …), merging them in order does NOT land the upper PRs on `main` unless each PR's base is retargeted to `main` first. GitHub only auto-retargets a dependent PR when the PR it stacks on is merged AND that PR's head branch is deleted. In the kxlahsimx09 repos, merged branches are NOT auto-deleted → no auto-retarget.

Incident: audit-#168 PR stack #158→#160→#164→#165 (mb-next-payment-gateway), merged in order without retargeting. Result: #158 (base already `main`) merged to main fine; #160 merged into #158's head branch, #164 into #160's, #165 into #164's — three PRs' content (G6/G7/G8, G9, admin-JWT harness) landed in side branches, never reached `main`. Symptom check: `gh pr view <n> --json baseRefName` on a MERGED stacked PR shows it merged INTO a side branch, not `main`; and the expected files/migrations are absent from `origin/main`.

Recovery (clean, no loss — all commits survive on the side branches): create a fresh branch off current `main`, cherry-pick the content commits (skip any already on main via the bottom PR), open one clean PR → `main`, re-verify. The audit-#168 recovery was PR #166 — 3 cherry-picked commits, zero conflicts.

Prevention — two options, pick one before merging a stack:
1. Retarget each stacked PR's base to `main` (`gh pr edit <n> --base main`) before merging it — do this PR-by-PR as the one below it merges; OR
2. Enable delete-branch-on-merge so GitHub auto-retargets the next PR.

Orchestrator note: when handing a user a stacked-PR merge plan, state the must-merge-in-order set explicitly AND the retarget requirement — and offer to retarget each as the user merges. Tags: #gotcha #github #stacked-pr #merge-mechanics #orchestrator

---
*Added via Oracle Learn*
