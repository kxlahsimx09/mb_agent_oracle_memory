---
title: p2p-hub fault-class catalogue (PR #18, docs/requirements/fault-class-catalogue.m
tags: [p2p-hub, docs, dispute, fault-class, liability, operator-reference]
created: 2026-06-01
source: next-product-writer
project: github.com/kxlahsimx09/p2p-hub
---

# p2p-hub fault-class catalogue (PR #18, docs/requirements/fault-class-catalogue.m

p2p-hub fault-class catalogue (PR #18, docs/requirements/fault-class-catalogue.md): authored a single operator-facing master table — one row per fault class with columns "Fault class | What happens | Raised/detected from | How it's decided | Outcome". It summarises the ratified §F.1 liability matrix as read at runtime and cross-refs DISPUTE-002 (does not supersede it).

Ground-truth mapping (P-004, all merged on origin/main, docs/design/p2p-hub-design-exploration.md):
- §F.1 = the 13 fault classes, close_outcomes, notes (the "what happens" column).
- §F.2 = dispute lifecycle / how disputes open (auto-final engine, append-only audit; the only non-auto transition = OPERATOR on proven §C10 recon digest-mismatch).
- §F.3 = close_outcome contract: 6 LIVE (matched_incomplete, no_action, customer_side_resolved, reattest_clean_resolved, authoritative_upheld, hub_absorbed) + 5 RESERVED→Phase2 (penalty_applied, provider_suspended, mediation_escalated, double_pay_handled, split_settled). resolved_by ∈ {auto, operator} only — no p2p-support, no legal.
- §G5 = verify service (app layer, not RPC) records thunder verdict ⟦S4⟧ into match_verifications then drives the transition RPC; transfer-window states INSTRUCTED→SENT→VERIFYING→SETTLED/EXPIRED.
- §G6 (ratified thread #5) = sharpened settle gate = genuine AND amount-matched AND delivered (delivered = slip receiver matches OUR destination, mask-aware last-4). A genuine-but-misdirected slip is NOT delivered ⇒ does not settle ⇒ routes to customer_non_receipt re-classify.
- §G8 = §F-predicate → verdict-field decision table (THE "how it's decided" column source). Key predicates: genuine∧actual≠M → wrong_amount; genuine∧actual==M∧delivered=false → customer_non_receipt(re-classify); genuine=false∧ambiguous=false → fake_slip(log-only); ambiguous=true → verification_oracle_error(re-attest backoff→cap; cap-exhaust ⇒ fail-safe EXPIRED, never CS); recon digest agree → authoritative_upheld, proven mismatch → OPERATOR; hub-log shows bug → hub_absorbed.

Four lanes: AUTO (engine, final) / OPERATOR (the one human path: proven §C10 digest mismatch) / ANALYTICS (destination_harvest_abuse, retrospective, no per-case close) / REMOVED (source_funds_clawback, Phase-2 deferred — thunder-confirmed slip = final in Phase 1). Group A (deposit_not_arrived, slip_deadline_missed B1.4 cliff, no_fault_timing) resolves in the §C5 match lifecycle as a match terminal, no close_outcome. CS/p2p-support is near-zero — decides nothing, only forwards the slip on request.

No source-doc ambiguity found: every escalation source and decision predicate was explicitly stated across §F.1/§G5/§G8; the docs are internally consistent. Process: cloned/edited in /tmp only (orchestrator write-guard), branched off fresh origin/main, docs PR to main, no auto-merge, no AI attribution. Pure table = no mermaid, so the docs-site mermaid gate was N/A.

---
*Added via Oracle Learn*
