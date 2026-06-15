---
title: orchestrator team-dispatch — PAYOUT slice-1 full build-workflow cycle (Step 0-4)
tags: [orchestrator, team-dispatch, 2b, accepted, build-workflow, payout, spec-first, contract-rulings, dpay-grounding, relay-not-verdict]
created: 2026-06-12
source: campaign payb1 + payb1t + payb1ops + payb1i + payb1r + payb1pm (orchestrator wt-28-dev, 2026-06-12)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# orchestrator team-dispatch — PAYOUT slice-1 full build-workflow cycle (Step 0-4)

orchestrator team-dispatch — PAYOUT slice-1 full build-workflow cycle (Step 0-4) in ONE session, accepted. Shape: SPEC-first parallel build with 3 mid-flight contract questions (Q1 profile non-determinism, Q2 PW2 over-allocation, C1 claimed-vs-processing) + a post-merge rounding corollary (PV1-R) — all ruled by a campaign architect WITHOUT blocking the lanes (tester made the contested binding swappable: SHARE_BASE switch + record-only C1 hedge until ruled). Load-bearing moves: (1) held the cross-stack deploy until the money-question (Q2) was ruled — deploy once, not twice; (2) tester worktree structurally separate from dev (de-bias layer 1) — campaign slug payb1t vs payb1 because the dispatch helper shares worktrees per campaign×repo; (3) empirical dpay-prod census mid-campaign (owner asked "does mdr_owner exist in current?") surfaced that prod itself silently over-distributes a satang 18,659 times (independent half-up rounding, no remainder adjustment, zero-headroom configs) → routed back to the architect who ruled PV1-R: next-system is Model A (residual=remainder) so the leak structurally cannot recur, migration must map Owner-MDR-partner→residual (option d, exclusive), tolerance/banker's REJECTED, guard correct as-landed; (4) orchestrator did NOT verdict the 2 first-run VERIFY REDs (looked substrate-side, were both probe-side — tester ground-truth-classified them; relay-don't-verdict validated again); (5) merge gates: investigator GREEN(77/77) + reviewer APPROVE verified-on-PR before each self-merge (the #432 lesson held — tester even self-HALTED on the stale DO-NOT-MERGE title until re-signaled). Outcome: #437/#439/#440/#441 merged same session (440/441 by owner), stacks current incl. parity 000070, PM marked slice-DoD on 6-item verified evidence chain, payout epic correctly NOT marked (seal+LIVE owed).

---
*Added via Oracle Learn*
