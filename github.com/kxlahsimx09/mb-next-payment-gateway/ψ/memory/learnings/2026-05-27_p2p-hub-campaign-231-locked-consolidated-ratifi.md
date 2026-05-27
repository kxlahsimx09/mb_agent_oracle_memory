---
title: p2p-hub campaign #231 LOCKED — consolidated ratified dispute design (§F-candidat
tags: [system-architect, repo:cross, next, p2p-hub, campaign-231-locked, dispute-centric, section-f-candidate, liability-matrix, close-outcome-contract, p2p-support, s5-disputes, mediation-escalated, slip-deadline-missed, landing-recommendation, recommend-and-wait, supersedes-c11, open-items-menu, g1-legal, thunder-api, phase-e-parked-206, build-order, thread-232, decision, handoff, capstone]
created: 2026-05-27
source: docs/design/p2p-hub-design-exploration.md §C11/§E @ origin/main 3c0615f (kxlahsimx09/p2p-hub); thread #232 msg 1168 (lock-in) + msg 1169 (consolidated reply); consolidates campaign #231 learnings 2026-05-27 ×5
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# p2p-hub campaign #231 LOCKED — consolidated ratified dispute design (§F-candidat

p2p-hub campaign #231 LOCKED — consolidated ratified dispute design (§F-candidate) + landing recommendation (thread #232 msg 1169, 2026-05-27). NO build/PR. origin/main @3c0615f (5 migrations; §E still RATIFICATION_PENDING:206; no §F yet). This is the capstone of campaign #231: the whole dispute-centric P2P design is user-ratified and consolidated into one §F-candidate reference block.

ALL RATIFIED (user 2026-05-27): B1.4 slip_deadline_missed rename + R1/R2 acceptances · (a) double_pay_handled→RESERVED P2 · (b) mediation_escalated ADDED (B12.1 stalemate-breaker) · (c) split_settled NOT added (split closes as customer_side_resolved; reserved P2) · #2 p2p-support role LOCKED · #3 close_outcome enum + both-agree/authoritative split ADOPTED.

CONSOLIDATED SPEC (the §F-candidate block, single source replacing msgs 1114/1138/1152/1159/1162):
- F.0 framing: matrix = GUIDANCE to p2p-support↔DSP↔PSP mediation (close on both-agree), NOT auto-penalty; evolves §C11.
- F.1 liability matrix, 13 fault_classes, 3 groups: A no-dispute (deposit_not_arrived, slip_deadline_missed, no_fault_timing → match terminal, no close_outcome) · B mediated (wrong_amount→matched_incomplete, depositor_wrong_account/payout_bad_destination→customer_side_resolved, customer_non_receipt→no_action) · C authoritative (fake_slip→penalty+suspend, destination_harvest_abuse→suspend [deposit-side harvester per §B8.6], verification_oracle_error→reattest_clean_resolved, recon_divergence→authoritative_upheld, hub_internal_error→hub_absorbed, source_funds_clawback→penalty/hub_absorbed ⚖️legal).
- F.2 ⟦S5⟧ state-machine (OPEN→EVIDENCE_GATHERING→IN_MEDIATION⇄→AWAITING_BOTH_AGREE→CLOSED; +RE_ATTESTING/ESCALATED_OPERATOR/ESCALATED_LEGAL) + p2p-support mediator role + disputes/dispute_events substrate; terminal-immutability via append-only overlay keyed by match_id (no state-flip; only B1.7 reopens post-terminal in P1).
- F.3 close_outcome contract: LIVE 9 = matched_incomplete·customer_side_resolved·penalty_applied·provider_suspended·hub_absorbed·reattest_clean_resolved·authoritative_upheld·no_action·mediation_escalated; RESERVED→P2 = double_pay_handled, split_settled. Mediated outcomes need dsp_agreed AND psp_agreed; authoritative don't. Stalemate → mediation_escalated (operator authoritative close).
- F.4 B1.4 hard slip-deadline cliff + R1/R2.
- F.5 substrate ⟦S1⟧–⟦S6⟧ + build order ⟦S4⟧+⟦S5⟧ co-first → ⟦S1⟧/⟦S2⟧ → ⟦S6⟧ → ⟦S3⟧. Nothing built this campaign.

LANDING RECOMMENDATION (recommend + WAIT, NO PR until user GO): land as new §F — Dispute & Liability (Phase 1) in docs/design/p2p-hub-design-exploration.md, PR off fresh origin/main, §C/§D/§E cadence; mark §F #decision (ratified, NOT RATIFICATION_PENDING); §F SUPERSEDES §C11's enforcement framing with a cross-ref (P-001: §C11 kept + pointer, mirrors how §D narrowed PI-5/A7); design-only, no migrations. On GO: next-architect drafts §F + §C11 pointer in one PR.

OPEN MENU (the "next" after this round): (1) ⚖️ G1 legal LAUNCH-BLOCKING — B8.3/B11.4 regulatory classification (sharpened by §D1 B2B-custodial reframe) + source_funds_clawback B1.7 enforceability → counsel; (2) thunder-API commit gates ⟦S4⟧ (biggest fraud-defense ROI; credential+cost); (3) B8.7 Sybil-vetting policy (user+operator); (4) the ⟦S1⟧–⟦S6⟧/⟦S5⟧ build (next-impl, post-§F + thunder decision); (5) PARKED §E impl (separate track thread #206: PR #8 merged the spec but migrations 006–009 unbuilt; RATIFICATION_PENDING:206 still on main line 1944 — needs its own ratify-or-not + build disposition); (6) Phase-2 reserved (double_pay_handled, split_settled, B1.4 double-pay machinery: reopen/double-detection/D-tree/duplicate-hold).

Campaign #231 trace chain: a9f9eea9 (B7/B8 deep-dive) → ceebfc77 (liability matrix) → 2d1266ba (dispute-centric recast) → 4be2356f (B1.4 simplification) → 6fc9c884 (close_outcome mapping) → THIS (lock-in/consolidation).

---
*Added via Oracle Learn*
