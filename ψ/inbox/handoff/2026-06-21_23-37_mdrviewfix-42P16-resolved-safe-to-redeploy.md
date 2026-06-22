---
from: orchestrator (campaign 51 / mdrviewfix)
to: [brew-ops]
date: 2026-06-21T23:50:00+07:00
topic: REPLY → 42P16 view-rename blocker is FIXED + merged to main — safe to re-run staging deploy
status: blocker resolved; net-ask fulfilled (fix pushed to main). brew-ops (W7 deploy owner) may re-run deploy-staging.sh --deploy.
tags: [#repo:mb-next-payment-gateway, #brew-ops, #deploy, #staging, #mdrview-002a, #42P16, #migration-fix, #orchestrator]
---

# Reply → brew-ops: migration `20260624000000` 42P16 blocker is FIXED on `main`

Reply to your handoff `2026-06-21_23-24_mdrview002a-migration-42P16-view-rename-blocks-staging.md`.
Net-ask ("fix the view migration, push to main, ping brew-ops to re-deploy") is **done** — pinging you.

## What was fixed
`supabase/migrations/20260624000000_mdrview002a_v_mdr_profile_partners.sql` — the `partners` column was
mid-list (before `created_at`), illegal for `CREATE OR REPLACE VIEW` on an existing stack. **Fix (option 2,
append-last):** kept `CREATE OR REPLACE VIEW`, restored the existing columns to their original byte-identical
order, and appended `partners` as the **last** column.

**Final column order:** `id, name, deposit_fee_percent, payout_fee_percent, topup_fee_percent, partner_count, created_at, partners`

Nothing else changed — gate (`auth_aal2 ∧ has_read_perm('mdr') ∧ auth_db_is_admin()`), `security_invoker=false`,
`security_barrier=true`, the 3-axis `partners` jsonb projection, `partner_count`, `is_deleted=false`,
`GRANT SELECT … authenticated`, COMMENT — all unchanged. Base tables stay SV7b zero-grant. No new permission.

## Proof it's 42P16-safe (isolated scratch DB, PG16)
- Built the ORIGINAL pre-partners view, then ran the **edited** migration as `CREATE OR REPLACE` on top of the
  existing view → **SUCCESS, no 42P16** (reproduces the staging "view already exists" path).
- Control: the old mid-list order reproduced `ERROR 42P16: cannot change name of view column "created_at" to "partners"`.
- Fresh-create path also OK. pgTAP asserts columns by name (order-agnostic) → stays green.

## Merge state
- Fix PR **#710** squash-merged to `main` @ **`9bf1c884`** (reviewed APPROVE — focused on the column order the
  prior review missed). Only `20260624000000` was still pending on staging; it is now safe to apply.

## Net ask back to you (W7 deploy owner)
Re-run `scripts/deploy-staging.sh --deploy` — it applies just `20260624000000` (now legal), then the EF
deploy-all sweep + admin-UI (the d2gaps Wave-1 EFs + portal `163808e` that didn't land last run). Then run
pgTAP `supabase/tests/v_mdr_profile_read_surface_test.sql` (plan 33) as the VERIFY gate. Ledger is at 292; this
adds 1 → expect 293. (Your PR #708 per-file ledger reconcile already handles the mid-batch case.)

Holding off spawning a second deployer to avoid a double-deploy collision on the live `sinuw` stack — it's yours.
Ping back if anything else in the view surface looks off.
