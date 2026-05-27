---
title: p2p-hub §F PR OPENED — campaign #231 ratified dispute design landed (NOT merged)
tags: [system-architect, repo:cross, next, p2p-hub, section-f, dispute-liability, pr-10, campaign-231, landed-not-merged, decision, supersedes-c11, worktree-off-origin-main, design-doc-pr, p2p-support, close-outcome-contract, b1.4-hard-cliff, s1-s6-substrate, thread-232, open-pr, handoff]
created: 2026-05-27
source: p2p-hub PR #10 (kxlahsimx09/p2p-hub), branch next-architect/p2p-hub-section-f-dispute-liability-232 @ fca6204; docs/design/p2p-hub-design-exploration.md §F; thread #232 msg 1171 (GO) + msg 1173 (reply)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# p2p-hub §F PR OPENED — campaign #231 ratified dispute design landed (NOT merged)

p2p-hub §F PR OPENED — campaign #231 ratified dispute design landed (NOT merged) (thread #232 msg 1173, 2026-05-27). USER GO executed: drafted + opened the §F design-doc PR.

PR: https://github.com/kxlahsimx09/p2p-hub/pull/10 (OPEN, awaiting user review/merge — NOT auto-merged per AGENTS §9).
Branch: next-architect/p2p-hub-section-f-dispute-liability-232, off fresh origin/main @3c0615f via a dedicated WORKTREE at /Users/dev01/Code/github.com/kxlahsimx09/p2p-hub.wt-section-f-232 (primary checkout left parked on architect/phase-c-opt-in-protocol, undisturbed — §3d). Commit fca6204, NO AI attribution (§9).

Diff: 1 file, +193 lines — docs/design/p2p-hub-design-exploration.md:
- Added `# Phase F — Dispute & Liability (Phase 1)` between Phase E (ends ~line 2312) and `# Appendix` (was line 2314). Subsections F.0 framing · F.1 13-row liability matrix (groups A/B/C + close_outcome + mediated/authoritative lane) · F.2 dispute lifecycle (S5) + p2p-support mediator + append-only-overlay terminal-immutability · F.3 close_outcome contract (9 live + 2 reserved + both-agree/authoritative split + mediation_escalated) · F.4 B1.4 hard slip-deadline cliff + R1/R2 · F.5 ⟦S1⟧–⟦S6⟧ substrate + build order. Content = the ratified consolidated block from msg 1169 verbatim-in-spirit.
- §F marked **#decision** (user-ratified 2026-05-27) — NOT RATIFICATION_PENDING (contrast §E which still carries RATIFICATION_PENDING:206).
- §C11 got a one-line blockquote cross-ref pointer (`§C11 §evolved-by §F`): §F supersedes §C11's enforcement framing; §C11 retained per P-001 (mirrors how §D narrowed PI-5/A7).
- Design-only: no migrations, no code. Verified: no mermaid fences (state-machine is a plain ASCII code block — avoids the docs-site render break), no conflict markers, F.0–F.5 all present.

POST-MERGE follow-ups (when user merges PR #10): §F is already #decision so NO marker-flip needed (unlike a draft-then-ratify flow); the worktree p2p-hub.wt-section-f-232 can be `git worktree remove`d after merge. Campaign #231 design fully lands on merge.

OPEN ITEMS unchanged (the "next" menu): ⚖️ G1 legal launch-blocking (B8.3/B11.4 + source_funds_clawback B1.7 enforceability) · thunder-API commit (gates ⟦S4⟧) · B8.7 vetting policy · the ⟦S1⟧–⟦S6⟧/⟦S5⟧ build (next-impl, post-merge) · parked §E impl (thread #206: PR#8 spec merged, migrations 006–009 unbuilt, RATIFICATION_PENDING:206 still on main) · Phase-2 reserved (double_pay_handled, split_settled, B1.4 double-pay machinery).

Campaign #231 trace chain (6 links): a9f9eea9 (B7/B8 deep-dive) → ceebfc77 (liability matrix) → 2d1266ba (dispute-centric recast) → 4be2356f (B1.4 simplification) → 6fc9c884 (close_outcome mapping) → d457be4a (lock-in/consolidation) → THIS (§F PR opened).

---
*Added via Oracle Learn*
