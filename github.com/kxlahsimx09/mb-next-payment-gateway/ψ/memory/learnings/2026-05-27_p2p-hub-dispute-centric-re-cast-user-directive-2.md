---
title: p2p-hub dispute-centric RE-CAST — user directive 2026-05-27 (thread #232 msg 113
tags: [system-architect, repo:cross, next, p2p-hub, dispute-centric, liability-matrix, p2p-support-mediator, s5-disputes, fault-class, mediation-workflow, both-agree-gate, close-outcome-enum, terminal-immutability, append-only-overlay, b1.4, expired-dispute-reopen, double-pay-detection, duplicate-suspected-hold, verification-oracle-error, reattest-loop, matched-incomplete, thunder-authoritative, design-directive, thread-232, campaign-231, decision, handoff]
created: 2026-05-27
source: docs/design/p2p-hub-design-exploration.md §C5/§C8/§C11/§B1.4/§B7.5 @ origin/main 3c0615f (kxlahsimx09/p2p-hub); thread #232 msg 1135 (user directive) + msg 1138 (reply)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# p2p-hub dispute-centric RE-CAST — user directive 2026-05-27 (thread #232 msg 113

p2p-hub dispute-centric RE-CAST — user directive 2026-05-27 (thread #232 msg 1138, campaign #231). Reframes the B7.5 liability matrix and elevates ⟦S5⟧ disputes to the design spine. Design/spec, NO build. origin/main @3c0615f (PR #9 = docs-only §B8.6 role-correction, harvester=deposit-side; no substrate change, 5 migrations; stub match_status has EXPIRED + DISPUTED).

THE PIVOT (user ruling, binding): the p2p-hub's PRIMARY resolution mechanic is **DISPUTE + p2p-support-mediated conversation** — p2p-support ↔ DSP ↔ PSP talk, anchored on the countersigned liability matrix, until **BOTH sides agree to close**. The matrix is a **guide to that conversation, NOT an auto-penalty engine**. ⟦S2⟧ apply_credit_penalty demotes to ONE close-outcome (fraud/clear-fault), not the default. "Most p2p cases use the dispute mechanic as the primary tool and resolve through conversation to close on both sides." Design TO that.

4 CONTESTED-ROW RULINGS (verbatim, applied):
1. verification_oracle_error (B1.5): hub-absorbs ALWAYS, NO bank-record re-adjudication. Match → DISPUTED, STAYS disputed until hub re-attests via thunder UNTIL THUNDER NO LONGER ERRORS, then the clean verdict decides direction (close_outcome reattest_clean_resolved).
2. wrong_amount short (B1.2): thunder confirms REAL but short → DISPUTED → DSP & PSP each reconcile with their OWN customer at the actual amount → close matched_incomplete (partial). NO inter-provider auto-debit.
3. late_deposit_double_pay (B1.4) CORRECTION: system-bank does NOT auto-pay on expiry (prior "PSP fell back + paid" was WRONG). Default: late deposit → just EXPIRED. EDGE: late slip arrives AFTER EXPIRED + thunder-confirms-real → flip EXPIRED→DISPUTE (overlay), then double-detect.
4. recon_divergence (B6.1): thunder + hub-log = final/authoritative; a provider with counter-evidence may open a DISPUTE to pause before resolution (close authoritative_upheld unless real divergence).

MATRIX RECAST (fault_class → dispute-resolution-path), three groups:
- (I) MEDIATED (both-agree close): wrong_amount→matched_incomplete · depositor_wrong_account→customer_side_resolved · payout_bad_destination→customer_side_resolved · customer_non_receipt→conditional(thunder first) · late_deposit→see B1.4 · recon_divergence→authoritative_upheld · hub_internal_error→hub_absorbed(admin_credit).
- (II) AUTO/NON-MEDIATED (no mutual agreement): fake_slip→penalty_applied(⟦S2⟧)+provider_suspended(⟦S1⟧ SUSPENDED_HARD) · destination_harvest_abuse(deposit-side per §B8.6 @3c0615f)→provider_suspended · deposit_not_arrived→EXPIRED+reputation · no_fault_timing→no_action(hub clock PI-1).
- (III) SPECIAL LOOPS: verification_oracle_error→reattest-until-clean(hub-absorbs) · source_funds_clawback→⚖️ NEEDS-LEGAL (G1, post-SETTLED overlay reopen + legal co-mediator, penalty capped by hub-balance).

⟦S5⟧ SPINE DESIGN: p2p-support = explicit mediator role (operationalizes §A3 hub-operator adjudication, in MEDIATION mode). State machine: OPEN→EVIDENCE_GATHERING→IN_MEDIATION⇄loop→AWAITING_BOTH_AGREE→CLOSED; + RE_ATTESTING (oracle_error), ESCALATED_OPERATOR (fraud/abuse), ESCALATED_LEGAL (clawback). Tables: disputes(id, match_id, fault_class, opened_by, status, matrix_version, authoritative_evidence, dsp_agreed, psp_agreed, close_outcome, liable_provider_id?, penalty_amount?, resolution_note, resolved_by) + dispute_events(append-only conversation/evidence log, P-001). close_outcome enum: matched_incomplete · customer_side_resolved · penalty_applied · provider_suspended · hub_absorbed · reattest_clean_resolved · authoritative_upheld · double_pay_handled · no_action. KEY: mediated outcomes need dsp_agreed AND psp_agreed; authoritative/operator outcomes (penalty/suspend/hub_absorbed/reattest/authoritative_upheld) do NOT (can't make a fraudster agree).

TERMINAL-IMMUTABILITY SOLUTION (B12.5/P-001): a dispute is an **append-only overlay keyed by match_id, NOT a state-flip on the match**. Opening a dispute on EXPIRED/SETTLED does NOT mutate matches.status — inserts a disputes row; terminal row stays immutable; resolution emits a NEW compensating record. match_status='DISPUTED' enum value used ONLY for in-flight (pre-terminal) disputes; post-terminal reopens are pure overlay. v_match_effective_state derives "EXPIRED (disputed)" by join.

B1.4 MECHANICS: reopen trigger = late TransferSent on EXPIRED + thunder-confirms-real-transfer-at-destination (a late slip with NO real transfer is just refused per §C5). Double-detection = did PSP customer open a NEW payout obligation already at INSTRUCTED for same dest+amount+customer-ref, created after expiry? NO→customer_side_resolved (PSP+customer: accept-as-success or refund). YES→double-pay risk → ranked handling: D-1/D-3 cancel fresh obligation's deposit-leg + let the late deposit satisfy it (one payment — PREFERRED, needs fresh-leg still cancellable) / D-2 unwind after both land (PSP recovers duplicate from over-paid customer) / D-4 manual-ops (hub can't make-whole). 🟠 PROTOCOL RECOMMENDATION (needs user nod): add a "duplicate-suspected hold" — hold a matching fresh obligation's deposit-leg instruction when an EXPIRED match reopens with a late real transfer, to buy the D-1/D-3 cancellation window.

SHAPE CHANGES: ⟦S5⟧ disputes = SPINE (mediation workflow, not auto-penalty machine). ⟦S2⟧ = one outcome. ⟦S6⟧ liability_terms still versioned/countersigned/pinned-per-match-at-PROPOSED but role shifts to "guidance anchor the mediator opens with." ⟦S4⟧ thunder rises to CO-PRIMARY with ⟦S5⟧ (authoritative evidence settling rulings 1/2/4). Revised build order: ⟦S4⟧+⟦S5⟧ co-first → ⟦S1⟧/⟦S2⟧ escalation levers → ⟦S6⟧ → ⟦S3⟧ last.

3 OPEN ITEMS for user: (1) B1.4 handling tree + duplicate-suspected-hold nod; (2) p2p-support role confirm; (3) close_outcome enum + both-agree-vs-authoritative split as the ⟦S5⟧ contract.

---
*Added via Oracle Learn*
