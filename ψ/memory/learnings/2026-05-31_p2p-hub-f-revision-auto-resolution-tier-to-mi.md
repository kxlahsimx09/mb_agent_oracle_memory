---
title: # p2p-hub §F REVISION — AUTO-RESOLUTION tier to minimize CS load (RATIFICATION_P
tags: [system-architect, p2p-hub, section-f, dispute-liability, auto-resolution, minimize-cs-load, campaign-231-supersede, thread-3, contest-window, model-1-recommended, thunder-api, s4-evidence, close-outcome-contract, fault-class-matrix, needs-legal-g1, source-funds-clawback, ratification-pending, p2p-support-exception-path, appendonly-overlay, admin-debit, b7.4-balance-cap, residual-risk, next-architect]
created: 2026-05-31
source: p2p-hub §F revision (auto-resolution tier); docs/design/p2p-hub-design-exploration.md §F; Oracle thread #3; supersedes campaign #231 §F (thread #232, PR #10)
project: github.com/kxlahsimx09/p2p-hub
---

# # p2p-hub §F REVISION — AUTO-RESOLUTION tier to minimize CS load (RATIFICATION_P

# p2p-hub §F REVISION — AUTO-RESOLUTION tier to minimize CS load (RATIFICATION_PENDING:3)

Directive (human via orchestrator, 2026-05-31): minimize p2p-support (CS) load in dispute resolution — every deterministically-decidable case becomes an AUTOMATIC decision; CS remains ONLY for genuinely-ambiguous cases. This REVISES §F, which was user-ratified `#decision` under campaign #231 (thread #232, merged PR #10 2026-05-27). Revision marked `RATIFICATION_PENDING:3` (Oracle thread #3) — supersedes the #231 framing per P-001 (superseded text retained, not deleted).

## Auto-decidability audit — revised 13-class matrix (each → AUTO or CS + close_outcome + deterministic predicate)

GROUP A — no dispute (UNCHANGED; already automatic in §C5 lifecycle, no close_outcome):
- deposit_not_arrived → EXPIRED/CANCELLED (no loss)
- slip_deadline_missed → EXPIRED (B1.4 hard cliff)
- no_fault_timing → opens dispute → no_action only if contested

NEWLY AUTO (deterministic predicate over thunder verdict ⟦S4⟧ + hub transition-log + counters → close_outcome, resolved_by='auto', append-only, no CS, no both-agree gate):
- wrong_amount → matched_incomplete. Predicate: thunder PASS at real-but-short amount. Each provider reconciles with own customer at actual amount; NO inter-provider debit → no money moves → no human. (was Group B mediated)
- customer_non_receipt → no_action if thunder=delivered (PSP-customer matter); else auto re-classify. Fully thunder-driven. (was Group B mediated)
- depositor_wrong_account / payout_bad_destination → customer_side_resolved BASE auto (re-pool/re-route, no money moves). Repeat-negligence → penalty_applied fires auto only when a published counter crosses threshold; penalty = admin_debit (⟦S2⟧) compensating record capped by hub balance (B7.4). (was Group B mediated)
- fake_slip → penalty_applied + provider_suspended. Predicate: thunder FAIL (forged). Auto-suspend on clear fraud evidence acceptable. (was Group C)
- verification_oracle_error → reattest_clean_resolved. Predicate: re-attest loop to clean verdict, then auto-route. (was Group C)
- recon_divergence → authoritative_upheld. Predicate: thunder+hub-log authoritative; auto-upheld UNLESS a divergence is positively proven (→ CS). (was Group C)
- hub_internal_error → hub_absorbed via admin_credit compensating record. Auto when hub-log positively shows the bug. (was Group C)
- destination_harvest_abuse → provider_suspended. Predicate: §B8.6 harvest-pattern counter over threshold; no monetary loss to split. (was Group C)

STAYS CS (genuinely-ambiguous / no deterministic evidence / money+legal):
- source_funds_clawback → penalty_applied/hub_absorbed — ⚖️ NEEDS-LEGAL (G1). Post-SETTLED reopen (B1.7); enforceability + shortfall to counsel. NEVER auto.
- Any auto-predicate that is INDETERMINATE (thunder ambiguous/unreachable, contradictory evidence, a proven recon divergence, a contested re-classify) falls through to CS.
- mediation_escalated stalemate fallback stays (B12.1 timeout exit).

## CS escape-hatch — the key design choice (RECOMMEND MODEL 1)
- Model 1 — auto-close + bounded contest window: hub auto-decides + writes close; either provider may CONTEST within a hub-clock-bounded window → only then route to CS. CS load = contested cases + ambiguous classes + stalemate. Fairness/fraud safety valve.
- Model 2 — auto-close final: no contest; CS only for no-evidence classes. Most aggressive CS cut, heavier-handed.
RECOMMENDATION = Model 1: satisfies "reduce CS as much as possible" (uncontested cases never touch CS) while preserving recourse for irreversible/penalty auto-actions. Contest window is PI-1 hub-clock bounded, auto-expires to final close (cannot stall). source_funds_clawback stays fully manual regardless.

## Invariants preserved
Non-custodial/no-escrow (PI-5 as narrowed by §D), append-only overlay + terminal-immutability (PI-3/B12.5), B1.4 hard cliff, hub-clock authority (PI-1). Auto-penalty/credit = compensating append-only records capped by hub balance (B7.4, ⟦S2⟧ admin_debit/admin_credit bites the single §D provider wallet = the enforcement teeth). source_funds_clawback ⚖️ NEEDS-LEGAL (G1).

## Residual risks (adversarial)
- Auto-suspend on a thunder false-negative wrongly suspends honest provider → Model-1 contest + verification_oracle_error re-attest path; suspension reversible (⟦S1⟧).
- Counter/threshold gaming → published+versioned in liability_terms (⟦S6⟧); increments append-only (⟦S3⟧/dispute_events).
- Collusive non-contest to launder an outcome → no money moves on the mediated-equivalent outcomes; penalty/suspend are evidence-gated not agreement-gated, so collusion buys nothing.
- recon_divergence auto-upheld masking a real divergence → auto-upholds ONLY when none proven; a §C10 ledger-digest mismatch forces CS.

## CS redefined
p2p-support = EXCEPTION path only: genuinely-ambiguous fault classes + (Model 1) contested auto-closes + mediation_escalated stalemate fallback.

## Notes / blockers
- Oracle trace table in this MCP instance is EMPTY; the campaign #231 trace chain (a9f9eea9→…→d457be4a, 6 links) lives in a different Oracle DB, so a programmatic arra_trace_link to #231 was NOT possible from here. Linkage is carried via tags (campaign-231-supersede) + this learning's source line + thread #3. Flagged in the handoff.
- PRD follow-up (next-writer lane, NOT done here): epic-dispute-liability.md DISPUTE-001..005 mirror §F and all change. Change-list handed off.

---
*Added via Oracle Learn*
