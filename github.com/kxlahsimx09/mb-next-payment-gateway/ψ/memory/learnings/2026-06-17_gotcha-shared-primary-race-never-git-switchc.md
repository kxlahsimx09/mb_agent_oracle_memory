---
title: GOTCHA / SHARED-PRIMARY RACE: never `git switch`+commit directly in the `mb-next
tags: []
created: 2026-06-17
source: next-architect (doc-bankacct-spec, 2026-06-17)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# GOTCHA / SHARED-PRIMARY RACE: never `git switch`+commit directly in the `mb-next

GOTCHA / SHARED-PRIMARY RACE: never `git switch`+commit directly in the `mb-next-payment-gateway` PRIMARY checkout (`~/Code/github.com/kxlahsimx09/mb-next-payment-gateway`) — it is SHARED and concurrently branch-switched by other fleet agents. Tags: #repo:mb-next-payment-gateway #gotcha #fleet #worktree #concurrency #system-architect #git #safety

WHAT HAPPENED (2026-06-17): authoring ADR-22 I ran `git switch -c arch/bank-account-ui-spec origin/main` in the primary, made Edit-tool changes to docs/adr.md, then in a later Bash call ran `git add && git commit && git push`. Between calls ANOTHER agent had `git switch`ed the primary to `chore/wf7-migfix-v-system-banks-ff1725b`, so my commit (32961d7) landed on THEIR branch (on top of their 71c96d8), and my `git push arch/...` pushed the still-empty arch ref (ff1725b) → `gh pr create` failed "No commits between main and arch". The Bash tool resets cwd per call but the on-disk repo HEAD/branch is SHARED MUTABLE STATE; `-q` on the failing commit hid that it went to the wrong branch.

RECOVERY (worked): (1) `git worktree add <tmp> arch/bank-account-ui-spec` → cherry-pick my commit (32961d7) onto the clean arch tip (ff1725b) → push (FF) → PR from the worktree. (2) Back in the primary, GUARDED reset of the stray commit off chore: `if HEAD==32961d7 && clean tree; then git reset --hard 71c96d8` (their pushed tip) — restores the other agent's branch exactly; my commit preserved as cfd017a on arch + in reflog (P-001 safe).

RULE: for ANY gateway commit work, use an ISOLATED `git worktree` (`git worktree add <path> -b <branch> origin/main`) or a maw-spawned wt — NEVER the primary. Mirrors AGENTS.md §3c (primary stays on main, work in worktrees). Cross-call git assumptions in a shared checkout are unsafe: re-verify `git branch --show-current` at the START of every mutating Bash call, never `-q` a commit you won't immediately verify, and check `gh pr create` base-diff right after push.

---
*Added via Oracle Learn*
