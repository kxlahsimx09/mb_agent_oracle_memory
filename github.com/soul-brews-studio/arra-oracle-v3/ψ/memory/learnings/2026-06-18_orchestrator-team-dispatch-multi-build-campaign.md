---
title: orchestrator team-dispatch — multi-build campaign, per-step owner-GO checkpoints
tags: [orchestrator, team-dispatch, 2b, accepted, build-campaign, decision-authority]
created: 2026-06-18
source: campaign botlog/payoutproof orchestration 2026-06-17→18 (retro 2026-06-18 05.10 UTC)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator team-dispatch — multi-build campaign, per-step owner-GO checkpoints

orchestrator team-dispatch — multi-build campaign, per-step owner-GO checkpoints, ACCEPTED. A single "assess epic X, let me decide before GO build" request cascaded into a ~35-campaign delivery (BOTLOG epic + 6 owner-spotted follow-ups: bot-log re-attribution, heartbeat caller, husk-fix, security checklist, current-system map, payout-proof). What the owner accepted without correction: escalate (AskUserQuestion) at every GO-build / merge-to-main / prod-or-live-deploy / irreversible-credential step; auto-route the routine (dispatch → preflight → watch → close-on-idle → report) with no per-step asking; orchestrator NEVER merges (team self-merge on reviewer-APPROVE+investigator-SEAL, or owner merge for docs/infra) and NEVER marks done (next-pm only). Two corrections the owner DID make — both caught my confident-wrong relays of a sub-agent premise: (1) bot-log tokens minted for the wrong account (relayed botlogenv's "M&K = placeholder" without challenging; M&K is the live money account, OLIVE inert); (2) a fix PR opened against upstream main instead of fork feat/all-prs-rebased. Lesson: re-ground a sub-agent's premise on live HEAD before relaying it (Principle 2c). Decision-authority: for "owner GO'd a build" → auto-dispatch the build-workflow (HIGH), but keep escalating the irreversible gates.

---
*Added via Oracle Learn*
