---
title: orchestrator dispatch — #167 requirement-doc gap review: cross-role find → verif
tags: [orchestrator, decision-authority, accepted, requirement-doc, gap-review, cross-role-cross-check, verify-before-remediate, pg-writer, next-architect, next-writer, thread-167]
created: 2026-05-19
source: parent thread #167 — requirement-doc gap-review campaign, msgs 514-553
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator dispatch — #167 requirement-doc gap review: cross-role find → verif

orchestrator dispatch — #167 requirement-doc gap review: cross-role find → verify → fact-check chain before remediation 2026-05-18/19

Request: user asked the orchestrator to have pg-writer review the `next` system's requirement docs (epic-deposit, epic-payout) and list gaps.
Classification: single-thread campaign #167, multi-agent, multi-round. Owners: pg-writer (current-system cross-check + code fact-checks), next-architect (verification + P1#2 design + ADR amendments), next-writer (doc fixes + the new matcher epic), next-impl (P1#2 code).
Confidence: HIGH — user instructed and ruled gap-by-gap.
Outcome: 16 gaps surfaced, all verified genuine; P1#1 ruled accepted-divergence (PR #159), P1#2 fixed (PR #162 ADR-amendment + #163 code + #168 doc), P1#3 fixed (PR #161), matcher subsystem given its own epic epic-statement-matching.md (PR #169). P2/P3 left as deferred backlog.
User reaction: accepted at every round.

Decision-authority + process lessons:
1. The strongest move for a "review the requirement docs" request is a CROSS-ROLE lens. pg-writer (the *current* mobiz system's writer) reviewing the *next* system's docs caught operational realities the next-side authors structurally could not see ("the live gateway handles X — does next cover it?"). Use a current-system expert to cross-check a next-system spec, and vice versa.
2. A three-step verify-before-remediate chain prevented every wrong edit: (a) pg-writer FOUND gaps from the current lens; (b) next-architect VERIFIED each against next's design intent (some pg-writer "gaps" were deliberate divergences or already-covered — next-architect downgraded #1 and #3); (c) when next-architect's fix design rested on an assumption about the current system, pg-writer FACT-CHECKED it against live current code before the user ratified (confirmed min/max is enforced, not dead config; surfaced the bank-table-vs-hardcoded-slice divergence). Never let a finding go straight to a doc/code edit — find, verify against the other side's intent, fact-check the assumptions, then the user rules.
3. The orchestrator escalates DELIBERATE-DIVERGENCE calls to the user, not just genuine-bug calls: P1#1 was a real gap but the user ruled it an accepted tradeoff — and the right output was a one-line doc note recording the divergence so a future reviewer does not re-flag it (turn a silent omission into a recorded decision).
4. A subsystem referenced by many stories but owned by none (the statement matcher — invoked by deposit AND payout, no single user actor) warrants its own epic; an engine-centric story framing (no user-role actor) is correct for it. next-writer flagged this as a structural call; the user accepted.

---
*Added via Oracle Learn*
