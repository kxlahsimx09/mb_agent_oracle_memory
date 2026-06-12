---
title: title: Portal PRs — RED ui-gate check is review-blocking until branch-protection
tags: [next-code-reviewer, repo:mb-next-admin-portal, next, review, decision, ci-gate, branch-protection, portal, feedback]
created: 2026-06-12
source: Owner standing instruction, 2026-06-12 thread #18; verified no .github/workflows + Vercel-docs RED on main
project: github.com/kxlahsimx09/mb-next-admin-portal
---

# title: Portal PRs — RED ui-gate check is review-blocking until branch-protection

title: Portal PRs — RED ui-gate check is review-blocking until branch-protection exists (free-tier, reviewer IS the gate)

STANDING INSTRUCTION (owner, 2026-06-12, thread #18): for `mb-next-admin-portal` PRs, treat a RED **ui-gate** CI check as **review-blocking**. The repo is on GitHub free tier → required-status-checks / branch protection cannot be enforced by GitHub, so the next-code-reviewer is the human gate: do not emit an APPROVE body-header while the ui-gate is RED. Lift this once real branch-protection (paid tier or org move) lands.

How to apply on every portal review (add to the dimension-1 pass):
1. `gh pr checks <n> --repo kxlahsimx09/mb-next-admin-portal` AND `gh pr view <n> --json statusCheckRollup` — read the actual check state, not the author's "tsc/eslint/detect green" claim.
2. Distinguish PR-caused vs pre-existing: compare the failing context against `gh api repos/.../commits/main/status`. A check that is RED on `main` too (identical across independent PRs) is pre-existing infra, NOT the PR's debt — same precedent the orchestrator set for the layout.tsx eslint finding. Don't block a PR for a failure it didn't introduce; do surface it.

State of the repo as of 2026-06-12 (so future reviews don't re-derive): there is currently **NO GitHub Actions ui-gate workflow** (`.github/workflows/` is empty). The only check present is a **Vercel deploy of the `mb-next-admin-portal-docs` project**, which is **FAILING on main and on every PR** — a pre-existing/misconfigured infra failure (the actual app staging is a different project, `mb-next-admin-portal-staging.vercel.app`). So until a real lint/typecheck/build ui-gate CI is wired, there is no PR-caused gate signal to read, and the Vercel-docs RED is non-PR infra. Owner clarification pending on what check constitutes "the ui-gate".

---
*Added via Oracle Learn*
