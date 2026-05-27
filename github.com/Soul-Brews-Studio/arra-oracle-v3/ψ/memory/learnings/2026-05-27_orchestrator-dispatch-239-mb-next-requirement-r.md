---
title: orchestrator dispatch — #239 mb-next requirement re-review (second-pass, post-#2
tags: []
created: 2026-05-27
source: orchestrator / parent thread #239 (2026-05-27)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator dispatch — #239 mb-next requirement re-review (second-pass, post-#2

orchestrator dispatch — #239 mb-next requirement re-review (second-pass, post-#228/#234 verify-against-HEAD)

tags: [orchestrator, decision-authority, fan-out, two-lens-review, requirement-remediation, verify-against-head, next-writer, pg-writer, thread-239, repo:arra-oracle-v3, mb-next-payment-gateway, fleet]
source: parent thread #239 (subs #240 next-writer / #241 pg-writer), 2026-05-27; user re-requested the same two-lens review as accepted #225.

WHAT: User (direct CLI, acting as orchestrator) re-ran the accepted #225 two-lens requirement review AFTER the #228/#234 authoring landed (7 net-new epics + 2 refreshes + A1–A4 ratified, 13 PRs). I fanned out the same orthogonal pair: next-writer = internal-completeness, pg-writer = vs-#current production. Briefed BOTH on the #225→#228→#234 history so they verified current HEAD (12b9e1c) and reported only what REMAINS — not re-flag already-authored/ratified items.

OUTCOME (surface holds up): next-writer — substantially COMPLETE, every ratified ADR maps to an epic, P2 tail closed; only R1 (§ADR-8 A2 9th fair-router filter never propagated to BOT-001/PULLOUT-002) + R2 (SETTLE-001 partner-initiated scope Q). pg-writer — A3 rate-limits now CLEAN; 2 newly-visible faithfulness drops, both in the freshly-authored epic-source-flows.md loss-risk surfaces: B1 (Pullout demand-refill is config-gated default-OFF + fires on opposite dest-LOW edge, but epic frames 4 co-equal live drain triggers) + B2 (DTR-001 S2 universal "never touches a wallet" contradicted by production deposit-refund-via-DT which debits/credits wallet; DTR-002 drops the money-movement half). + LOW AUTH-005 lockout lifecycle.

PATTERNS REINFORCED:
- Orthogonal lenses stay non-redundant even on a second pass: internal-completeness said "complete"; vs-production found 2 silent faithfulness drops INSIDE the "complete" epics. The high-value find is structurally invisible to the internal pass. Always pair them.
- verify-against-HEAD framing works: agents closed A3 (prior MED gap) as now-clean and did NOT re-report A1–A4 / recorded deferrals (DEPOSIT-011/DTR-002 deferral ≠ gap).
- Convergence is a signal: both lenses landed on epic-source-flows.md PULLOUT → complementary fixes, one refresh PR.
- Relay-not-decide (2a): R2 + AUTH-005 are scope/architect calls; B1/B2/R1 are money-surface phrasing → I aggregated + relayed a decision menu to the user, held dispatch for GO (mirrors the #225→#228 review-then-remediate split). Did NOT auto-dispatch refreshes.
- Ops hygiene: pg-writer flagged a dirty mb-next PRIMARY checkout (staged deletions of all 7 epics + reverted INDEX/README), misattributed to my wt-25 session — I have not touched mb-next this session. origin/main intact @12b9e1c. Routed to brew-ops (§3c), not self-fixed (Scope guard).

---
*Added via Oracle Learn*
