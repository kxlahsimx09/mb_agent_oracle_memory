# [for next-ui] v_system_banks applied to staging — wire /system-bank

**From:** brew-ops (slug `brew-ops-vsystembanks-deploy2`), 2026-06-17 (GMT+7)
**Target applied:** staging **sinuw** (`sinuwgsqqyqzlpaavimf`)
**Source:** `kxlahsimx09/mb-next-payment-gateway`, branch `feat/bank-read-views`, **PR #553 (OPEN — NOT merged by me)**
**Continues:** next-dev handoff `2026-06-17_15-07_next-dev-bankacct-readviews`

## TL;DR — next-ui is CLEAR to wire `/system-bank`
`public.v_system_banks` is LIVE on sinuw and verified leak-safe with a real aal2 admin. Bind `supabase.from('v_system_banks').select('*')`. No EF deploy needed (it's a VIEW; mirrors v_users exactly).

> Note (only /system-bank is unblocked): per next-dev §3, **/bank-accounts** (client/partner beneficiary registry + approval workflow) is a real BACKEND GAP — no table/RPCs exist. NOT addressed here; needs a separate backend slice.

## Migration applied (TARGETED — Management-API SQL endpoint, NOT db push)
- `supabase/migrations/20260617000030_v_system_banks_read_surface.sql` (sha256 `a9d4e58b…83f3`, 10316 bytes) applied via `POST /v1/projects/sinuwgsqqyqzlpaavimf/database/query` — exact SQL piped from the PR branch. **HTTP 201, clean.** Same BOTLOG/v_users discipline — staging is ~10 forward-slices behind main + out-of-order, so `db push` would refuse and/or drag in unrelated topup/settlement/pullout migrations. Targeted apply avoided that.
- **Pre-state:** `v_system_banks` did NOT exist (clean apply); all 3 helpers (`auth_aal2`/`has_read_perm`/`auth_db_is_admin`) live; base `bank_account` already zero-grant (SV7b); all 12 referenced columns present.
- **Post-state verified (Management API):** reloptions = `security_invoker=false, security_barrier=true`; grants view→authenticated TRUE, view→anon FALSE, base `bank_account`→authenticated FALSE (SV7b intact); 16 projection columns in exact contract order; 0 secret/credential columns; seed `super_admin → system-bank:view` present.

## pgTAP gate: 22/22 PASS (psql 16 / pgtap 1.3.3 via sinuw session pooler)
`supabase/tests/v_system_banks_read_surface_test.sql` — all substantive assertions pass (structural + secret-free TEETH + grants + seed + behavioral: aal2 super_admin enumerates the bank, code/pool_name/method-flags/daily_in_count observable; aal1/client/partner/no-claim all → 0 rows).

⚠️ **Two TEST-FILE bugs (NOT migration defects) — for next-dev / PR #553:**
1. **plan count off by 2:** file declares `plan(20)` but contains **22** assertions (behavioral block has 9, not 7). pg_prove reports "planned 20 but ran 22". Fix → `plan(22)`.
2. **FK fixture bug (same class as the v_users test):** the behavioral block inserts `app_user` UCLI with `client_id=CLI` but NEVER seeds the parent `client` (or its `merchant_config`) row → on a CLEAN DB the `app_user_client_id_fkey` rejects it and aborts tests 14–22. On staging the run passed ONLY because three fixed-id app_user rows already exist from the prior v_users run, so the `ON CONFLICT (id) DO NOTHING` insert was a no-op and the FK was never evaluated. I re-ran a corrected version (seed `merchant_config`→`client` before `app_user`, fresh isolated ids, `plan(22)`) → **22/22 PASS independent of staging leftovers**, proving the migration itself is correct.

## rbac_seed_vs_catalogue_test.sql: 55/55 PASS, 0 fail
- Test 44 `seed ⊆ catalogue: system-bank:view` = **PASS** — the seed is catalogue-native, no test change (exactly as next-dev stated; CA7 subset gate test 4 stays GREEN).
- Note: tests 4 & 8 (`bot-activity-log:view`), flagged as pre-existing failures in the v_users round, are now GREEN here — the BOTLOG catalogue amendment has since landed. No regressions from my seed.

## Behavioral leak-safety verify (REST, REAL aal2 admin via portal-test-cast U_SA slot + real TOTP)
TOTP generator KAT-verified (RFC 6238: GEZD… @ T=59 → 287082 PASS) before use. Flow: password sign-in → aal1 → mfa.challenge → mfa.verify(TOTP) → **aal2** JWT (aal claim = aal2). Actor = `olive-u-sa+hk32qr@probe.local` (app_user: admin / super_admin; role carries system-bank:view).
- **(A) aal2 admin** `GET /rest/v1/v_system_banks?select=*` → **HTTP 200, 7 real bank_account rows**, full 16-col contract shape. **SECRET/CREDENTIAL COLUMNS = NONE** (regex scan over token|secret|password|_enc|api_key|credential|encrypted). `account_number` present and **FULL** (e.g. len 10) — expected, admin-gated per §5. Sample: code=scb, balance=1000000, pool=main_pool, deposit+payout=true, daily_in=0.
- **(B) aal1 admin** (same user, NOT stepped up) → **HTTP 200, 0 rows** — aal2 gate fail-closed. Does NOT repeat the v_payouts leak class.
- **(C) anon** → **HTTP 401** `permission denied for view v_system_banks` (no grant).
- **(D) aal2 admin direct-select on base `bank_account`** → **HTTP 403** permission denied (SV7b zero-grant intact — base stays unreadable).

## ⚠️ Stale slot note (for whoever owns slots)
`.secrets/slots/next-ui.env` is STALE on sinuw — its `UI_ADMIN_USER_ID` (`67814db3…`, `next-ui-admin@probe.local`) no longer exists in gotrue (admin API → null). I used the current `.secrets/slots/portal-test-cast.env` `U_SA_*` super-admin slot (factor id `03ada07a…`) instead. next-ui should use portal-test-cast U_SA (or a refreshed next-ui.env) for any aal2 admin flow on sinuw.

## EXACT row-shape contract for /system-bank (from next-dev's handoff; confirmed live on sinuw, 16 cols in this order)
| view column | type | SystemBankRow field | BACKED |
|---|---|---|---|
| `id` | uuid | id | yes |
| `system_bank_code` | text | bankCode | yes |
| `account_name` | text | accountName | yes |
| `account_number` | text | accountNo (FULL — admin-tier) | yes |
| `balance` | numeric | balance | yes |
| `available_balance` | numeric | (extra; bot-reported real-bank balance) | yes (bonus) |
| `is_active` | bool | status (true→active / false→inactive) | yes |
| `availability` | text | derive `bot` (online→'online' else 'offline') AND `working` (maintenance→'maintenance', online→'ready', offline/error→'busy') | yes |
| `last_heartbeat_at` | timestamptz | (bot liveness) | yes (bonus) |
| `pool_name` | text | pool (NULL if none) | yes |
| `method_deposit` | bool | methods.deposit | yes |
| `method_payout` | bool | methods.payout | yes |
| `method_pullout` | bool | (extra; no SystemBankRow slot) | yes (bonus) |
| `method_direct_transfer` | bool | (extra) | yes (bonus) |
| `daily_in_count` | int | dailyInCount (lazy-midnight reset: stale reset_date → 0) | yes |
| `created_at` | timestamptz | (sort key) | yes |

**UNBACKED SystemBankRow fields (no schema column — UI must degrade; follow-up):** `mdrProfile`, `priority`, `methods.topup`, `methods.settlement`, `dailyOutCount`, `dailyCount` (in+out; out unbacked), `dailyAmount`.

## For next-ui — wire it
Add `listSystemBanks()` (mirror `listUsers()`): `supabase.from('v_system_banks').select('*').order('created_at',{ascending:false})` with the user's **aal2** session → rows iff admin ∧ system-bank:view ∧ aal2, `[]` otherwise (RLS is the authority; non-admin/below-aal2 → `[]`, anon → 401). The /system-bank page can flip from `@/lib/mock` to live now. **PR #553 stays OPEN — DO NOT MERGE.**
