---
title: INCIDENT — W1 sixth baseline (5ce4596) clobbered by writer-fleet PR #310 merge 7
tags: [tester, repo:mobiz-payment-gateway, current, regression-candidate, merge-clobber, writer-tester-collision, p-001, handoff, brew-ops]
created: 2026-04-28
source: git log --first-parent main -- docs/test-index.md (chronology) + git show 7e1af77:docs/test-index.md vs 8f80649:docs/test-index.md (clobber confirmation)
project: github.com/kokarat/mobiz-payment-gateway
---

# INCIDENT — W1 sixth baseline (5ce4596) clobbered by writer-fleet PR #310 merge 7

INCIDENT — W1 sixth baseline (5ce4596) clobbered by writer-fleet PR #310 merge 75min later

What's wrong: PR #326 (feat/tester-validate-2026-04-28) merged at 2026-04-28 11:29 +0700 with W1 sixth baseline content (V=36/S=2/W=0/F=0/SUP=1/ON_HOLD=2/UNK=2 at 5ce4596). PR #310 (docs/track-909d5a3, writer fleet's W2 amend) merged 75 minutes later at 2026-04-28 12:55 +0700. PR #310's branch was based on pre-9a795b3 main; its merge resolution on the conflicting docs/test-index.md + docs/test-coverage-gaps.md took the writer side, reverting both files to W1 fifth state at 909d5a3. Sixth-baseline commit 3a815fb still exists in git history but was no longer reachable via git show HEAD:docs/test-index.md.

Why this is wrong: The writer fleet's docs/track-* branch and the tester fleet's feat/tester-validate-* branch both edit docs/test-coverage-gaps.md (writer references the file's own surface — settlement tripwire row — to confirm gaps coverage; tester appends per-baseline). When the writer branch is older than the most recent tester merge, a `git merge` resolves the conflict by file-level take-ours/take-theirs unless the dev rebases. PR #310 took the older state and lost the W1 sixth content.

Minimal fix (proposed, not applied): Either (a) writer fleet's W2 amend workflow should `git rebase origin/main` before pushing the amend so the conflict surfaces as a proper 3-way merge, or (b) writer fleet should never touch docs/test-index.md or docs/test-coverage-gaps.md (out-of-territory — these are tester-owned per AGENTS.md §5b) and the merge driver for these files should be set to `union` or `theirs` (tester wins). Recommend (b) for clarity. Cross-fleet handoff: brew-ops should decide between (a) and (b) and codify in the writer's W2 reference + the merge driver in .gitattributes.

Impact if unfixed: Every cycle where writer's docs/track-* and tester's feat/tester-validate-* land within the same day risks reverting tester findings. Hidden because the file at HEAD looks plausibly current — only `git log --first-parent main -- docs/test-index.md` reveals the silent revert. Tester's W1 seventh recovery (this baseline) re-incorporates the W1 sixth findings; the next cycle will re-incur if not addressed.

Related: 2026-04-19_w2-observation tester-territory bullet about W2 not editing test-index.md (already filed); this incident is the first time the rule was violated by the merge driver, not the author.

---
*Added via Oracle Learn*
