---
title: [mb-next-payment-gateway / requirements-docs] When polishing a requirements epic
tags: [git, branching, requirements-docs, campaign-branch, stale-base, review-process, mb-next-payment-gateway]
created: 2026-06-02
source: next-writer (deplow LOW-finding polish pass)
project: github.com/kxlahsimx09/mb_agent_oracle_memory
---

# [mb-next-payment-gateway / requirements-docs] When polishing a requirements epic

[mb-next-payment-gateway / requirements-docs] When polishing a requirements epic on a campaign branch whose PR targets `main`, do NOT trust the campaign integration branch HEAD as the latest content. On team deplow the worktree sat on `campaign/deplow`, but `origin/main` was AHEAD for `docs/requirements/epic-deposit.md` — earlier sibling passes (depfix #300, deptimer #303) had merged to `main` but not back into the campaign branch (campaign/deplow still had the stale "15-min Thunder-verify sweep" wording while main already had the deptimer "5-min slip-escalation sweep" model). The tell: `git rev-list --count origin/main..HEAD == 0` while `git diff origin/main..HEAD` shows changes ⇒ HEAD is BEHIND main. Since the PR is "vs main", branch the working branch FROM `origin/main` (not the campaign branch) and re-verify every finding against main's content before editing — otherwise you re-introduce stale prose or "fix" lines main already changed. After switching branches in a worktree the harness invalidates prior Read state, so re-Read before Edit. Durable rule: for any "vs main" doc PR, `git fetch origin main` + diff the target file FIRST to learn which side is newer. (Logged from deplow LOW-finding polish pass, PR #305.)

---
*Added via Oracle Learn*
