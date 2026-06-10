---
title: Owner preference (2026-06-10): for BUILD-team work, the fleet MAY self-merge a P
tags: [owner-preference, merge-policy, build-workflow, review-gate, self-merge, orchestrator]
created: 2026-06-10
source: owner direction 2026-06-10 (LIVE-gate session)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Owner preference (2026-06-10): for BUILD-team work, the fleet MAY self-merge a P

Owner preference (2026-06-10): for BUILD-team work, the fleet MAY self-merge a PR once the REVIEW gate passes (next-code-reviewer body-header = APPROVE) — no separate owner merge-approval needed. This is an explicit owner override of the generic CLAUDE.md "NEVER merge PRs without explicit user permission" rule, and matches build-workflow.md ("Self-merge unblocks delivery; it does not mark anything done"). Scope: build-team PRs (code fixes/features in the nextteam flow) that have a reviewer APPROVE in the review body. The orchestrator may run `gh pr merge --merge` for these (merging is delivery, not a "mark done" — only next-pm marks DONE, on evidence). Still NOT covered by this: non-build/infra/ADR PRs without a build-review, or anything the owner flags for manual review. Applied: PR #369 (auth-login returning-user 2FA fix) self-merged after reviewer APPROVE.

---
*Added via Oracle Learn*
