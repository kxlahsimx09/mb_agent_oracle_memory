---
title: p2p-hub ⟦S5⟧ close_outcome↔matrix mapping FINALIZED + orphan/gap findings (threa
tags: [system-architect, repo:cross, next, p2p-hub, s5-disputes, close-outcome-enum, fault-class-mapping, mediated-vs-authoritative, mediation-stalemate, mediation-escalated, double-pay-handled-orphan, p2p-support-ratified, both-agree-gate, non-custodial-mediator, b12.1-timeout, enum-orphan-check, enum-gap-check, liability-matrix, thread-232, campaign-231, decision, contract-finalized]
created: 2026-05-27
source: docs/design/p2p-hub-design-exploration.md §C11/§B12.1 @ origin/main 3c0615f (kxlahsimx09/p2p-hub); thread #232 msg 1161 (ratify+ask) + msg 1162 (reply); builds on 2026-05-27_p2p-hub-dispute-centric-re-cast + _b14-phase-1-simplification
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# p2p-hub ⟦S5⟧ close_outcome↔matrix mapping FINALIZED + orphan/gap findings (threa

p2p-hub ⟦S5⟧ close_outcome↔matrix mapping FINALIZED + orphan/gap findings (thread #232 msg 1162, campaign #231, 2026-05-27). Design/spec, NO build. origin/main @3c0615f. User RATIFIED #2 (p2p-support role = LOCKED, mediation mode within hub-operator remit) + #3 (close_outcome enum + both-agree/authoritative split = ADOPTED as the ⟦S5⟧ contract).

MAPPING — 13 fault_classes → close_outcome → lane, three groups:
- GROUP A — NO dispute (resolve in the §C5 MATCH lifecycle, not ⟦S5⟧; close_outcome n/a): deposit_not_arrived→EXPIRED/CANCELLED · slip_deadline_missed (B1.4, renamed)→EXPIRED · no_fault_timing→(none; →no_action only IF a provider contests).
- GROUP B — MEDIATED (close needs dsp_agreed AND psp_agreed): wrong_amount→matched_incomplete · depositor_wrong_account→customer_side_resolved (→penalty_applied authoritative on repeat) · payout_bad_destination→customer_side_resolved (→penalty on repeat) · customer_non_receipt→no_action if thunder-delivered else re-classifies.
- GROUP C — AUTHORITATIVE (operator/evidence; no mutual-agreement gate): fake_slip→penalty_applied+provider_suspended · destination_harvest_abuse→provider_suspended · verification_oracle_error→reattest_clean_resolved · recon_divergence→authoritative_upheld · hub_internal_error→hub_absorbed · source_funds_clawback→penalty_applied/hub_absorbed (⚖️ legal).

ORPHAN: `double_pay_handled` is now UNUSED in Phase 1 (it was the B1.4 double-pay outcome; B1.4 = hard cliff with no dispute). DECISION (recommended): RESERVE for Phase 2 (re-introduce with the deferred reopen/double-detection machinery), don't ship in Phase-1 enum. No other orphans (other 8 each reached by ≥1 case).

GAP (the genuine finding): MEDIATION STALEMATE has no closing outcome. The mediated lane closes only on dsp_agreed AND psp_agreed; if they never both agree the dispute stalls → violates B12.1 (every non-terminal state needs a timeout+exit). RECOMMEND ADD `mediation_escalated`: on a mediation deadline, p2p-support escalates to hub-operator who closes AUTHORITATIVELY per the liability matrix. DURABLE DESIGN INSIGHT: a non-custodial mediator's both-agree lane MUST have an authoritative stalemate-breaker — it cannot force agreement, so it must be able to fall back to an operator ruling + the ⟦S2⟧/⟦S1⟧ levers. Otherwise both-agree is a deadlock surface.

BOUNDARY (not a gap): close_outcome is DISPUTE-scoped; Group-A no-dispute fault_classes resolve via the MATCH terminal (EXPIRED/CANCELLED), intentionally no close_outcome. Don't read "no close_outcome" as missing coverage.

SPLIT SANITY: consistent — fraud/abuse=authoritative, customer-reconcile=mediated, evidence/hub-decided=authoritative; mediated→authoritative escalations (repeat-negligence→penalty, stalemate→mediation_escalated) coherent. MINOR: ⟦S6⟧ liability_terms.liable_role includes `split` but no dedicated split close_outcome — lands as customer_side_resolved unless user wants explicit `split_settled` (low priority).

NET FINALIZED Phase-1 ⟦S5⟧ close_outcome enum (9): matched_incomplete · customer_side_resolved · penalty_applied · provider_suspended · hub_absorbed · reattest_clean_resolved · authoritative_upheld · no_action · mediation_escalated (NEW) — with double_pay_handled RESERVED→P2. (Net swap vs the msg 1138 enum: −double_pay_handled, +mediation_escalated.)

3 confirmations pending user: (a) reserve double_pay_handled→P2, (b) add mediation_escalated, (c) split_settled wanted?

---
*Added via Oracle Learn*
