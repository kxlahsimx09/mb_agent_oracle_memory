# [for brew-ops + next-ui] bank read-views (system-bank + bank-accounts)

**Agent:** next-dev-bankacct-readviews · **Date:** 2026-06-17 (GMT+7)
**Repo:** kxlahsimx09/mb-next-payment-gateway
**Branch:** `feat/bank-read-views` (off `origin/main` HEAD 0839a18)
**PR:** #553 — https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/553 — **DO NOT MERGE** (awaiting review)

## TL;DR
- **/system-bank** → BUILT. New leak-safe read-view `public.v_system_banks` over `bank_account`. Mirrors the v_users / v_merchants pattern exactly. Ready to unblock next-ui.
- **/bank-accounts** → **DEEPER BACKEND GAP, not built.** The client/partner BENEFICIARY bank-account table with an approval workflow does NOT exist anywhere in migrations. This page needs a whole subsystem (table + approval state machine + RPCs), not a read-view. See §3.

## 1. Migration + targeted-apply order (sinuw — do NOT db push / deploy-all)
- File: `supabase/migrations/20260617000030_v_system_banks_read_surface.sql`
- Test: `supabase/tests/v_system_banks_read_surface_test.sql` (pgTAP, plan 20)
- **Apply order:** single migration, lands AFTER `20260617000020_v_users_read_surface.sql`. Independent of the in-flight topup/settlement/pullout migrations (no shared objects). Apply this ONE file targeted; do NOT run a full push (topup/settlement/pullout may be mid-flight on main).
- NOTE: I could NOT run the pgTAP locally (no reachable Postgres / no docker daemon / no pgtap ext in this env). SQL was statically verified against schema_floor + all bank_account ALTERs + the helper signatures. brew-ops please run `psql "$DB_URL" -f supabase/tests/v_system_banks_read_surface_test.sql` on staging after apply.

## 2. RBAC seeded
- `('super_admin', 'system-bank:view')` — **catalogue-native** (rbac_seed_vs_catalogue_test.sql block A: `('system-bank','view create update delete account-view restart-bot')`). Seed only; NO catalogue change → the CA7 subset gate stays GREEN with no test edit. Idempotent (ON CONFLICT (role,permission) DO NOTHING).
- (`bank-account:view` is ALSO already catalogue-native — block A line 82 `('bank-account','view create update delete approve')` — but NOT seeded here because there is no view/table to gate yet. Seed it when the /bank-accounts subsystem is built.)

## 3. /bank-accounts is a real gap (verified exhaustively)
Searched all 47 migrations + 53 tables + EFs. No `client_bank_account` / `partner_bank_account` / `beneficiary` / `payout_account` table with `owner_type(client|partner) + purpose(deposit|payout) + status(pending|approved|rejected) + is_default`. There is NO `is_default` column anywhere in the schema. Closest existing things:
- `settlements` (20260616000100): operator settles money OUT to clients/partners — has `entity_type(client|partner)`, `status`, dest bank fields, approval audit — but it's a TRANSACTION ledger, not a registered-beneficiary-account registry. No is_default, no purpose-deposit-vs-payout.
- `client` table has enable_deposit/enable_payout flags; `ts_payouts` takes inline destination bank details (no separate account registry).
→ Building /bank-accounts requires a new table + approval RPCs. Recommend filing a separate backend slice (next-architect/next-dev). It is NOT a read-view task.

## 4. CONTRACT for next-ui — v_system_banks
Bind: `supabase.from('v_system_banks').select('*')` (RLS is the authority — non-admin/below-aal2/no-perm caller sees `[]`, not a 4xx; anon → 401 no grant). Newest-first ordering is next-ui's `.order('created_at',{ascending:false})`.

Row shape (view columns) → SystemBankRow mapping:

| view column | type | SystemBankRow field | BACKED? |
|---|---|---|---|
| `id` | uuid | id | yes |
| `system_bank_code` | text | bankCode | yes |
| `account_name` | text | accountName | yes |
| `account_number` | text | accountNo | yes (FULL — admin-tier, see §5) |
| `balance` | numeric | balance | yes |
| `available_balance` | numeric | (extra; bot-reported real-bank balance) | yes (bonus) |
| `is_active` | bool | status (true→active / false→inactive) | yes |
| `availability` | text | derive `bot` (online→'online' else 'offline') AND `working` (maintenance→'maintenance', online→'ready', offline/error→'busy') | yes |
| `last_heartbeat_at` | timestamptz | (bot liveness; UI may refine bot online/off) | yes (bonus) |
| `pool_name` | text | pool (NULL if no pool) | yes |
| `method_deposit` | bool | methods.deposit | yes |
| `method_payout` | bool | methods.payout | yes |
| `method_pullout` | bool | (extra real method; no SystemBankRow slot) | yes (bonus) |
| `method_direct_transfer` | bool | (extra real method) | yes (bonus) |
| `daily_in_count` | int | dailyInCount (daily_deposit_count w/ lazy-midnight reset: stale reset_date → 0) | yes |
| `created_at` | timestamptz | (sort key) | yes |

**UNBACKED SystemBankRow fields (no schema column — UI must degrade; follow-up):**
- `mdrProfile` — bank_account has NO mdr_profile_id (it lives on client/ts_deposits/ts_payouts).
- `priority` — no priority column on bank_account (priority is on withdrawal_queue rows).
- `methods.topup` — NOT in the bank_account_method enum (`payout|pullout|direct_transfer|deposit`).
- `methods.settlement` — NOT in the enum (settlement derives to 'payout' via source_type_to_method).
- `dailyOutCount` — no per-account daily-out counter on schema.
- `dailyCount` — = in+out; out side unbacked.
- `dailyAmount` — no per-account daily-amount aggregate column.

## 5. account_number PII decision
**Exposed FULL** to the gated admin tier (NOT masked). Precedent: `v_deposits` destination-bank columns (`20260612000230` `_deposit_system_bank`) already surface the system bank's full account_number to an aal2 admin holding `deposit:view`. /system-bank is the screen where an admin operates these very accounts, and the gate here is strictly tighter (aal2 ∧ system-bank:view ∧ admin tier). Masking to last-4 would diverge from existing admin-tier precedent and defeat the screen's purpose. If policy later mandates last-4 HERE specifically, it's a one-line projection change (`right(account_number,4)`).

## 6. Leak-safety posture (matches v_users)
- Owner-context (`security_invoker=false`) + `security_barrier=true` (stops caller-qual pushdown below the gate).
- Embedded gate: `(SELECT auth_aal2()) AND (SELECT has_read_perm('system-bank')) AND (SELECT auth_db_is_admin())` — each wrapped in scalar subquery (InitPlan, once/query, DB-fresh).
- VIEW-only `GRANT SELECT TO authenticated`; base `bank_account` STAYS zero-grant (SV7b intact — TEETH test asserts authenticated has NO SELECT on base bank_account).
- NO credential column reachable: bank_account has none (bot creds in `bot_credentials`, NOT joined); storage_token* not projected; TEETH asserts no token/secret/enc/key/password column on the view.
