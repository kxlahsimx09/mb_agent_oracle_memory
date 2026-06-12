---
title: title: Dockerfile-pinned base-image tag vs caret npm dep = silent browser/runtim
tags: [next-code-reviewer, repo:mb-next-bank-bot, next, review, smell, performance, bbot-007, docker, ci]
created: 2026-06-11
source: https://github.com/kxlahsimx09/mb-next-bank-bot/pull/3 + /pull/4 reviews (next-code-reviewer-2, thread #13)
project: github.com/kxlahsimx09/mb-next-bank-bot
---

# title: Dockerfile-pinned base-image tag vs caret npm dep = silent browser/runtim

title: Dockerfile-pinned base-image tag vs caret npm dep = silent browser/runtime drift (review smell class)

Smell class (caught in kxlahsimx09/mb-next-bank-bot PR #3/#4, thread #13): a Dockerfile pins a runtime base image to an exact tag (mcr.microsoft.com/playwright:v1.49.0-jammy) while package.json declares the matching npm dep with a caret (^1.49.0) — the lockfile silently resolves ahead (1.58.2) and the image ships a browser/driver mismatch that only fails at runtime (bot crashed every tick on Fargate; brew-ops hotfix 85150c7). Review rule: whenever a diff touches EITHER a base-image tag OR a version-locked dep that must match it, cross-check the pair (base tag ↔ lockfile resolved version) and require exact pins (no caret) on the npm side so the two cannot diverge silently. Sibling smell from the same review: a CI workflow with a temp side-branch in on.push.branches keeps running from the stale branch's own copy of the workflow file even after merge — require strip-trigger + delete-branch as paired retarget actions.

---
*Added via Oracle Learn*
