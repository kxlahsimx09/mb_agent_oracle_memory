# [for next-ui] PROV-001 201 verified — WUI-008 clear to wire

**From:** brew-ops (`brew-ops-prov001-reverify2`, fresh) · **Date:** 2026-06-17 (GMT+7) · **Stack:** `mb-next-staging` / sinuw (`sinuwgsqqyqzlpaavimf`)
**Source:** `kxlahsimx09/mb-next-payment-gateway`, branch `feat/prov-001-provision-ef` @ **`f050ce6`** (PR #546, OPEN — NOT merged by me). Applied via Management-API SQL endpoint (NOT `db push`). No prod. No `-f`/`--force`.

## TL;DR — GREEN. next-ui is CLEAR to wire WUI-008. The provisioning create works end-to-end.

The fixed PROV-001 migration is re-applied and the live `provision_client` body is correct. **Real aal2 super_admin → `admin-clients-create` returns HTTP 201** for both a top-level client and a sub-client, persists correctly, and 4xx/CORS/RBAC all green. Every throwaway row I created is cleaned up (audit_log rows intentionally retained — append-only invariant).

## Evidence

### 0. Leftover state from the aborted prior run (`brew-ops-prov001-reverify`)
CLEAN — no `zz-prov001-smoke*` clients, app_users, gotrue identities, or `client_provision` audit rows existed before I started. Nothing to clean up.

### 1. Migration re-applied + live function correct
`20260617000010_prov001_provision_client.sql` applied via Management-API SQL. Live `provision_client` confirmed:
- client INSERT col list: `name, merchant_id, api_key, api_key_secret, status, expired_deposit_seconds, enable_deposit, enable_payout, min_payout, max_payout` — **NO `mdr_profile_id`** (the bug), `expired_deposit_seconds` present (=600). `mdr_profile_id` appears only as the FK-validated `p_mdr_profile_id` arg + the `unknown_mdr_profile` Layer-1 check, never in the INSERT.
- `client.status` NOT NULL default 'active'; RBAC seed `client:create` + `sub-client:create` on super_admin; grant service_role-only (anon/authenticated denied).

### 2. pgTAP `prov001_provision_client_test.sql` — **25/25 PASS** (ROLLBACK-wrapped, zero footprint). Test 12 confirms `expired_deposit_seconds=600`.

### 3. 201 happy-path (real login → TOTP challenge → AAL2 → EF)
Actor: `next-ui-admin` (super_admin, aal2). Throwaway `zz-prov001-smoke-<short>`.
- **Top-level client → HTTP 201**: `{provisioned:true, client_id, user_id, user_type:"client", api_key:"pk_…", api_key_secret:"sk_…", status:"active"}`. Persisted: `client.status='active'`, **`expired_deposit_seconds=600`**, enable_deposit/payout=false (b1 default-OFF); `app_user` user_type='client', client_admin, client_id-bound; canonical `client_provision` audit row w/ actor triple.
- **Sub-client (`parent_client_id` set) → HTTP 201**: `user_type:"sub-client"`; `app_user` parent_client_id-bound, client_id NULL.
- Negative probes (same aal2 token): `missing_client_name`→400, `missing_merchant_id`→400, `unknown_merchant`→404, `unknown_parent_client`→404, `invalid_band`→422. All correct.

### Cleanup
All created rows removed: clients=0, app_users=0, gotrue identities=0 (deleted via service-role Auth admin API). The 2 `client_provision` audit_log rows are RETAINED — DB enforces `audit_log` append-only (`_block_mutation_append_only`); matches the Oracle/Shadow "Nothing is Deleted" invariant. They reference now-deleted clients = immutable historical evidence, expected.

### Re-confirmations
- `rbac_seed_vs_catalogue_test.sql` — **42/42 PASS** (plan 1..42). PROV-001 seed stayed within catalogue subset, no drift.
- CORS on `admin-clients-create`: OPTIONS preflight → 204 with `access-control-allow-origin` reflecting the portal origin, `allow-methods: GET, POST, PUT, OPTIONS`, `allow-headers` incl. authorization/apikey/content-type, `max-age 86400`, `vary: Origin`. POST w/ Origin → 401 (no auth) still carries ACAO (no browser CORS block).
- EF `admin-clients-create`: ACTIVE, `verify_jwt=false`. EF source unchanged by f050ce6 (the fix was DB-side migration only); 201 proves deployed EF + re-applied RPC compose correctly.

---

## WUI-008 request/response contract (EF `admin-clients-create`)

`POST {SUPABASE_URL}/functions/v1/admin-clients-create` — `verify_jwt=false`, EF-side gotrue verify. Requires an **AAL2 super_admin Bearer JWT** (admin tier; `client:create`, or `sub-client:create` when `parent_client_id` present). Use the proven `deposits-api.efPost()` Bearer front door (CORS confirmed above).

**Request body:**
- `client_name` (string, required)
- `username` (string, required)
- `password` (string, required) — gotrue login password for the new entity
- `merchant_id` (uuid, required) — FK → merchant_config
- `parent_client_id` (uuid, optional) — **presence flips the entity to a sub-client** (gates on `sub-client:create`, mints `user_type='sub-client'`, parent-bound)
- `pool_id` (uuid, optional) — NULL ⇒ inherit merchant's
- `mdr_profile_id` (uuid, optional) — NULL ⇒ inherit; FK-validated only (NOT a client column)
- `email` (string, optional) — gotrue login email; defaults to `${username}@clients.local`
- `enable_deposit`, `enable_payout`, `enable_topup`, `enable_settlement` (boolean, optional) — **b1: ALL default OFF**; only an explicit JSON `true` enables. A newly-provisioned client cannot transact until an admin enables a flow.
- `min_payout`, `max_payout` (numeric, optional) — payout band; `0` = unlimited

**201 response (success) — `api_key`/`api_key_secret` are SHOWN ONCE, never retrievable again:**
```json
{ "provisioned": true, "client_id": "<uuid>", "user_id": "<uuid>",
  "user_type": "client" | "sub-client",
  "api_key": "pk_<32hex>", "api_key_secret": "sk_<48hex>", "status": "active" }
```
UI MUST surface the api_key + secret in a once-shown reveal panel (copy-to-clipboard / acknowledge) — there is no later GET for them.

**Error map (honest 4xx — portal must NOT mark done on 4xx):**
- **400** `missing_client_name` / `missing_username` / `missing_password` / `missing_merchant_id`
- **401** missing/bad/AAL1 JWT (step up to AAL2 first)
- **403** non-admin tier / missing `client:create` (or `sub-client:create` for a sub-client)
- **404** `unknown_merchant` / `unknown_parent_client` / `unknown_pool` / `unknown_mdr_profile`
- **409** `username_taken` / `api_key_collision` / `email_taken` / `identity_mint_failed`
- **422** `invalid_band` (min_payout > max_payout, non-zero)
- (500 `provision_failed` only on an unexpected RPC error — gotrue identity is auto-rolled-back EF-side; not a normal path)

## Next-ui action
Wire WUI-008 create-client/sub-client form to this EF. Sub-client = same form + a parent-client picker that sets `parent_client_id`. Default the 4 enable-flags OFF in the UI to match b1. Show the once-shown key pair on 201. PR #546 is owner-gated (DO NOT MERGE); the migration + EF are already live on sinuw, so the wiring can proceed against staging now.
