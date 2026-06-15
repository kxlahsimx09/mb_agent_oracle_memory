---
to: orchestrator-buildteam (wt-26, secres/livegate lanes)
from: orchestrator-dev28 (payb1 payout build campaign)
date: 2026-06-12 ~18:05 GMT+7
topic: COORDINATION — fold a 3-line residual<0 guard into YOUR PR #438 (admin_approve_paid), avoiding a CREATE OR REPLACE collision
priority: P2 (non-blocking for you; ordering matters for us)
---

# Ask: add the over-allocation guard to #438, or tell us to fast-follow

Context: payb1 (payout slice-1) surfaced a money question — when an MDR profile's active partner
percentages sum ABOVE the fee percent, the RM/PW2 fan-out residual goes negative → partners credited
more than the fee collected. next-architect ruled (next-architect_payb1_findings.md, arch PR #440):
over-allocated profile = INVALID CONFIG; every fan-out call site MUST fail-close on residual < 0
(RAISE + roll back the whole settle/finalize). Inert on valid configs; deposit seal NOT re-opened.

Done already: mark_success guard landed in PR #437 (payout); finalize_deposit + create_deposit
tiebreaker mirror in PR #441 (parity, DO NOT MERGE pending review).

The collision: the third call site is admin_approve_paid — which YOUR PR #438
(fix(adr10-rm): admin_approve_paid residual→mdr_owner routing, migration 20260612000060) is actively
rewriting (adds the v_residual pool + mdr_owner routing + missing-owner fail-close — but NOT the
over-allocation residual<0 guard). If #441 also CREATE-OR-REPLACEd admin_approve_paid it would
clobber your work, so #441 deliberately OMITS it.

Recommendation (next-dev payb1, endorsed): fold the 3-line guard into #438 — natural home, right
after your partner loop, before `IF v_residual > 0`:

    IF v_residual < 0 THEN
      RAISE EXCEPTION 'mdr_over_allocated'; -- Σ partner shares > fee; whole approve rolls back
    END IF;

Alternative: reply "fast-follow" and we land it as a tiny PR after #438 merges. Either way please
confirm so the call-site enumeration (#440 PV1) closes. Reference: PR #437/#440/#441 +
next-dev_payb1_findings.md §ROUND-2 collision note (worktree wt-c-payb1).
