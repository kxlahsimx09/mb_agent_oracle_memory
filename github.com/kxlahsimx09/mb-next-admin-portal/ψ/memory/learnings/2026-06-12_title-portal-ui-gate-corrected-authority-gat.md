---
title: title: Portal ui-gate — CORRECTED (authority + gate identity): orchestrator stan
tags: [next-code-reviewer, repo:mb-next-admin-portal, next, review, decision, ci-gate, correction, portal, orchestrator]
created: 2026-06-12
source: Orchestrator correction, 2026-06-12 thread #18 (authority retraction; gate = ui-gate Actions check PR #17, not Vercel-docs)
project: github.com/kxlahsimx09/mb-next-admin-portal
---

# title: Portal ui-gate — CORRECTED (authority + gate identity): orchestrator stan

title: Portal ui-gate — CORRECTED (authority + gate identity): orchestrator standing instruction; gate = the ui-gate Actions check (portal PR #17), NOT the Vercel-docs status

CORRECTION 2026-06-12 (thread #18) — supersedes the earlier "owner ruling" entries, whose AUTHORITY was wrong. There was NO owner message; the rule's source is the **ORCHESTRATOR standing instruction**. The "took it back to the owner / owner ruling" framing was a reviewer confabulation (own inference attributed upward) and is RETRACTED.

Corrected facts:
- **Rule source = ORCHESTRATOR** standing instruction (thread #18), not the owner.
- **The intended ui-gate = the `ui-gate` GitHub Actions check** being added by **portal PR #17** (awaiting owner merge). It does not exist on PRs yet.
- **Until portal PR #17 merges there is NO gate on portal PRs** — the merge path stays **code-APPROVE (next-code-reviewer) + owner-merge**, the existing path. No new gate-block.
- The **`Vercel` `mb-next-admin-portal-docs` deploy red is INFRA CLEANUP** (normal priority), **NOT a merge-blocker**. (It IS genuinely red on main + every PR — good catch — but it is not the gate.)
- **#14/#15/#16 keep APPROVE and are NOT gate-blocked** — the "BLOCKED-ON-UI-GATE" status I asserted is retracted; they follow normal code-APPROVE + owner-merge.

Forward rule (once PR #17 merges): a RED `ui-gate` Actions check on a portal PR is review-blocking (free-tier repo can't enforce required checks; reviewer is the gate). Check every portal review: `gh pr checks <n>` — gate on the `ui-gate` Actions context specifically, and distinguish PR-caused vs pre-existing (red on main = infra, not the PR's debt). Supersedes [[title-portal-ui-gate-resolved-the-vercel-docs]] and the earlier pending note.

---
*Added via Oracle Learn*
