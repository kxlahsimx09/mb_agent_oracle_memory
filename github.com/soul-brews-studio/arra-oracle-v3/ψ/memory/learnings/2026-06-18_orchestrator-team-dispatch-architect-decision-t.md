---
title: orchestrator team-dispatch — "architect-decision-then-implement" two-stage, para
tags: [orchestrator, team-dispatch, 2b, accepted, architect-decision-then-implement, adr-reversal, owner-gated-pr, parallel-build, #repo:cross, #fleet, #handoff, #decision]
created: 2026-06-18
source: campaign botlogdirectread + botloggatedviews (orchestrator)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator team-dispatch — "architect-decision-then-implement" two-stage, para

orchestrator team-dispatch — "architect-decision-then-implement" two-stage, parallel-build, ACCEPTED. Shape: a decision-packet handoff lands in the inbox asking the architect to ratify/reject a ratified-ADR reversal (here: §ADR-15 BL6-D EF-sole-read → gated direct-read views for portal /bankbot-logs). Correct routing: (1) spawn a FRESH next-architect under its own slug (campaign botlogdirectread) to DECIDE the open questions + author the ADR amendment as a DOCS-ONLY owner-gated PR + write the brew-ops impl contract — NOT to implement; (2) after the decision, spawn a FRESH brew-ops under a SEPARATE slug (botloggatedviews, own worktree/branch off main — never share the architect's ADR-PR branch, else the migration mixes into the docs PR) to build the migration+pgTAP as a second owner-gated PR. Owner chose to build IN PARALLEL (both PRs owner-gated, nothing deploys until owner merges) rather than wait for ADR ratification — this is a valid owner call to surface, not to assume. Result: ADR PR #602 (docs) + migration PR #603 (DB+pgTAP, 31/31 + 40/40 green) both OPEN, owner-gated. Mechanics that worked: team-dispatch-helper.sh per (campaign×repo); verify each teammate's kickoff actually submitted (helper warns "TUI readiness not detected after 45s — sending kickoff anyway" — capture-pane to confirm the agent is running, not stuck at ❯); fresh slug per Step-3 never-reuse rule; close BOTH campaigns with team-dispatch-finish.sh once idle (came-to-rest / "Idle." / footer flips to "← for agents") to free quota — finish deletes the LOCAL branch but the PR rides the ORIGIN remote branch so the PR stays OPEN (verified). brew-ops correctly deferred to the architect contract over a looser orchestrator-dispatch word ("reframe" vs "flip" the service_role assertion) — principle 2a, attribute to the domain authority.

---
*Added via Oracle Learn*
