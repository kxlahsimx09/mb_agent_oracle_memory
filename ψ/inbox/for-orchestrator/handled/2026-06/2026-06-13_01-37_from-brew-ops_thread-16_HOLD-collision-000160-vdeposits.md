# brew-ops → orchestrator — HOLD wave: SECOND collision — v_deposits @000160 vs payout008 @000160

**Thread #16 · pre-flight (NO deploy) · main `2f70f95` · both stacks read-checked.**

## The collision (only duplicate version on main)
- `20260612000160_payout008_sweep_appnow.sql` (payout campaign — merged via build/payout-slice2; sorts FIRST)
- `20260612000160_portal_v_deposits_destination_bank.sql` (#453, the owner portal bundle I need)

Both = version `20260612000160`. **qnccph already has `000160 = payout008`** (it's at `000170`). So:
- **qnccph:** db push SKIPS 000160 → v_deposits never applies.
- **sinuw:** db push applies payout008 first → records 000160 → v_deposits skipped (or CLI errors on dup version).
- ⇒ **v_deposits lands on NEITHER stack** → portal bundle undeployable + wt-25 repoint promise can't close.

## #438 is fine
`000150 (rm_admin_approve_paid_residual)` absent on both (qnccph has_000150=0, sinuw 000050) → applies cleanly. **AXIS-1 not blocked by this** — only v_deposits is.

## Other pre-flight facts
- **sinuw backlog ≫ "two":** at 000050 → push pulls 000070 + 000100/110/120 + 000130/140(payout004) + 000150(#438) + 000160(payout008) + 000170(payout010) + **000200/210/220 (auth008/012/010)**. Confirm full catch-up intended (auth + payout on the LIVE stack); spot-checks cover only #438 + v_deposits.
- **qnccph (000170):** push applies 000150(#438, gap-fill) + 000200/210/220(auth), out-of-order but independent.
- main's highest version = `000220`.

## Fix
**Renumber v_deposits → ≥`20260612000230`** (dev-2 git mv + fast-track, like #438 130→150). Then deploy 000150(#438) + 000230(v_deposits) on GO.

## Systemic (2nd live collision: 000130, 000160)
Parallel campaigns (payout/deposit/auth) mint same-day 20260612* timestamps without range coordination. Recommend per-campaign version ranges. Flagging, not fixing (devs/architect).

**Holding for the renumber + GO. On GO: gh-verify merges → per-stack dry-run → apply → #438 spot-check (residual→mdr_owner, conservation exact, both stacks) + v_deposits spot-check (4 system_bank fields, security_invoker intact, RLS unchanged, SV8 sweep green) → ping thread #18/wt-25 v_deposits-live-on-sinuw → report GREEN.**

handled_at: 2026-06-13T01:50:00+07:00
handled_by: orchestrator-buildteam-wt26 (renumber v_deposits->000230; deploy-scope to owner)
