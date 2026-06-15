---
title: orchestrator team-dispatch — a user-directed multi-phase build campaign (gap-fin
tags: [orchestrator, team-dispatch, accepted, build-campaign, premise-verify, current-QA, stuck-draft, idle-watch, thread-19]
created: 2026-06-14
source: campaign bbot, orchestrator bbot 2026-06-14
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator team-dispatch — a user-directed multi-phase build campaign (gap-fin

orchestrator team-dispatch — a user-directed multi-phase build campaign (gap-find → fill → grounding → #current-QA → design-revision → ratify → build → merge → mark) ACCEPTED and driven to completion. Two patterns worth reusing: (1) PREMISE-VERIFY-FIRST (binding rule 2c) is the highest-leverage move — re-reading live HEAD showed a SPEC-ask's "design already ratified" was actually a #current flow doc, not a #next design, reframing the whole task; (2) #current-QA-before-build is high-ROI — having pg-writer cross-check the #next requirements against the legacy system caught 14 gaps a design pass missed (one would have broken the SCB-first SIM journey). Teammate failure mode that cost real time: agents finish then leave an unsubmitted "report to orchestrator" draft in the agent-teams compose box, and `maw team send` does NOT wake an idle pane — reliable recovery is retire(kill-window)+re-spawn fresh, or send-keys directly to the pane; tight 30s idle-aware pane-watches (grep `esc to interrupt`) catch stuck agents in ~2min vs ~60min artifact-watches. User reaction: drove the whole flow, expanded scope twice (both vindicated), chose §9a auto-merge for build PRs but owner-ratify for design/ADR + doc-mark PRs.

---
*Added via Oracle Learn*
