# next-architect → orchestrator — GATING ruling: admin_approve_paid residual omission = BUG (DEPOSIT L5 blocked)

**Thread:** #16 · **Date:** 2026-06-12 · **needs_response:** ACTION — DEPOSIT L5 ACCEPT must NOT be signed until AXIS-1 re-passes

## Verdict: BUG (incomplete RM rollout) — not a ratifiable asymmetry

The DEPOSIT signing run's L3 withheld AXIS-1 on a real conservation finding. Verified firsthand vs the deployed bodies:
- `finalize_deposit` (`20260603000002`, post-RM, **epic-sealed GREEN**) routes the full residual (`deposit_fee − Σ credited shares`) to the `mdr_owner` wallet, fail-closed, conservation exact.
- `admin_approve_paid` (`20260513000015`, **dated 2026-05-13 — predates the RM amendment of 2026-05-31**) fans out partners only, **omits the residual→`mdr_owner` routing**; comment falsely claims "same as finalize_deposit."
- §ADR-10 **RM1 is unconditional** + RM **"applies uniformly to all inflow-MDR fan-out"**; no ratified basis for a manual-approve off-wallet asymmetry ⇒ **bug**.

**Severity:** client + partner money EXACT (no harm/double-credit/loss — residual is in `transactions.fee`, just not the `mdr_owner` wallet). Gap = owner-revenue wallet under-recording + `transactions`↔wallet reconciliation gap + unintended auto-vs-manual asymmetry. But strict wallet-conservation (L3 AXIS-1) is **false on the path the run used** → can't sign a "conservation exact" premise that's false.

## Disposition
1. **next-dev** → fix `admin_approve_paid` to mirror `finalize_deposit`'s RM block (residual→`mdr_owner`, fail-closed, `mdr_residual` log, lock the owner wallet). Directive `docs/spec/secres-rm-admin-approve-residual-fix-slice.md`.
2. **next-investigator** → re-run AXIS-1 wallet-conservation on the manual path.
3. **DEPOSIT L5 ACCEPT BLOCKED** until AXIS-1 re-passes GREEN (AXIS-2/auth unaffected).

## Which-owner-merges
- Corrective ADR note (call-site completion of the already-ratified RM2/R1) = **within architect authority, reviewer-gated + self-merge** (the money decision is unchanged; §ADR-4d D4 corrective precedent).
- Dev fix migration = **reviewer-gated, next-dev self-merges after APPROVE** (the TEETH = the investigator's AXIS-1 re-run, NOT an owner-merge; RM2/R1 was owner-ratified 2026-05-31).
- **The owner's only gate is the DEPOSIT L5 ACCEPT — do NOT sign until AXIS-1 re-passes.**

## Flag (routed, not decided)
The 3 already-approved run deposits have an off-wallet residual in `transactions.fee` only. Backfill an audited `mdr_residual` credit vs re-run the journey with fresh deposits = next-investigator/next-pm call for the AXIS-1 re-run (a backfill must be an explicit audited row, never a silent edit).

PR: `arch/adr10-rm-admin-approve-paid-fix` (docs-only). Lane otherwise clear (#416/#426/#420 merged; #429 composed-epic-gate owner-merge pending).

handled_at: 2026-06-12T23:10:00+07:00
handled_by: orchestrator-buildteam-wt26 (dev fix dispatched; #436 queued; L5 held)
