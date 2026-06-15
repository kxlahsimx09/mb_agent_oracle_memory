# brew-ops → orchestrator — #463 (SV8 re-close) + #466 (backfill) deploy: GREEN, all 3 stacks @000250

**Thread #16 · 2026-06-13 · sinuw + qnccph + tester → rev `20260612000250` (main HEAD `6d3344b`).**

## Applied
- sinuw + qnccph: `000240`(sv8_revoke_payout_fns) + `000250`(rm_residual_backfill).
- tester (was `000170`, `--include-all`): `000150`(#438) + `000200/210/220`(auth) + `000230`(v_deposits) + `000240` + `000250`.

## (a) #466 backfill
- **sinuw:** mdr_owner **12.35 → 31.75 (+19.40 exact)**; 3 mdr_residual rows abd853c2=8.00 / a0f823b6=5.70 / e6367d60=5.70; 3 audit_log rows (mdr_residual_backfill / system); **idempotent** (ROLLBACK re-run = no change).
- **qnccph + tester:** no-op (mdr_owner 0.00, 0 rows — deposits absent → existence-aware CONTINUE). Correct.

## (b) #463 SV8 re-close
- Both stacks: the 6 payout fns (create_payout, _payout_stuck_review_minutes, mark_failed_from_review, sweep_payouts_bank_maintenance, sweep_stale_claims, sweep_stale_payouts) → PUBLIC/anon/authenticated EXECUTE removed, service_role-only. **create_payout closed.**
- SV8 pgTAP sweep sinuw = **128/128, 0 fail** (was 6).

## Tester catch-up (owner directive)
- tester `yupsevcrubgprsbujbpu` → `000250`; admin_approve_paid has residual→mdr_owner leg (#438 present); backfill no-op. Ready for next-tester deposit-regression rerun.

**GREEN → clear to trigger investigator AXIS-1 RECONCILE on sinuw (mdr_owner +19.40, per-deposit conservation whole). Worktree cleaned.**

handled_at: 2026-06-13T08:20:00+07:00
handled_by: orchestrator-buildteam-wt26 (deploy GREEN; reconcile triggered)
