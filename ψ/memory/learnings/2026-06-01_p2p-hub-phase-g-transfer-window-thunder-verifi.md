---
title: p2p-hub Phase G — Transfer-Window & Thunder Verification (design-pass, RATIFICAT
tags: [p2p-hub, thunder-verification, transfer-window, mock-seam, fraud-defence, section-F, section-E]
created: 2026-06-01
source: system-architect — Phase G design-pass (thread #5, PR #16)
project: github.com/kxlahsimx09/p2p-hub
---

# p2p-hub Phase G — Transfer-Window & Thunder Verification (design-pass, RATIFICAT

p2p-hub Phase G — Transfer-Window & Thunder Verification (design-pass, RATIFICATION_PENDING:5, PR #16). Replaces the §E7 advance_to_verifying "1A-COLLAPSE SEAM" with the real INSTRUCTED→SENT→VERIFYING path; it is the single true blocker for BOTH the real settle path AND the ratified auto-final §F (thread #3), which decides ~every dispute class off the thunder verdict ⟦S4⟧ and build-orders it co-first (§F.5). Continues thread #4's §E ratification, which pre-flagged this as the next build and the two §E8 seams it must close.

KEY DESIGN DECISIONS:
- ThunderClient SEAM (TS/Bun): one interface, two impls (MockThunderClient + RealThunderClient), selected by config (THUNDER_CLIENT=mock|real). The normalized verdict carries ONLY what thunder supplies (genuine←success, actualAmount←rawSlip.amount.amount, transRef, receiverProxy←rawSlip.receiver.account.proxy.account masked-ok, senderBank, transferDate, errorCode/message, ambiguous, raw escape-hatch for the schemaless `data`). "delivered" + "amountMatched" are DERIVED ABOVE THE SEAM (thunder supplies NEITHER — exactly as mobiz does).
- The thunder call lives in the Bun/Supabase-EDGE app layer, NOT a Postgres RPC (RPCs can't make external HTTP). Same pattern as the deployed admin-approve-topup edge fn. The verify service records the verdict into ⟦S4⟧ match_verifications, then drives the DB transition via RPC (→SETTLED via deployed settle_p2p_match §D4 / →EXPIRED fail-safe / →§F dispute overlay).
- MOCK emits mobiz's EXACT {success,data:{rawSlip:{…}}} JSON; per-scenario fixtures exercise every §F class; switch-to-real is config-only.
- Transfer-window substrate: ADD VALUE 'INSTRUCTED' then 'SENT' BEFORE 'VERIFYING', EACH in its own enum-add migration step (§E4 same-tx caution — Postgres forbids USING a freshly-added enum value in the adding tx). PI-6 destination reveal at INSTRUCTED.

THE 3 MOBIZ CONTRACT GAPS (mobiz hit these in production):
1. NO "delivered" verdict — thunder success:true only means slip is a GENUINE bank transfer, NOT that funds reached OUR destination. mobiz found ~905 fraud cases (~1.07M THB) of genuine slips paid to a 3rd party → built a receiver-account match (slip receiver.proxy.account vs expected destination, MASK-AWARE last-4 compare). DESIGNED IN + surfaced the §F SETTLE-PREDICATE SHARPENING for human ratify: settle-gate := genuine AND amount-matches AND receiver-matches-destination. This is a REFINEMENT to §F's predicate EVALUATION (makes the customer_non_receipt "delivered" test concrete), NOT a change to §F's dispositions (close_outcome set unchanged). A genuine-but-misdirected slip ⇒ NOT delivered ⇒ customer_non_receipt re-classify, NOT SETTLED.
2. NO "amount matched" boolean — thunder gives rawSlip.amount.amount (actual); compare client-side → wrong_amount → matched_incomplete.
3. success:false is OVERLOADED (fake slip vs OCR/transport/timeout). SPLIT via an explicit `ambiguous` flag: genuine=false AND data present (fraud-ish errorCode) → fake_slip (log-only, §F); ambiguous=true (transport/timeout/parse, NO data) → verification_oracle_error → exp-backoff re-attest to a cap → fail-safe EXPIRED. Discriminator = `data` present (decided bad slip) vs absent (undecided error). Never a fraud verdict on ambiguity.

CLOSED the two §E8 seams §F needs (flagged by §E8 note + thread #4): (a) EXPIRED-from-VERIFYING transition (1A had no VERIFYING exit except settle); (b) post-charge charged-fee refund-to-balance — post-ACCEPTED terminals were already CHARGED (§E6 balance-=F), so a non-settle terminal must refund balance += F (§C7 CQ1) + release the reserved stake M. The 002 enum has fee_refund (reserved-=F) + release_reserve but NO balance-credit op — recommend a new fee_refund_charged value so the audit trail names which kind; fee_refund must NOT be silently overloaded. Implement EXPIRED per ratified §F, NOT the superseded §C5/§D7 FAILED/DISPUTED routing.

PROCESS NOTES: mermaid gate — NEVER ```mermaid for stateDiagram/flowchart (the docs-site check-mermaid.mjs parses every ```mermaid block with the real parser); used plain ``` ASCII for state machines (zero ```mermaid fences in the doc). Cross-DB caveat: this MCP can't chain to §E thread #206 / campaign #231/#232 — linkage by tags + source lines. Reference: §C8 thunder gate, §C5 lifecycle, §E7 collapse seam, §E8 fee_refund seam, §F.1 dispositions, §F.5 ⟦S4⟧/⟦S5⟧, thread #3 (§F ratify), thread #4 (§E ratify), thread #5 (this Phase G).

---
*Added via Oracle Learn*
