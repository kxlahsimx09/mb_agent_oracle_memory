# HANDOFF → owner of mdrview-002a / PR #705 — migration `20260624000000` blocks staging deploy (42P16)

**From:** brew-ops (W7 staging deploy) · **To:** the gateway migration owner / author of PR #705 · **Date:** 2026-06-21 (GMT+7)
**Stack:** staging/live `sinuw` (`sinuwgsqqyqzlpaavimf`). **Scope:** one migration is a deploy-blocker; pure SQL authoring fix.

## TL;DR
`supabase/migrations/20260624000000_mdrview002a_v_mdr_profile_partners.sql` **fails on any stack where `v_mdr_profile` already exists** — i.e. every deployed stack. It uses `CREATE OR REPLACE VIEW` but changes the view's column set/order (adds `partners`), and Postgres forbids that:

```
ERROR: 42P16: cannot change name of view column "created_at" to "partners"
HINT: Use ALTER VIEW ... RENAME COLUMN ... to change name of view column instead.
```

`CREATE OR REPLACE VIEW` can only **append** columns at the end and cannot rename/reorder/remove existing ones. It passed CI / fresh-DB (view created from scratch) but blocks every redeploy onto an existing stack. This is a migration-authoring bug, not a deploy/tooling issue.

## The fix (your call — pick one)
1. **DROP then recreate** (simplest, matches intent):
   ```sql
   DROP VIEW IF EXISTS public.v_mdr_profile CASCADE;   -- then the existing CREATE ... AS SELECT ...
   ```
   Re-grant + re-COMMENT after (the file already does GRANT SELECT … authenticated). CASCADE only if dependents exist — check first; if any, recreate them too.
2. **Append-only**: keep the existing column order byte-identical and add `partners` as the LAST column, so `CREATE OR REPLACE` is legal (no rename/reorder). The file's header claims columns are "byte-identical to 20260618000400:184-209" — they are NOT in the failing version (the new column lands mid-list, shifting `created_at`).

Either way, re-run `supabase/tests/v_mdr_profile_read_surface_test.sql` (pgTAP) to confirm the read surface + gate are unchanged.

## Current staging state (so you don't trip on it)
- The deploy applied the 9 pending migrations BEFORE this one (dtr-w3, d2gaps withdrawal-review, T&C build+seed) and **brew-ops reconciled the ledger** for them (283 → **292**). `v_mdr_profile` is **untouched** (the failing statement rolled back) — old definition still live.
- **Only `20260624000000` remains pending.** Once you push the fix to `main`, brew-ops re-runs `scripts/deploy-staging.sh --deploy` — it applies just that one migration, then the EF deploy-all sweep + admin-UI (which did NOT deploy this run because the script correctly stopped at migrations).
- EF/UI on staging are therefore still the prior deploy (105 EFs, UI `827dda7`); the d2gaps Wave-1 EFs + portal `163808e` land on the re-deploy after your fix.

## Tooling note (already handled, FYI)
The deploy helper batched its ledger reconcile at the end of the apply loop, so this mid-batch failure stranded the 9 applied files as unledgered drift. Fixed in **PR #708** (ledger per-file). No action needed from you — flagged for context.

**Net ask:** fix the view migration (DROP+recreate or append-last), push to gateway `main`, ping brew-ops to re-deploy.
