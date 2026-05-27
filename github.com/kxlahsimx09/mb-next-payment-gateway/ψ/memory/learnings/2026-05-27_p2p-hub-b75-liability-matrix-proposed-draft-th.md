---
title: p2p-hub B7.5 liability matrix — proposed draft (thread #232 msg 1114, campaign #
tags: [system-architect, repo:cross, next, p2p-hub, b7.5, liability-matrix, fault-class, dispute, who-vouched, deposit-side, payout-side, non-custodial, enforcement-cap, admin-debit, source-funds-clawback, needs-legal, needs-user, verification-oracle-error, liability-terms, disputes-substrate, s5, s6, mobiz-precedent, slip-fraud, thread-232, campaign-231, handoff]
created: 2026-05-27
source: docs/design/p2p-hub-design-exploration.md §C11/§D7/§B7.5 @ origin/main 6f7517e (kxlahsimx09/p2p-hub); thread #232 msg 1114; mobiz services/slipFraudCheck.go@ef71420 + slipMatchHash.go@44f8634
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# p2p-hub B7.5 liability matrix — proposed draft (thread #232 msg 1114, campaign #

p2p-hub B7.5 liability matrix — proposed draft (thread #232 msg 1114, campaign #231, 2026-05-27). The G2 gate; feeds ⟦S5⟧ disputes + ⟦S6⟧ liability_terms. Design pass, NO build. Grounded §C11 + §D7 failure table + §B7.5 + mobiz precedent; origin/main @6f7517e (5 migrations, unchanged).

SPINE — "who vouched for what": DSP (deposit-side provider) vouches its depositor transfers + source-fund legitimacy + slip authenticity + correct amount to the given destination. PSP (payout-side) vouches the destination account it supplied (correct/open/usable) + honest receipt confirm. Hub vouches correct 1:1 matching + uncorrupted machine-readable destination delivery at INSTRUCTED + the §C8 verify gate ran + fee/deadline accounting. Loss follows the broken vouch.

PROPOSED `fault_class` ENUM (stable contract for both ⟦S5⟧ and ⟦S6⟧): deposit_not_arrived · depositor_wrong_account · payout_bad_destination · wrong_amount · fake_slip · source_funds_clawback · verification_oracle_error · late_deposit_double_pay · customer_non_receipt · destination_harvest_abuse · recon_divergence · no_fault_timing · hub_internal_error.

MATRIX (fault_class → liable party → tag):
- deposit_not_arrived (B1.1) → NO monetary liability, DSP reputation signal only (match cancels, hub absorbs verify cost CQ1). ✅
- depositor_wrong_account (B1.3a) → DEPOSIT-side. ✅ (mobiz precedent)
- payout_bad_destination (B1.3b/B1.6-supplied) → PAYOUT-side. ✅
- wrong_amount (B1.2) → DEPOSIT-side for the amount; partial-funds-already-at-destination recovery 🟠.
- fake_slip (B8.1) → DEPOSIT-side + SUSPENDED_HARD. ✅ (mobiz slipFraudCheck.go #360 + slipMatchHash #362)
- source_funds_clawback (B1.7) → DEPOSIT-side in-principle. ⚖️ NEEDS-LEGAL (enforceability cross-entity + balance-cap shortfall + AML tie B8.3/G1, sharpened by §D1 B2B-custodial reframe).
- verification_oracle_error (B1.5) → HUB-absorbs (thunder false ± with no gaming). 🟠 (vs provider-re-attest-under-penalty; thunder-vendor contract angle).
- late_deposit_double_pay (B1.4) → PSP-own-CS recovers duplicate from over-paid withdrawer (protocol-prevented by CANCELLED-irreversible; funds reached destination correctly). 🟠 (unrecoverable-withdrawer absorber; recommend PSP).
- customer_non_receipt (B7.1) → NO inter-provider liability when §C8 confirms delivery (PSP-own-CS, evidence handoff only); else collapses to wrong_account/fake_slip/oracle_error. ✅
- destination_harvest_abuse (B8.6) → abusing provider SUSPENDED_HARD + reputation; NO admin_debit (no monetary counterparty loss). ✅
- recon_divergence (B6.1) → provider whose ledger diverges from hub log. 🟠 (hub log = coordination truth, bank record via §C8 = settlement truth).
- no_fault_timing (B5.1–B5.4) → NO fault, hub clock binds (PI-1). ✅
- hub_internal_error (B2.1 double-match / corrupted delivery) → HUB-absorbs (compensating record PI-3, admin_credit). ✅

ENFORCEMENT COUPLING (honest teeth): every liable-row is enforceable ONLY via ⟦S1⟧ status/suspension + ⟦S2⟧ apply_credit_penalty, and CAPPED by the at-fault provider's hub-balance. loss>balance + walk-away → degrades to suspension+reputation+de-registration, NO make-whole (ratified B7.4/Q5 non-custodial ceiling). Present the matrix to providers + legal WITH this ceiling stated.

PLUG-IN: ⟦S6⟧ liability_terms(version, fault_class, liable_role∈{deposit,payout,hub,none,split}, split_ratio?, effective_from) — countersigned at C3 registration, version PINNED per-match at PROPOSED (no retroactive re-assignment). ⟦S5⟧ open_dispute tags fault_class; resolve_dispute reads liability_terms@version → maps liable_role → match's deposit/payout provider → liable_provider_id + penalty_amount → calls ⟦S2⟧.

MOBIZ PRECEDENT CAVEAT: slip-fraud blocks (slipFraudCheck.go@ef71420 #360 receiver-mismatch; slipMatchHash @44f8634 #362 reuse) confirm fake_slip + depositor_wrong_account land on the depositing side — BUT mobiz is single-gateway (gateway-vs-its-own-depositor); the INTER-PROVIDER allocation has NO direct precedent and is first-principles. pg-writer fan-out offered for the mobiz post-credit-reversal/clawback anchor (B1.7) if the user wants a current-system anchor.

6 contested calls open for user: (1) ratify ✅ rows; (2) ⚖️ clawback → legal; (3) oracle-error absorber; (4) wrong_amount partial recovery owner; (5) double-pay unrecoverable absorber; (6) recon truth-authority.

---
*Added via Oracle Learn*
