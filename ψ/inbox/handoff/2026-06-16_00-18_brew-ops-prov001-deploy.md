# [for next-ui + next-dev] PROV-001 admin-clients-create deployed to staging — wire WUI-008 (4xx OK; 201 HAPPY-PATH BLOCKED by an RPC bug)

**From:** brew-ops (slug `brew-ops-prov001-deploy`) · **Date:** 2026-06-17 (GMT+7) · **Stack:** `mb-next-staging` / sinuw (`sinuwgsqqyqzlpaavimf`)
**Source:** `kxlahsimx09/mb-next-payment-gateway`, branch `feat/prov-001-provision-ef`, **PR #546** (OPEN, owner-gated — NOT merged by me). Worktree `mb-next-payment-gateway.wt-prov001`.
**Continues:** next-dev handoff `2026-06-16_00-08_next-dev-prov001-ef.md`.

## TL;DR — MIGRATION + EF + CORS + RBAC GATE all GREEN. But the **201 happy path 500s**: the `provision_client` RPC INSERTs into `client` columns that do NOT exist on this substrate. The portal can wire the form + the honest-4xx surface NOW; the **create-success path is BLOCKED on a 1-line gateway fix (next-dev / PR #546).**

## 1. Migration applied (TARGETED — Management-API SQL endpoint, NOT db push)
- `supabase/migrations/20260617000010_prov001_provision_client.sql` applied via `POST /v1/projects/{ref}/database/query` (exact branch SQL) + recorded in `supabase_migrations.schema_migrations` (`20260617000010 / prov001_provision_client`). Same targeted discipline as BOTLOG/v_users — main's in-flight topup/settlement migrations NOT dragged on.
- Prereqs verified present on sinuw BEFORE apply: `app_user.status` (20260612000210) ✓, `role_permissions` (20260611000010) ✓. Note: `20260616000120` is NOT on sinuw (sinuw ledger tail = `20260616000070`); it is an ordering reference, NOT a hard dep — the migration's real deps are satisfied and it is idempotent, so I applied it.
- Post-apply verified: `client.status` col present (NOT NULL default `'active'`, CHECK active|inactive|suspended) ✓ · `provision_client` RPC present, SECURITY DEFINER ✓ · EXECUTE granted to `service_role`+`postgres` only (anon/authenticated/public correctly absent) ✓ · 2 RBAC seeds present ✓.

## 2. EF deployed — ACTIVE + CORS correct
- `admin-clients-create` deployed TARGETED by name (bundled the flipped `_shared/rbac.ts` automatically). **ACTIVE, version 1, verify_jwt=false.**
- **CORS preflight:** portal origin `https://mb-next-admin-portal.vercel.app` → **204 + ACAO echoed** (+ allow-headers `authorization, apikey, content-type, x-client-info`, allow-methods `GET, POST, PUT, OPTIONS`). `http://localhost:3000` → 204 + ACAO echoed. Evil origin → **204 with NO ACAO** (blocked). 
- No-bearer POST → **401 `missing_bearer_token`** (fail-closed, ACAO still echoed). GET → 405.

## 3. pgTAP gates
- **`rbac_seed_vs_catalogue_test.sql`: 42/42 PASS, 0 fail.** `ok 9 seed ⊆ catalogue: client:create` + `ok 34 sub-client:create` both GREEN; SUBSET gate (ok 4) GREEN. The 2 new verbs are catalogue-clean within-authority adds, exactly as next-dev stated. (Bonus: the prior `bot-activity-log:view` drift is resolved — ok 8 green.)
- **`prov001_provision_client_test.sql`: FAILS.** Tests 1–8 (structural/grant/seed) pass; then the happy-path call aborts the txn and cascades. **TWO defects surfaced (see §4).**

## 4. ⛔ BLOCKER — the 201 happy path 500s (gateway code bug, PR #546 — for next-dev)
Behavioral verify as a REAL aal2 super_admin (next-ui.env slot + live TOTP; aal claim = aal2):
| case | result |
|---|---|
| 400 missing_client_name | ✅ `{"error":"missing_client_name"}` |
| 404 unknown_merchant | ✅ `{"error":"unknown_merchant"}` |
| 422 invalid_band (min>max) | ✅ `{"error":"invalid_band"}` |
| **201 real provision** (`zz-prov001-smoke-…`) | ❌ **HTTP 500 `{"error":"provision_failed"}`** |

**Root cause (proven by a ROLLBACK-wrapped direct RPC probe, zero footprint):**
`ERROR: column "mdr_profile_id" of relation "client" does not exist` — `provision_client` line 63 INSERT. The RPC's `INSERT INTO public.client (name, merchant_id, api_key, api_key_secret, mdr_profile_id, status, enable_deposit, enable_payout, min_payout, max_payout)` references **two columns wrong for this substrate**:
1. **`client.mdr_profile_id` does NOT exist** anywhere on the `client` table (verified live + grep-verified no migration ever adds it to `client`; the only `mdr_profile_id` ADD COLUMN is on `ts_payouts`, migration 20260612000100). The RPC must NOT write `mdr_profile_id` to `client` (or a migration must add the column first). The `p_mdr_profile_id` FK-existence VALIDATE is fine; only the INSERT into the non-existent column is the bug.
2. **`client.expired_deposit_seconds` is NOT NULL with NO default** — the RPC's INSERT omits it, so even after fixing #1 the INSERT fails a NOT NULL violation. Must supply a value (existing clients use 900/300/30; suggest a sensible default e.g. 900, or inherit). 
3. **Test bug** in `prov001_provision_client_test.sql` (separate from the RPC): the happy-path call `provision_client((SELECT v FROM _t WHERE k='m')…)` errors `column reference "v" is ambiguous` — the test's `_t(k,v)` CTE column `v` collides with the RPC's internal plpgsql `v` variable when the subquery is evaluated in-function. Alias the CTE column (e.g. `_t(k, val)`) so the test runs.

**No cleanup needed:** the 500 left ZERO state — the DB txn rolled back AND the EF's `rollbackIdentity()` deleted the gotrue user. Verified: 0 `zz-prov001%` client rows, 0 app_user rows, 0 orphaned `auth.users`, 0 `client_provision` audit rows. The all-or-nothing atomicity (DB txn + EF-side identity compensation) is actually well-built — only the `client` INSERT shape is wrong.

## 5. EXACT WUI-008 CONTRACT (copied from next-dev's handoff — confirmed live for the 4xx surface)
**EF:** `POST /functions/v1/admin-clients-create` (verify_jwt=false, EF-side gotrue verify, AAL2 admin JWT, Bearer).
**Request body (JSON):** `client_name`*, `username`* (unique on app_user), `password`*, `merchant_id`* (FK→merchant_config). Optional: `parent_client_id` (present ⇒ SUB-CLIENT, gates `sub-client:create`; absent ⇒ top-level, gates `client:create`; must resolve to an ACTIVE client), `email` (default `<username>@clients.local`), `pool_id` (NULL⇒inherit), `mdr_profile_id` (NULL⇒inherit), `enable_deposit`/`enable_payout`/`enable_topup`/`enable_settlement` (**b1 default-OFF: only explicit JSON `true` enables**), `min_payout`/`max_payout` (0=unlimited; min>max non-zero ⇒ 422).
**Success 201:** `{ provisioned:true, client_id:<uuid>, user_id:<gotrue sub = app_user.id>, user_type:"client"|"sub-client", api_key:"pk_…", api_key_secret:"sk_…" /* §ADR-7 — SHOWN ONCE, never retrievable */, status:"active" }`. `user_id` is the value every lifecycle EF (set-role/disable/enable/unlock/reset-2fa) takes, and the row `v_users` surfaces.
**Errors (honest 4xx — portal must NOT mark done on 4xx):** 400 `missing_client_name`/`missing_username`/`missing_password`/`missing_merchant_id` · 401 missing/bad/AAL1 JWT · 403 `{error:"forbidden", required_permission}` (non-admin / missing client:create|sub-client:create) · 404 `unknown_merchant`/`unknown_parent_client`/`unknown_pool`/`unknown_mdr_profile` · 422 `invalid_band` · 409 `username_taken`/`api_key_collision`/`email_taken`/`identity_mint_failed`.

## 6. Is next-ui clear to wire WUI-008?
**PARTIALLY.** next-ui CAN wire the form + the 4xx/no-done-on-4xx handling + the once-shown api_key/secret UI scaffold against this live contract NOW (the 400/404/422/401/403 surface is REAL and verified). But the **§ADR-21 AUTH/WUI-008 flip to "done" must WAIT** for the next-dev RPC fix + a re-deploy + a green 201 — until then a real "Create client" submit 500s. Recommend: next-ui builds the form now, and either I or a follow-up brew-ops re-runs the 201 verify after next-dev pushes the `client` INSERT fix to PR #546.

## Safety / scope
No PR merged (owner-gated). No prod touched. No `-f`/`--force`. Worktree left clean (made ZERO repo edits — only applied SQL to sinuw + ran the gates). Did NOT patch the migration on staging to mask the bug (would diverge staging from PR #546). pgtap 1.3.3 + psql 16 used via the sinuw session pooler.

## Fallback path
`/home/ubuntu/Code/github.com/kxlahsimx09/mb_agent_oracle_memory/ψ/inbox/handoff/2026-06-17_HH-MM_brew-ops-prov001-deploy.md`
