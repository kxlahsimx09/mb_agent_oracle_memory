---
title: p2p-hub B7 (dispute) + B8 (fraud) decision-ready deep-dive (thread #232 msg 1104
tags: [system-architect, repo:cross, next, p2p-hub, dispute, fraud, b7, b8, enforcement-substrate, non-custodial, admin-debit, provider-suspension, reputation, c8-verification, thunder-api, c11-dispute, c3-registration, liability-matrix, minimal-slice, build-first-ranking, needs-legal, regulatory-classification, cs-operator-delegation, accepted-residual, handoff, thread-232, campaign-231]
created: 2026-05-27
source: docs/design/p2p-hub-design-exploration.md §C8/§C11/§C3/§D8/§E2 @ origin/main 6f7517e (kxlahsimx09/p2p-hub); thread #232 msg 1104; deployed migrations 001-005 verified
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# p2p-hub B7 (dispute) + B8 (fraud) decision-ready deep-dive (thread #232 msg 1104

p2p-hub B7 (dispute) + B8 (fraud) decision-ready deep-dive (thread #232 msg 1104, campaign #231, 2026-05-27) — defense decomposition + the concrete minimal enforcement substrate + ranked build-first list.

Follow-up to the 72-case Phase B matrix (learning 2026-05-26_p2p-hub-phase-b-per-case-audit). User picked the B7+B8 deep-dive. Each case decomposed into 4 buckets: PROTOCOL-PREVENTS-WHEN-BUILT / CS-OPERATOR-DELEGATION / LEGAL-POLICY / ACCEPTED-RESIDUAL + a one-line user-decision. Covered B7.1/B7.3/B7.4/B7.5 (B7.2→B4.8) and B8.1–B8.9. Grounded p2p-hub origin/main @6f7517e (migrations 001–005 only; PR #8 merged the §E SPEC into the doc, not migrations 006–009 — enforcement substrate still unbuilt).

THE CONCRETE MINIMAL SUBSTRATE (turns the §D8 "teeth" + the C8/C11/C3 triad from design into defended) — tagged ⟦S1⟧–⟦S6⟧:
- ⟦S1⟧ Provider status+suspension: `providers.status provider_status` enum (specced §E2, unbuilt; providers stub = id/name/created_at) + admin RPC `set_provider_status(provider_id,status,reason,operator)`. The master off-switch every B7/B8 escalation needs.
- ⟦S2⟧ `admin_debit` penalty producer: `apply_credit_penalty(provider_id,amount,match_id,reason,operator)` SECURITY DEFINER — atomic balance debit + change_logs row op=admin_debit. **Enum value EXISTS, producer MISSING.** The only money a non-custodial hub can move (§D8 lever).
- ⟦S3⟧ Reputation: append-only `provider_signal_events` + `v_provider_reputation` view. Softest/derived; last.
- ⟦S4⟧ C8 verification: `match_verifications(match_id PK, thunder_result, dest_matched, receipt_confirm, verdict)` + thunder-API integration (EXTERNAL dependency) + gate SETTLED-requires-PASS / mismatch→DISPUTED. The truth oracle; today zero verification — settle_p2p_match fires from any VERIFYING row with no proof.
- ⟦S5⟧ C11 dispute workflow: `disputes(id,match_id,fault_class,opened_by,status,liable_provider_id,penalty_amount,resolution,resolved_by)` + open_dispute/resolve_dispute RPCs; resolve calls ⟦S2⟧(+⟦S1⟧). DISPUTED match-enum exists; workflow doesn't.
- ⟦S6⟧ C3 identity: `provider_keys` + `liability_terms` (versioned matrix ref) + KYC/legal-entity vetting fields + provider_id non-reuse. PI-7 wire-signing is a transport lift; minimal B7/B8-defending slice = liability_terms + vetting fields.

RANKED BUILD-FIRST (to make B7+B8 defended-not-just-designed):
1. ⟦S1⟧ (tiny — off-switch) → 2. ⟦S2⟧ (tiny — enum exists; converts B7.4 "no teeth" into a real bounded lever in ~a day) → 3. ⟦S4⟧ C8 thunder gate (highest single fraud-defense ROI: closes B8.1 fake-slip + gives independent corroboration for B7.3/B8.5/B1.5; ⚠ gated on external thunder-API integration decision) → 4. ⟦S5⟧ (CS/operator surface; wires #1+#2 into auditable workflow) → 5. ⟦S6⟧ (identity spine; bigger transport lift) → 6. ⟦S3⟧ (derived; last).

TWO USER/LEGAL GATES (block builds, not themselves buildable):
- G1 — B8.3/B11.4 legal classification: ESCALATE to counsel BEFORE launch; §D1's B2B-custodial reframe sharpened the exposure (hub no longer "holds no money"). LAUNCH-BLOCKING.
- G2 — B7.5 liability-matrix rows (fault-class→liable-party) + B8.7 vetting policy: user+legal authoring; prerequisite to ⟦S5⟧ fault-mapping and ⟦S6⟧ vetting.

DURABLE FRAMING: everything downstream of DISPUTED stays a CS/operator workflow BY DESIGN — the hub coordinates + penalizes hub-balance, never moves customer funds. The non-custodial enforcement ceiling (B7.4 accepted residual, ratified Q5): penalty is CAPPED by the at-fault provider's hub balance; a provider whose balance < the loss it caused, who walks away, cannot be forced to make-whole. CS role for B7.1 = evidence-provider only, never customer-refund.

---
*Added via Oracle Learn*
