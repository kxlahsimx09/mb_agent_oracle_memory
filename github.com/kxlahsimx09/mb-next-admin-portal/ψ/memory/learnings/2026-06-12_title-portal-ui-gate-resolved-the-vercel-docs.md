---
title: title: Portal ui-gate RESOLVED — the Vercel(-docs) check IS the gate; RED on mai
tags: [next-code-reviewer, repo:mb-next-admin-portal, next, review, decision, ci-gate, branch-protection, portal, feedback, brew-ops]
created: 2026-06-12
source: Owner ruling, 2026-06-12 thread #18 (AskUserQuestion: gate = Vercel-docs as-is; #14/15/16 keep APPROVE)
project: github.com/kxlahsimx09/mb-next-admin-portal
---

# title: Portal ui-gate RESOLVED — the Vercel(-docs) check IS the gate; RED on mai

title: Portal ui-gate RESOLVED — the Vercel(-docs) check IS the gate; RED on main blocks ALL portal merges (owner ruling)

OWNER RULING 2026-06-12 (thread #18), supersedes the "clarification pending" note: for `mb-next-admin-portal` the **ui-gate = the existing `Vercel` commit-status check, as-is** (currently the `mb-next-admin-portal-docs` deploy). Because that check is **RED on `main` and on every PR**, **all portal PRs are gate-blocked (merge held) until it goes green**. Fixing it is a **brew-ops infra task** (repair/reconfigure the Vercel-docs project, or repoint the gate at the real app `mb-next-admin-portal-staging` deploy) — NOT a code change. No GitHub Actions ui-gate exists (`.github/workflows/` empty); the reviewer is the gate (free-tier, no enforced required-checks).

Operational consequence — portal verdicts are now TWO-AXIS:
- **code-review axis** (my normal APPROVE / REQUEST-CHANGES on the diff), AND
- **gate axis** (ui-gate GREEN / RED).
Both must pass to merge. An APPROVE body-header on a RED-gate portal PR means "code is good, but DO NOT MERGE until the gate is green." State it explicitly so next-pm/orchestrator don't merge on the code-APPROVE alone.

#14/#15/#16 disposition: **keep APPROVE** (the RED is pre-existing infra, not their code — same precedent as the layout.tsx eslint caveat) but they are **BLOCKED-ON-UI-GATE** until the Vercel check is green. Routed to brew-ops to fix the failing Vercel-docs deploy. Lift the whole gate-block regime once real branch-protection (paid tier / org move) lands. Check state every portal review: `gh pr checks <n>` + `gh api repos/.../commits/main/status`.

---
*Added via Oracle Learn*
