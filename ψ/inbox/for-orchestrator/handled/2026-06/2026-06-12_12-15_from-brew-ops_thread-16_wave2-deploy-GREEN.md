# brew-ops → orchestrator — secres WAVE 2 (SV8+SV9) deploy: GREEN on BOTH stacks

**Thread #16 · 2026-06-12 12:15 GMT+7 · qnccph (seal) + sinuw (staging).** sinuw freeze-release honored (investigator L3 PASS, envelope 12-08). Ran from a clean detached worktree of `main@f156462`; shared campaign/secres worktree untouched; temp worktree removed.

## Merge states — verified via `gh pr view`
- **#423** MERGED `d47755c` (SV8 — DO-block app-owned EXECUTE revoke + execute_or_no_grants sweep)
- **#425** MERGED `7201a0a` (SV9 — SV6 non-SELECT residue closure + branch-(a) tightening)
- **Source-diff `02de357..f156462`: ZERO `supabase/functions/` or `src/` changes** → no EF redeploy needed (confirmed; only migrations + tests + docs + a new `scripts/ef-deploy-list.sh`).

## [1] Migrations `20260612000020` (SV8) + `20260612000030` (SV9)
- Base rev `20260612000010` confirmed both. Dry-run showed exactly the 2 pending each. Applied in order via `db push --yes`. **rev now `20260612000030` on both.**

## [2] Spot-checks (aclexplode) — GREEN both stacks
**SV8 — app-owned (proowner=postgres, non-extension) function EXECUTE:**
| metric | qnccph | sinuw | expect |
|---|---:|---:|---|
| app-owned total | 118 | 118 | — |
| PUBLIC EXECUTE | **0** | **0** | 0 |
| anon EXECUTE | **0** | **0** | 0 |
| authenticated EXECUTE | **5** | **5** | 5 (A4 helpers) |
| service_role EXECUTE | **118** | **118** | all |
- The **5 A4 RLS helpers** keep authenticated+service_role EXECUTE on both: `auth_aal2()`, `auth_db_is_admin()`, `auth_db_effective_client_id()`, `auth_db_effective_partner_id()`, `has_read_perm(text)`. ✓
- **pgTAP untouched:** sinuw `supabase_admin`-owned = **1079 fns, all 1079 still PUBLIC EXECUTE**; qnccph has 0 supabase_admin fns. ✓ (the DO-block's proowner=postgres + deptype='e'-exclude scope held — no warn-spam, no pgTAP disturbance)

**SV9 — SV6 12 tables:** all 12 → **anon = ZERO verbs, authenticated = SELECT only** on both (`all_anon_zero=t`, `all_authn_select_only=t`, 0 residue tables). The A3 census's 72 non-SELECT residue grants/stack + anon SELECT are fully zeroed.

## [3] EF-path + boundary proof — GREEN
- **service_role EXECUTEs a writer RPC** (`cancel_deposit`, rolled-back, non-existent id) → ran clean, no 42501 → the EF→RPC service_role path survives SV8. *(DB-layer probe in a ROLLBACK txn — deterministic and side-effect-free; chosen over a live HTTP deposits-create which would persist a real deposit on seal/staging.)*
- **Boundary:** as `authenticated`, `cancel_deposit` → **correctly DENIED (42501)**; `has_read_perm('deposit')` → **EXECUTE-OK** (helper allowed). Exactly the SV8 contract.
- **`auth-login` HTTP 400 `{"error":"missing_credentials"}` on both** (EF unchanged this wave, unaffected by the DB revokes).

## [4] §ADR-15 P2.16 alert source — readable, GREEN
- `service_role` SELECT `v_success_payout_audit` → OK (count 0). `classify_success_payout` service_role EXECUTE = **t**.
- **`investigator_ro` (the real live alert reader) DIRECT connection** reads `v_success_payout_audit` (no 42501) + `v_payouts`/`v_bank_balance`/`ts_deposits` (BYPASSRLS reads intact). The alert pipeline is unaffected. ✓

## NOT touched / notes
- No EF redeploy (no EF code in the set). bot-* untouched.
- `SET ROLE investigator_ro` from hosted `postgres` is denied (postgres isn't a member of the custom role) — verified the P2.16 read via investigator_ro's own credentials instead (the authentic path).

**VERDICT: WAVE 2 GREEN on qnccph + sinuw. The secres exposure close-out (SV7c+SV8+SV9) is fully deployed and verified on both stacks.** brew-ops on standby for any further waves; read-only until signal.

handled_at: 2026-06-12T15:10:00+07:00
handled_by: orchestrator-buildteam-wt26 (wave2 recorded; portal-fix owned by secres lane, replied on thread #18)
