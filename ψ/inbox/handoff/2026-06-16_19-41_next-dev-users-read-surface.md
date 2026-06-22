# [for brew-ops] user-list read surface — migration ready to apply (sinuw)

**From:** next-dev (slug `next-dev-users-read-surface`), 2026-06-16
**Repo:** `kxlahsimx09/mb-next-payment-gateway`
**Branch:** `feat/users-read-surface`
**PR:** #543 (https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/543) — **DO NOT MERGE** (owner-gated)

## What this unblocks
The `/users` portal page had no authenticated-readable user list (`v_auth_users` is investigator_ro-only; `app_user` is SV7b zero-grant; no admin-users-list EF), so the shipped WUI-006/009 lifecycle EFs (set-role/disable/enable/unlock, portal PR #37, EFs live on sinuw) couldn't be driven from the UI and §ADR-21 couldn't flip AUTH-011/012 `via=api → via=ui`. This adds the read surface.

## Surface type: a VIEW (not a function, not an EF)
`public.v_users` — owner-context projection over `app_user`, mirroring the entity-read-views slice (`v_merchants`/`v_clients`, migration 20260611000300) which **explicitly named this /users view in §5** as the prescribed fast-follow. NOT the v_payouts leak class.
- `WITH (security_invoker = false, security_barrier = true)`
- A4 admin-tier gate embedded in WHERE: `aal2 ∧ has_read_perm('user') ∧ auth_db_is_admin()` (DB-fresh; all three helpers already EXECUTE-granted to authenticated via 20260611000010)
- `GRANT SELECT ON v_users TO authenticated` only; base `app_user` stays zero-grant; anon nothing
- NO secret columns (app_user has none; auth.users not projected)

## Files + apply order (TARGETED apply — main may carry in-flight topup migrations; do NOT `db push`/deploy-all, same discipline as BOTLOG)
1. `supabase/migrations/20260616000040_v_users_read_surface.sql` — creates the view, grants SELECT to authenticated, seeds the perm. Idempotent (CREATE OR REPLACE VIEW + ON CONFLICT seed).
2. Then run the pgTAP: `supabase/tests/v_users_read_surface_test.sql` (20 assertions; psql `-tA -f`).
**No EF deploy needed** — this is a view; the lifecycle EFs already live on sinuw.

## New perm to seed (already in the migration)
`super_admin → user:view`. `user:view` is ALREADY a ratified F3 catalogue member (rbac_seed_vs_catalogue_test.sql block A: `('user','view create update delete')`) → CA7 seed ⊆ catalogue SUBSET gate stays green, **no test change**.

## EXACT row-shape contract for next-ui's listUsers() (reads `GET /rest/v1/v_users` as authenticated, aal2 JWT — same as v_deposits/v_clients)
```ts
type AdminUserRow = {
  id: string;                  // uuid — the gotrue sub / app_user.id; THE user_id every lifecycle EF takes
  username: string;
  email: string | null;        // nullable on app_user
  user_type: "admin" | "client" | "sub-client" | "partner";
  role: string;                // current single-valued RBAC role (set-role target)
  client_id: string | null;
  parent_client_id: string | null;
  status: "active" | "inactive" | "suspended";  // disable/enable axis (AUTH-012)
  is_locked: boolean;          // unlock axis (AUTH-005)
  failed_login_attempts: number;
  locked_at: string | null;
  banned_until: string | null;
  created_at: string;
};
```
Lifecycle EF bodies take `{ user_id: row.id, ... }`. set-role: `{ user_id, role }`; disable: `{ user_id, status, cut_sessions? }`; enable/unlock: `{ user_id }`.

## Gate status
- bun rbac + cors `_shared` tests: 24 pass / 0 fail.
- pgTAP authored to v_deposits_rls + authro_forensic_views house style; NOT run locally (no PG server/pgtap ext in this env) — structurally verified against the cited precedents. brew-ops runs it on apply.

## For next-ui
Add `listUsers()` to `mb-next-admin-portal/src/lib/admin-users-api.ts` binding the shape above. Minimal change: `supabase.from('v_users').select('*')` with the user's aal2 session → rows iff admin+user:view, `[]` otherwise.
