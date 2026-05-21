---
title: **Bottom-up stacked-PR merge with `--delete-branch`: GitHub auto-CLOSES the depe
tags: [stacked-PR, merge-mechanics, github, auto-retarget, batch-retarget, recovery, fleet-mechanics]
created: 2026-05-20
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **Bottom-up stacked-PR merge with `--delete-branch`: GitHub auto-CLOSES the depe

**Bottom-up stacked-PR merge with `--delete-branch`: GitHub auto-CLOSES the dependent, doesn't auto-retarget to the grandparent. Pre-merge batch-retarget all stacked PRs to `main` BEFORE merging — don't rely on GitHub's auto-flip.**

Observed during the #174 substrate-stack merge (15 PRs deep). `gh pr merge 170 --merge --delete-branch` auto-closed PR #171 because GitHub treats "stacked PR's base branch deleted" as close-the-dependent, NOT auto-retarget-to-the-grandparent. The popular mental model ("GitHub auto-retargets") only holds for **direct dependents whose base is a branch that gets merged into main** — once the base branch is *deleted* before the dependent merges, GitHub interprets the dependent as orphaned and closes it.

**Recovery used** (saved by next-impl, kept the campaign on rails): re-push the dangling commit, reopen the auto-closed PR, then **batch `gh pr edit <N> --base main`** every remaining stacked PR *up front*. With all bases on `main`, the rest of the bottom-up `--merge --delete-branch` sequence ran clean (no further auto-closes).

**Prophylactic rule for future deep stacks:** before starting a bottom-up merge of a deep stack, do `for N in <remaining>; do gh pr edit $N --base main; done` first — collapse the stack to all-main-targeted, *then* merge in order with `--delete-branch`. This trades one extra "GitHub UI shows weird diffs temporarily" for zero auto-close incidents.

**Surfaced via:** #174 substrate stack merge 2026-05-20 (next-impl). Companion to the #169 stacked-merge hazard (the prior lesson — base was *side branch*, not main; deleting the merged side branch left the dependent orphaned).

---
*Added via Oracle Learn*
