---
title: Settlement fee is CONFIG-0 (dormant rate-driven mechanism), NOT structurally abs
tags: [system-architect, repo:mb-next-payment-gateway, next, migration-map, settlement, mdr, fee, adr-12, thread-236, config-gated, wallet, correction]
created: 2026-05-26
source: mobiz SettlementController.go:268-270/831/1035 + withdrawalQueue.go:1499-1512 + models/mdr_profile.go:22 + models/settlements.go:32-40 + dpay prod (mdr_profiles all settlement_fee=0; fee on 7/2986; 100% approved_by) + thread #236
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Settlement fee is CONFIG-0 (dormant rate-driven mechanism), NOT structurally abs

Settlement fee is CONFIG-0 (dormant rate-driven mechanism), NOT structurally absent — refines the MDR-free finding (thread #236).

CORRECTION/REFINEMENT of [[2026-05-26_settlement-is-mdr-free-production-distributes-ze]]: that learning's DATA conclusion stands (prod distributes ~0 settlement MDR), but its characterization "the ApproveSettlement MDR branch NEVER FIRES / dead-path" is IMPRECISE. User asked the exact right question (structural-absent vs config-0); a code+data read (P-004) shows it is CONFIG-0, and the branch DID fire briefly.

VERIFIED IN BOTH CODE AND DATA (mobiz @local + dpay prod, 2026-05-26):

CODE (the fee MECHANISM EXISTS and is fully wired — rate-driven, no boolean flag):
- mdr_profiles.settlement_fee (float rate) — models/mdr_profile.go:22.
- CreateSettlement computes fee = round(amount * mdrProfile.Settlement/100) at create-time and stores settlements.fee + final_amount; debits amount+fee — SettlementController.go:268-270, 295, 331.
- On bank-success the withdrawal-queue dispatcher fires distributeMDRFees(...) GATED on `settlement.Fee > 0` — services/withdrawalQueue.go:1499-1512 (gate at :1509). So rate=0 → fee=0 → guard short-circuits; rate>0 → fee collected + partner wallets credited.
- settlements model carries full MDR fields (Fee, MDRProfileID, MDRDistributions, TotalDistributed) like deposit/payout. ApproveSettlement itself only enqueues (distribution is at completion, not approve); ConfirmReview success branch skips MDR (the tester learning — a manual override path).
- Two mobiz bugs NOT to inherit: settlement path never writes mdr_distributions back to the doc; distributeMDRFees looks up `clients` by EntityID so partner-entity settlements silently skip distribution.

DATA (mechanism is DORMANT, not dead):
- All 30 mdr_profiles have settlement_fee = 0 (vs deposit_fee 1.0-2.4% + payout_fee 0.2-0.4%, both actively used).
- settlements.fee populated on 7 of 2,986 docs, all at 2.0%, in a 2-week window (late-Mar→early-Apr 2026), then reverted to 0 → the branch DID fire for those 7. 2,979/2,986 carry no fee.
- No settlement_fee/settlement_mdr rate field on clients/partners/merchants (only min/max_settlement bands + enable_settlement toggle + mdr_profile_id pointer). No app_settings/system_settings settlement-fee toggle.
- 100% of completed settlements (2,797) went through admin ApproveSettlement (approved_by/approved_at populated) — it is the sole completion path.

VERDICT: a future settlement fee is enable-able by config (set a profile's settlement_fee > 0) — NO new dev in mobiz. So it is CONFIG-0 / dormant-rate, not structurally absent.

KEY REFRAME: a settlement fee is the settlement-flow analog of the actively-used payout_fee (both withdrawal-side) — it is a WITHDRAWAL-SERVICE fee, NOT a second charge of inflow MDR. So charging it is not "double-MDR"; whether to charge is a pure product/revenue choice. (Mobiz conflates them by storing settlement_fee inside the mdr_profile.)

ARCHITECT RECOMMENDATION (Q2, do NOT bind — user's call): (b) PRESERVE a config-gated settlement-fee capability, DEFAULT OFF (rate 0). Low-regret: the fee-profile substrate exists anyway (deposit/topup/payout MDR + payout_fee), so adding a settlement_fee rate column (default 0, folded into the §ADR-10 freeze at create like payout_fee) is trivial and avoids a future redesign; it was even briefly live, so it's a real lever. Model it as an EXPLICIT withdrawal-service fee (NOT inside an "MDR" profile) and DON'T inherit the two mobiz bugs. Phase-1 observable = no fee (rate 0), so SETTLE-001/002 ACs hold either way. OMIT (a) is viable but needs new dev if the business ever wants settlement withdrawal fees. Escalated to user for the final call.

---
*Added via Oracle Learn*
