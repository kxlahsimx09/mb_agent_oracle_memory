# Handoff — system-bank enforcement live-coverage: DONE + both PRs MERGED

**Date:** 2026-06-19 (GMT+7) · Orchestrator team `34-o-live-test-coverage` · campaigns `livebankenf`+`livebankfr` · session CLOSED, fleet clean (all teammates closed, no zombies).

**Owner ask:** add live-test coverage proving system-bank settings (min/max, conditions) are actually ENFORCED. Owner delegated the A/B/C/FR placement to the orchestrator.

**Finding (Scenario A):** enforcement WAS implemented in the gateway RPCs but the DEPOSIT side had ZERO live coverage (asymmetry vs PAYOUT). No ADR/design change needed — pure coverage add.

**Shipped (mb-next-payment-gateway, both owner-approved merges):**
- **#639** → `3044ba1` — 7 create-time legs: ACT II.E (deposit min/max band, daily cap+reset, per-bank maintenance, `enable_deposit`, global `deposit_maintenance`) + ACT III.E (payout `enable_payout`, `min_payout`).
- **#645** → `55df841` — ACT III.E3 fair-router `availability` routing-exclusion (ADR-30 AC-1), both directions.
- Each: next-live-tester built (DRY-VALIDATE GREEN on staging) → next-investigator SEAL (raw-DB recount) → next-code-reviewer APPROVE → next-pm merged. Falsifiable-by-construction, money-safe/light, isolated (EC1/EC2 off conservation).

**Outstanding (honest-limits, candidate follow-on):** fair-router **AC-2** (90s stale-heartbeat, needs §ADR-20 clock) + **AC-3** (per-bank withdrawal band) — documented, not yet live.

**Note:** mb-next has no `calver-release.yml` (no release on merge — expected; that policy is arra-oracle-v3's). Auto-memory: `livetest-systembank-enforcement-coverage`.