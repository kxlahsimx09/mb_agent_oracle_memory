---
title: # p2p-hub §F FINAL — auto-FINAL resolution, CS≈0, enforcement + clawback deferre
tags: [system-architect, p2p-hub, section-f, dispute-liability, auto-final, minimize-cs-load, cs-near-zero, campaign-231-supersede, f-v1-supersede, thread-3, contest-window-dropped, enforcement-deferred, clawback-removed-phase2, thunder-final, s4-evidence, s5-auto-engine, s3-silent-reputation, harvest-analytics, recon-operator-path, close-outcome-contract, fail-safe-expiry, fake-slip-log-only, accepted-residual-risk, ratification-pending, appendonly-overlay, next-architect, prd-change-list]
created: 2026-05-31
source: p2p-hub §F FINAL ruling (auto-final, CS≈0); docs/design/p2p-hub-design-exploration.md §F; Oracle thread #3; PR #12 commit 4e9eea5; supersedes §F v1 learning (2026-05-31_p2p-hub-f-revision-auto-resolution-tier-to-mi) and campaign #231 §F (thread #232, PR #10)
project: github.com/kxlahsimx09/p2p-hub
---

# # p2p-hub §F FINAL — auto-FINAL resolution, CS≈0, enforcement + clawback deferre

# p2p-hub §F FINAL — auto-FINAL resolution, CS≈0, enforcement + clawback deferred (RATIFICATION_PENDING:3)

Human ruling (confirmed 2026-05-31 GMT+7, via orchestrator) SIMPLIFIED §F much further than v1. v1 (earlier on thread #3, commit 8a0c03c) kept auto-penalties, auto-suspend, a both-agree mediated lane, and a 24–72h contest window. The human STRIPPED ALL OF THAT OUT. This learning supersedes the §F v1 learning (2026-05-31_p2p-hub-f-revision-auto-resolution-tier-to-mi.md) and the campaign #231 §F (thread #232, PR #10), per P-001 (superseded framing retained in the doc, not deleted). Implemented in PR #12 commit 4e9eea5 (SAME branch next-architect/p2p-hub-section-f-auto-resolution; NOT merged). Still RATIFICATION_PENDING:3.

## Core model: auto-FINAL
The Phase-1 dispute engine writes the close_outcome immediately and FINALLY (resolved_by='auto'). NO mediation lane, NO both-agree gate, NO contest window. Nothing punitive is auto-applied to a provider, so there is nothing to appeal — that is WHY the v1 contest window was removed. p2p-support decides nothing; its only residual role = forwarding the slip (evidence) on request (an ops courtesy). The ONLY genuine human decision left = an OPERATOR on a PROVEN §C10 ledger-digest mismatch (recon_divergence).

## FINAL fault-class matrix (class → disposition + outcome + predicate)
GROUP A — no dispute (unchanged, already auto in §C5): deposit_not_arrived (EXPIRED/CANCELLED), slip_deadline_missed (EXPIRED, B1.4 hard cliff), no_fault_timing.

AUTO (engine, resolved_by='auto', FINAL):
- wrong_amount → matched_incomplete — thunder PASS at real-but-short amount; each provider reconciles at the actual amount; no inter-provider debit. [unchanged from v1]
- customer_non_receipt → no_action — thunder OK ⇒ match valid/final. If payout side claims non-receipt, CS only forwards the slip (courtesy, NOT a decision). thunder not-delivered ⇒ auto re-classify + re-run.
- depositor_wrong_account → customer_side_resolved — depositor sent to wrong account = own fault ⇒ EXPIRED, depositor bears it. CS only informs. PENALTY ESCALATION DROPPED (vs v1).
- payout_bad_destination → customer_side_resolved — matched per thunder; payout provider gave wrong destination ⇒ PSP bears it. CS only forwards the slip. PENALTY ESCALATION DROPPED (vs v1).
- fake_slip → no_action LOG-ONLY — thunder FAIL ⇒ record a log entry only. NO auto-suspend, NO penalty (vs v1's auto-penalty+suspend). Enforcement out of the Phase-1 auto engine.
- verification_oracle_error → re-attest with exponential backoff + increasing timeout up to a cap; cap exhausted without clean verdict ⇒ FAIL-SAFE: do NOT settle / match EXPIRED + log (thunder can't confirm ⇒ no confirmation funds moved ⇒ don't pay). NOT routed to CS (vs v1's CS fall-through).
- recon_divergence → authoritative_upheld (uphold thunder+hub-log, do nothing) normal case. On a PROVEN §C10 ledger-digest mismatch ⇒ escalate to a human OPERATOR (internal accounting integrity, money-moving, very rare). THE ONLY HUMAN PATH.
- hub_internal_error → hub_absorbed (admin_credit compensating record, PI-3). [unchanged]

ANALYTICS (out of per-case engine):
- destination_harvest_abuse → NOT real-time auto-decidable. Retrospective analytics / batch detection feeding ops + ⟦S3⟧ reputation; no instant close_outcome (vs v1's auto-suspend).

REMOVED (Phase-2):
- source_funds_clawback → REMOVED / deferred. Thunder-confirmed slip = transfer succeeded = FINAL; the hub does NOT handle post-SETTLED source reversals/chargebacks in Phase 1. Removes the only post-SETTLED reopen (B1.7) AND the ⚖️ NEEDS-LEGAL G1 launch-blocker (clawback portion). (Q7 regulatory classification stays separately deferred — untouched.)

## close_outcome contract
LIVE Phase-1 (6): matched_incomplete · no_action · customer_side_resolved · reattest_clean_resolved · authoritative_upheld · hub_absorbed.
RESERVED → Phase 2 ("return when enforcement + mediation are built", P-001 not deleted): penalty_applied, provider_suspended (no auto-penalty/suspend), mediation_escalated (no mediation), plus double_pay_handled + split_settled.
resolved_by ∈ {auto, operator}. DROPPED p2p-support/legal + the dsp_agreed/psp_agreed + contest_* columns from v1.

## Substrate ⟦S1⟧–⟦S6⟧
Phase-1 CORE = ⟦S4⟧ thunder + ⟦S5⟧ auto-engine (append-only auto-resolution + audit log, NOT a mediation workflow) + ⟦S3⟧ silent reputation signals (NO punitive action attached; harvest detection depends on it). ⟦S6⟧ liability_terms = auto-rule config + published thresholds for analytics (not a countersigned mediation matrix). ⟦S2⟧ apply_credit_penalty + ⟦S1⟧ suspension are NO LONGER wired into the Phase-1 auto engine (operator/analytics-driven, deferred). Build order: ⟦S4⟧+⟦S5⟧ co-first → ⟦S6⟧ → ⟦S3⟧; ⟦S1⟧/⟦S2⟧ last + Phase-2-leaning.

## Accepted residual risks (stated plainly in F.6)
- fake_slip log-only: forged-slip provider NOT auto-suspended; operates until analytics/operator catches them. Fraud risk ACCEPTED for Phase 1.
- source_funds_clawback removed: post-settlement reversal/chargeback loss unhandled (someone eats it, no process). ACCEPTED.
- verification fail-safe expiry: a real-but-unverifiable transfer expires; funds may have moved, no settlement (same "bear it" as B1.4). Consistent.

## Invariants preserved
Non-custodial (PI-5), append-only overlay + terminal-immutability (PI-3/B12.5 — with clawback removed, Phase 1 has NO post-SETTLED reopen at all), B1.4 hard cliff (F.4 unchanged), hub-clock authority (PI-1). The only money the engine moves = hub_absorbed's admin_credit, a compensating record capped by hub balance (B7.4), no end-customer funds.

## Gates
No mermaid fences; sequenceDiagram in a bare ``` fence, state machines plain ASCII. check-mermaid.mjs scans only ```mermaid blocks → 0 blocks → passes.

## Notes / handoff
- Oracle trace table in this MCP instance was empty; campaign #231 trace chain lives in a different Oracle DB (not programmatically chainable here). Linkage carried via tags + this learning's source line + thread #3.
- next-writer PRD change-list (DISPUTE-001..005, epic-dispute-liability.md) handed off in the orchestrator report (NOT authored here — next-writer's lane).

---
*Added via Oracle Learn*
