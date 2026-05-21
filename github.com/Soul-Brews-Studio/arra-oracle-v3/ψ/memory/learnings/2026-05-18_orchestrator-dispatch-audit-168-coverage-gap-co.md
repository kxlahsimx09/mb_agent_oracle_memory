---
title: orchestrator dispatch — audit #168 coverage-gap continuation: design-then-build 
tags: [orchestrator, decision-authority, accepted, coverage-gap, next-impl, next-architect, pg-writer, thread-168, design-then-build, fact-check-before-ratify]
created: 2026-05-18
source: parent thread #168 — coverage-gap continuation campaign, msgs 516-540
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator dispatch — audit #168 coverage-gap continuation: design-then-build 

orchestrator dispatch — audit #168 coverage-gap continuation: design-then-build split + fact-check-before-nod 2026-05-18

Request: user asked the orchestrator to continue next-impl's integration-layer coverage-gap work (thread #168, the continuation of the closed #158 audit) — refresh the gap list, then close the gaps.
Classification: single-thread campaign #168, multi-round — refresh gap map → close P0/P1 (G5-G8) → G9 + admin-JWT design → build. Owners: next-impl (audit + build), next-architect (design), pg-writer (current-code fact checks).
Confidence: HIGH — user instructed and picked scope each round.
Outcome: G5-G9 + admin-JWT harness all built and hosted-verified — 4 fork PRs in one stack (#158 G5 / #160 G6-G8 / #164 G9 / #165 harness), none merged. Two follow-ups flagged: audit_log substrate port, and the admin endpoints themselves.
User reaction: accepted at every round.

Decision-authority + process lessons:
1. A dispatched "gap to close" can turn out to embed a design decision the implementer cannot make. G9 ("create-time validation rejections") looked like a probe in the #158 map; next-impl, building it, found the validations + config columns were entirely absent from the integrated substrate — it is a schema + money-RPC change that embeds config decisions, and next-impl correctly refused to "invent config." The orchestrator's move: do NOT push such an item back at the implementer — split it. Dispatch the design (next-architect) and the build (next-impl) as separate steps. When the user says "do it in parallel," the genuinely parallel-able piece is the DESIGN; the build follows the design. Saying so honestly (rather than dispatching a blocked build) is the right call.
2. Fact-check a design's assumptions against the current system BEFORE the user ratifies. next-architect's G9 design rested on "mobiz enforces per-client min/max at create; per-system-bank band is routing-time." The orchestrator dispatched pg-writer to verify that against live mobiz code before the user nodded — pg-writer confirmed it (and surfaced one real divergence: next-architect proposed a `bank` table, current uses a hardcoded slice — a deliberate improvement, not a mirror, which the user then chose knowingly). Verify-against-code-before-ratify caught a divergence the user should decide rather than absorb silently.
3. next-impl self-corrected its own earlier map entry (G9 mis-classified as a quick probe because it read the floor poc, not the integrated substrate) — second instance this fleet of an implementer honestly revising a prior claim when it hit the real substrate. The report-back discipline catches map errors.

---
*Added via Oracle Learn*
