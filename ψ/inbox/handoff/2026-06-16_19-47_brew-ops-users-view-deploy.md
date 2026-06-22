# [for next-ui] v_users read surface applied to staging — wire listUsers()

**From:** brew-ops (slug `brew-ops-users-view-deploy`), 2026-06-16
**Target applied:** staging **sinuw** (`sinuwgsqqyqzlpaavimf`)
**Source:** `kxlahsimx09/mb-next-payment-gateway`, branch `feat/users-read-surface`, PR #543 (OPEN, owner-gated — NOT merged by me)
**Continues:** next-dev handoff `2026-06-16_19-41_next-dev-users-read-surface.md`

## TL;DR
`public.v_users` is LIVE on sinuw and verified leak-safe. **next-ui is clear to wire `listUsers()`.** No EF deploy was needed (it's a VIEW; lifecycle EFs already live).

## Migration applied (TARGETED — not `db push`)
- `supabase/migrations/20260616000040_v_users_read_surface.sql` applied via the **Supabase Management-API SQL endpoint** (`POST /v1/projects/{ref}/database/query`), exact SQL piped from the feat branch. Same BOTLOG discipline — main's in-flight TOPUP migrations were NOT dragged onto staging.
- Pre-state: `v_users` did not exist (clean apply), all 3 helpers (`auth_aal2`/`has_read_perm`/`auth_db_is_admin`) live.
- Post-state verified:
  - reloptions = `security_invoker=false, security_barrier=true` (embedded-gate shape)
  - grants: `authenticated` SELECT = true, `anon` = false, base `app_user` `authenticated` SELECT = false (SV7b intact)
  - seed `super_admin → user:view` present (idempotent ON CONFLICT)
  - 13 projection columns, in order, no secret columns

## pgTAP gate result: 20/20 PASS
`supabase/tests/v_users_read_surface_test.sql` run against sinuw via session pooler (psql 16, pgtap 1.3.3 installed). **All 20 assertions pass** (structural + secret-free TEETH + grants + seed + RBAC-gated behavioral 13–20: admin sees ≥4 seeded rows, id = app_user.id, status/is_locked observable, and aal1/client/partner/no-claim all → 0 rows).

⚠️ **Test-file fixture-ordering bug (NOT a migration defect) — for next-dev/PR #543:** the behavioral block seeds the `app_user` client-tier actor (`UCLI`, `client_id=CLI`) BEFORE seeding the `client` row for `CLI`, so `app_user_client_id_fkey` (`app_user.client_id → client(id)`) rejects it and aborts the txn → tests 13–20 error. Fix = move the `merchant_config` + `client` INSERTs ABOVE the `app_user` INSERT. I verified all 20 pass with that one reorder (same fixture data, still ROLLBACK-wrapped). The migration itself is correct; this is purely test-author ordering.

## Behavioral verify (REST, real aal2 admin via next-ui.env + real TOTP)
- aal1 sign-in → MFA challenge → TOTP verify → **aal2 JWT** (aal claim = aal2).
- **(A) aal2 admin** `GET /rest/v1/v_users?select=*` → **327 rows**, full contract shape, **no secret column** (clean leak check).
- **(B) aal1 admin** (same user, NOT stepped-up) → **0 rows** — aal2 gate fail-closed. Leak-safety proven; does NOT repeat the v_payouts class.
- **(C) anon** → HTTP 401 `permission denied for view v_users` (no grant).

## rbac_seed_vs_catalogue_test.sql re-confirm
- Test **37 `seed ⊆ catalogue: user:view` = PASS** → the `user:view` seed I added is gate-clean (already a ratified F3 catalogue member; no test change, exactly as next-dev stated).
- ⚠️ 2 PRE-EXISTING failures unrelated to v_users (separate item): test 8 `bot-activity-log:view` (seeded to `super_admin` from the BOTLOG round but not in this test file's catalogue enumeration) and test 4 (the SUBSET-gate rollup that fails because of test 8). My migration only adds `user:view`; it did not introduce these. Flagging for whoever owns the BOTLOG catalogue amendment.

## EXACT row-shape contract for listUsers() (copied from next-dev's handoff; confirmed live on sinuw)
```ts
type AdminUserRow = {
  id: string;                  // uuid — gotrue sub / app_user.id; THE user_id every lifecycle EF takes
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

## For next-ui — wire it
Add `listUsers()` to `mb-next-admin-portal/src/lib/admin-users-api.ts`: `supabase.from('v_users').select('*')` with the user's aal2 session → rows iff admin+user:view, `[]` otherwise. §ADR-21 can flip AUTH-011/012 `via=api → via=ui` once the list drives the lifecycle EFs.
