# brew-ops → orchestrator — HOLD pre-brief wave: migration version COLLISION at 20260612000130

**Thread #16 · pre-brief recon (NO deploy) · both stacks read-only-checked.**

## The fork (verified via gh + git ls-tree + both stacks' schema_migrations)
| version | main `b08e69e` | `origin/build/payout-slice2` (UNMERGED) | qnccph applied | sinuw applied |
|---|---|---|---|---|
| 000070 | adr10_parity_residual_guard | (same) | yes | no |
| 000100/110/120 | payout001/002/003 | (same) | yes | no |
| **000130** | **rm_admin_approve_paid_residual (#438, MERGED 15:19)** | **payout004_reconcile_failed_from_review** | **payout004_reconcile (from payout-slice2)** | no |
| 000140 | — | payout004_sweep_appnow_config | payout004_sweep | no |

- **qnccph (seal):** rev `000140`, deployed from `build/payout-slice2`; HAS payout004@000130/000140; **does NOT have #438**.
- **sinuw (staging):** rev `000050`; has none of 000070–000140.

## Why the wave breaks as briefed
- **qnccph:** `db push` SKIPS 000130 (already recorded as payout004_reconcile) → **#438 never applies to qnccph** (silent). Stacks fork at 000130 (same version, different migration).
- **sinuw:** 5 migrations behind main → push applies 000070 + 000100/110/120 + 000130(#438) + then v_deposits — not "two." #438 DOES apply to sinuw.
- **AXIS-1** reads sinuw → **#438 applies cleanly to sinuw**, so AXIS-1 is reachable; qnccph parity is the gap.

## Decisions (architect/orchestrator + payout campaign — not mine to renumber)
1. **#438 → renumber ≥000150** (above qnccph 000140) so it applies to BOTH + survives payout-slice2's merge; OR out-of-band SQL + manual schema_migrations row on qnccph.
2. **payout-slice2 ↔ main:** payout004@000130/000140 collides with #438@000130 on merge — payout campaign must renumber/coordinate (standing hazard).
3. **sinuw backlog:** confirm full main backlog (000070–000130) is intended for sinuw (likely yes; more than "two").
4. **v_deposits (dev-2):** cut at ≥000150 (avoid 000130/000140 taken on qnccph).

**Recommendation:** #438→000150, v_deposits→000160; then I deploy both to sinuw+qnccph on GO with the specified spot-checks (#438: admin-approve fresh deposit → residual→mdr_owner, conservation exact; v_deposits: 4 system_bank fields populate, security_invoker intact, RLS unchanged) and ping thread #18/wt-25 once v_deposits is live on sinuw. **Holding for GO + path confirmation.**

handled_at: 2026-06-12T22:35:00+07:00
handled_by: orchestrator-buildteam-wt26 (renumber #438->000150 v_deposits->000160; hazard flagged)
