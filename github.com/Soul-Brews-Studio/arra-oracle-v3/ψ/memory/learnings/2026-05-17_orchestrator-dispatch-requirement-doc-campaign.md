---
title: orchestrator dispatch — requirement-doc campaign "finish epic-payout" resolved a
tags: [orchestrator, decision-authority, 2a-trivial-direct, accepted, requirement-doc, advisory-first-dispatch, next-writer, epic-payout, thread-157]
created: 2026-05-17
source: parent thread #157 — next-writer campaign, msgs 453-464
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator dispatch — requirement-doc campaign "finish epic-payout" resolved a

orchestrator dispatch — requirement-doc campaign "finish epic-payout" resolved auto 2026-05-17

Request: user asked the orchestrator to continue next-writer's requirement-document work and have next-writer recommend what to do next (thread #157).
Classification: single-agent campaign to next-writer (technical-writer role). Advisory-first: dispatch asked for a recommendation, not a pre-chosen task. Ran on one thread (#157) across three rounds — recommend → execute (A) → PAYOUT-007 follow-up — rather than spawning a thread per round (thread-discipline: fewer/coarser threads).
Confidence: HIGH — user instructed directly and picked from the options each round.
Outcome: epic-payout taken to 100% authored. PAYOUT-005 authored, PAYOUT-006 cut (no scope distinct from PAYOUT-004), PAYOUT-007 authored after a ratification-gate check, INDEX/README drift swept. Delivered as PR #150 (fork, unmerged).
User reaction: accepted at every round.

Decision-authority + process lessons:
1. Advisory-first dispatch works well for "what should we do next" requests: ask the owning expert to recommend (prioritized, with sizes + blockers), relay to the user, let the user pick. The user picked the agent's top recommendation each time. Pattern: for open-ended "continue X" requests, do not have the orchestrator choose the work item — dispatch a recommendation.
2. A conditional user ruling ("if PAYOUT-006 looks like PAYOUT-004, cut it") is safely delegated to the owning agent's judgement when the orchestrator hands over the criterion explicitly and the agent reports what it found. next-writer assessed and cut, with a named justification.
3. The owning agent self-corrected a factual error in its own earlier recommendation (it had said PAYOUT-007 was authored; it was a third stub). Surfacing that honestly turned a "done" into a "one story short" and a clean follow-up — evidence the report-back discipline catches the orchestrator's incomplete framing.
4. Ratification-gate discipline held: the PAYOUT-007 dispatch told next-writer to confirm §ADR-9 2026-05-12 actually covered the payout endpoint before authoring; next-writer confirmed (AM2/AM7) and only then authored. P-004 — do not promote a story the ADR does not back.

---
*Added via Oracle Learn*
